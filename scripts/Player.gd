extends SGKinematicBody2D

const Bomb = preload("res://scenes//Bomb.tscn")
const ONE := SGFixed.ONE # 1
var last_input_time = 0

onready var rng = $NetworkRandomNumberGenerator
onready var debugLabel = $DebugLabel

var velocity := SGFixed.vector2(0, 0)
var input_prefix := "player1_"
var acceleration := 4
var friction := ONE
var maxSpeed := 8 * ONE
var gravity := ONE / 2
var teleporting := false
var is_on_floor := false
var jumps_remaining := 2

# like Input.get_vector but for SGFixedVector2
# note: Input.is_action_just_pressed returns a float
func get_fixed_input_vector(negative_x: String, positive_x: String, negative_y: String, positive_y: String) -> SGFixedVector2:
	var input_vector = SGFixed.vector2(0, 0) # note: SGFixedVector2 is always passed by reference and can be copied with SGFixedVector2.copy()
	input_vector.x = 0
	input_vector.y = 0
	if Input.is_action_pressed(negative_x):
		input_vector.x -= ONE
	if Input.is_action_pressed(positive_x):
		input_vector.x += ONE
	if Input.is_action_pressed(negative_y):
		input_vector.y -= ONE
	if Input.is_action_pressed(positive_y):
		input_vector.y += ONE
	return input_vector

func _get_local_input() -> Dictionary:
	var input_vector = get_fixed_input_vector(input_prefix + "left", input_prefix + "right", input_prefix + "down", input_prefix + "up")
	var input := {}
	if input_vector != SGFixed.vector2(0, 0):
		input["input_vector_x"] = input_vector.x
		input["input_vector_y"] = input_vector.y
	if Input.is_action_just_pressed(input_prefix + "bomb"):
		input["drop_bomb"] = true
	if Input.is_action_just_pressed(input_prefix + "teleport"):
		input["teleport"] = true
	
	return input

func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	input.erase("drop_bomb")
	if ticks_since_real_input > 2:
		input.erase("input_vector")
	return input

func _network_process(input: Dictionary) -> void:
	# get input vector
	var input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	var air_control := ONE * 4

	# velocity vector
	velocity.x += input_vector.x * acceleration
	velocity.y += gravity
	
	if velocity.x > maxSpeed:
		velocity.x = maxSpeed
	if velocity.x < -maxSpeed:
		velocity.x = -maxSpeed
	
	if is_on_floor:
		jumps_remaining = 2
		if velocity.x > 0:
			velocity.x = max(0, velocity.x - friction)
		if velocity.x < 0:
			velocity.x = min(0, velocity.x + friction)
		if input_vector.y == ONE and jumps_remaining > 0:
			velocity.y = -16 * ONE
			jumps_remaining -= 1
	else:
		if jumps_remaining > 0 and input_vector.y == ONE:
			velocity.y = -8 * ONE
			jumps_remaining -= 1
	#else:
	#	if velocity.x > 0:
	#		velocity.x = max(0, velocity.x - (friction * air_control) / (ONE * 4))
			
		

	# update position based velocity vector // position += velocity
	fixed_position = fixed_position.add(velocity)
	velocity = move_and_slide(velocity, SGFixed.vector2(0, -ONE))
	
	# DEBUG
	debugLabel.text = "POSITION: " + str(fixed_position.x / ONE) + ", " + str(fixed_position.y / ONE) + "\nVELOCITY: " + str(velocity.x / ONE) + ", " + str(velocity.y / ONE) + "\nINPUT VECTOR: " + str(input_vector.x / ONE) + ", " + str(input_vector.y / ONE)
	
	if input.get("drop_bomb", false):
		SyncManager.spawn("Bomb", get_parent(), Bomb, { fixed_position_x = fixed_position.x, fixed_position_y = fixed_position.y })
	
	if input.get("teleport", false):
		fixed_position.x = (rng.randi() % 1024) * ONE
		fixed_position.y = (rng.randi() % 600) * ONE
		teleporting = true
	else:
		teleporting = false
		
	is_on_floor = is_on_floor() # update is_on_floor, does not work if called first in network_process, works if called last though

func _save_state() -> Dictionary:
	return {
		fixed_position_x = fixed_position.x,
		fixed_position_y = fixed_position.y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		is_on_floor = is_on_floor,
		teleporting = teleporting,
	}

func _load_state(state: Dictionary) -> void:
	fixed_position.x = state['fixed_position_x']
	fixed_position.y = state['fixed_position_y']
	velocity.x = state['velocity_x']
	velocity.y = state['velocity_y']
	is_on_floor = state['is_on_floor']
	teleporting = state['teleporting']
	sync_to_physics_engine()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	if old_state.get('teleporting', false) or new_state.get('teleporting', false):
		return
	fixed_position = old_state['fixed_position'].linear_interpolate(new_state['fixed_position'], weight)
