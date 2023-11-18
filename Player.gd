extends SGFixedNode2D

const Bomb = preload("res://Bomb.tscn")
const ONE := 65536 # 1
var last_input_time = 0

onready var rng = $NetworkRandomNumberGenerator

var input_prefix := "player1_"

var speed := 0
var teleporting := false

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
	var input_vector = get_fixed_input_vector(input_prefix + "left", input_prefix + "right", input_prefix + "up", input_prefix + "down")
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
	var input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	var max_speed = ONE * 3
	var acceleration_step = ONE / 4  # Smaller step for smoother transition

	if input_vector.x != 0 or input_vector.y != 0:
		# Gradually increase acceleration for smoother start
		if speed < max_speed:
			if speed < ONE / 2:  # Smaller initial speed
				speed += acceleration_step / 2
			else:
				speed += acceleration_step
			speed = min(speed, max_speed)
		fixed_position = fixed_position.add(input_vector.mul(speed))
	else:
		# Gradual deceleration
		speed = max(speed - acceleration_step, 0)
	if input.get("drop_bomb", false):
		SyncManager.spawn("Bomb", get_parent(), Bomb, { fixed_position = global_position })
	
	if input.get("teleport", false):
		var fixed_position := SGFixed.vector2(0, 0)
		fixed_position.x = (rng.randi() % 1024) * ONE
		fixed_position.y = (rng.randi() % 600) * ONE
		teleporting = true
	else:
		teleporting = false

func _save_state() -> Dictionary:
	return {
		fixed_position = fixed_position,
		speed = speed,
		teleporting = teleporting,
	}

func _load_state(state: Dictionary) -> void:
	fixed_position = state['fixed_position']
	speed = state['speed']
	teleporting = state['teleporting']

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	if old_state.get('teleporting', false) or new_state.get('teleporting', false):
		return
	fixed_position = old_state['fixed_position'].linear_interpolate(new_state['fixed_position'], weight)
