extends SGKinematicBody2D

const Bomb = preload("res://scenes//gameplay//Bomb.tscn")
const ONE := SGFixed.ONE # fixed point 1
var last_input_time = 0

onready var rng = $NetworkRandomNumberGenerator

var direction_mapping = {
	[1, 1]: "UP RIGHT", # 9
	[1, 0]: "RIGHT", # 6
	[0, 1]: "UP", # 8
	[0, -1]: "DOWN", # 2
	[1, -1]: "DOWN RIGHT", # 3
	[-1, -1]: "DOWN LEFT", # 1
	[-1, 0]: "LEFT", # 4
	[-1, 1]: "UP LEFT" # 7
}

# attributes // to be tuned
var velocity := SGFixed.vector2(0, 0)
export var walkingSpeed := 4
export var sprintingSpeed := 8
var sprintInputLeinency := 6
var airAcceleration := 0.2
var maxAirSpeed := 6
var gravity := 2 # this is a divisor, so 1/2
export var knockback_multiplier := 1
export var weight := 100
export var maxJumps := 2
var jumpsRemaining := 2
export var shortHopHeight := 8
export var jumpHeight := 16
var jumpSquatFrames := 4
var jumpSquatTimer := 0
var fullHop := true
var jumpSquatting := false

var facingRight := true # for flipping the sprite
enum State { # all possible player states
	IDLE,
	CROUCHING,
	WALKING,
	SPRINTING,
	DASHING,
	JUMPSQUAT,
	JUMPING,
	FALLING,
	ATTACKING,
	BLOCKING,
	HITSTUN,
	DEAD,
	NEUTRAL_L,
	NEUTRAL_M,
	NEUTRAL_H,
	FORWARD_L,
	FORWARD_M,
	FORWARD_H,
	DOWN_L,
	DOWN_M,
	DOWN_H
}
var playerState := 0

# 
var tickCount := 0 # is this used?
var input_prefix := "player1_"
var is_on_floor := false

# 
var controlBuffer := [[0, 0, 0]]


func _ready():
	# set fixed point numbers
	maxAirSpeed = maxAirSpeed * ONE
	gravity = ONE / gravity
	jumpHeight = -jumpHeight * ONE
	shortHopHeight = -shortHopHeight * ONE

	if self.name == "ClientPlayer":
		facingRight = false
		

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
	if Input.is_action_pressed(input_prefix + "sprint_macro"): # pressed, not just pressed to allow for holding
		input["sprint_macro"] = true
	
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

	# DEBUG
	update_dubug_label(input_vector)

	# Input Buffer
	update_input_buffer(input_vector)
	# TODO: parse input buffer

	# calculate velocity
	velocity.y += gravity
	if is_on_floor:
		jumpsRemaining = maxJumps
		if input_vector.x != 0 and not jumpSquatting: # might be able to replace jumpSquatting flag with just a platerState check
			if input_vector.x > 0: # update facing direction
				facingRight = true
			else:
				facingRight = false

			if input.has("sprint_macro") or sprint_check():
				velocity.x = sprintingSpeed * input_vector.x
				playerState = State.SPRINTING
			else:
				velocity.x = walkingSpeed * input_vector.x
				playerState = State.WALKING
		elif input_vector.x == 0: # if the player is not holding left or right
			velocity.x = 0
			playerState = State.IDLE

		if input_vector.y == ONE: # jump
			playerState = State.JUMPSQUAT
			jumpSquatting = true
		if jumpSquatting:
			jumpSquatTimer += 1
			if input_vector.y != ONE:
				fullHop = false
			if jumpSquatTimer > jumpSquatFrames: # after jumpSquatFrames, the player jumps
				if fullHop: # if the player is holding up during all jumpSquatFrames, the player jumps higher
					velocity.y = jumpHeight
					playerState = State.JUMPING
				else:
					velocity.y = shortHopHeight
					playerState = State.JUMPING
				jumpSquatTimer = 0
				jumpSquatting = false
				fullHop = true
	else:
		if input_vector.x != 0:
			velocity.x += airAcceleration * input_vector.x
			if velocity.x > maxAirSpeed:
				velocity.x = maxAirSpeed
			elif velocity.x < -maxAirSpeed:
				velocity.x = -maxAirSpeed

		# if input_vector.y == ONE and jumpsRemaining > 0:
		# 	velocity.y = shortHopHeight
		# 	jumpsRemaining -= 1
		# 	playerState = State.JUMPING
			
			

	# update position based velocity vector // position += velocity
	fixed_position = fixed_position.add(velocity)
	velocity = move_and_slide(velocity, SGFixed.vector2(0, -ONE))
	
	if input.get("drop_bomb", false):
		SyncManager.spawn("Bomb", get_parent(), Bomb, { fixed_position_x = fixed_position.x, fixed_position_y = fixed_position.y })

	# update animation
	update_animation()
		
	is_on_floor = is_on_floor() # update is_on_floor, does not work if called first in network_process, works if called last though

func sprint_check() -> bool:
	# input buffer has [x, y, ticks] for each input, this will need to expand to [x, y, [button list], ticks] or something of the like later
	if playerState == State.SPRINTING:
		return true
	# if a direction is double tapped, the player sprints, no more than sprintInputLeinency frames between taps
	if controlBuffer.size() > 3: # if the top of the buffer hold a direction, then neutral, then the same direction, the player sprints
		if controlBuffer[0][2] < sprintInputLeinency and controlBuffer[1][2] < sprintInputLeinency and controlBuffer[2][2] < sprintInputLeinency:
			if controlBuffer[0][0] == controlBuffer[2][0] and controlBuffer[0][1] == controlBuffer[2][1] and controlBuffer[1][0] == 0 and controlBuffer[1][1] == 0:
				return true
	return false
	


func update_input_buffer(input_vector):
	var inputBuffer = get_parent().get_node("DebugOverlay").get_node(self.name + "InputBuffer")
	tickCount += 1
	if controlBuffer.size() > 20:
		controlBuffer.pop_back()
	if controlBuffer.front()[0] == input_vector.x/ONE and controlBuffer.front()[1] == input_vector.y/ONE:
		var ticks = controlBuffer.front()[2]
		controlBuffer.pop_front()
		controlBuffer.push_front([input_vector.x/ONE, input_vector.y/ONE, ticks+1])
	else:
		controlBuffer.push_front([input_vector.x/ONE, input_vector.y/ONE, 1])

	if self.name == "ServerPlayer":
		inputBuffer.text = "PLAYER ONE INPUT BUFFER:\n"
	else:
		inputBuffer.text = "PLAYER TWO INPUT BUFFER:\n"

	for item in controlBuffer:
		var direction = direction_mapping.get([item[0], item[1]], "NEUTRAL")
		inputBuffer.text += str(direction) + " " + str(item[2]) + " TICKS\n"

func update_animation():
	if facingRight:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
	match playerState:
		State.IDLE:
			$NetworkAnimationPlayer.play("Idle")
		State.WALKING:
			$NetworkAnimationPlayer.play("Walk")
		State.SPRINTING:
			$NetworkAnimationPlayer.play("Walk")  # TODO: add sprint animation, for now it's the same as walking
		State.JUMPSQUAT:
			$NetworkAnimationPlayer.play("Jump") # plays the first frame of the jump animation
		State.JUMPING:
			$NetworkAnimationPlayer.play("Jump")
			$Sprite.frame = 1 # the second frame is jumping
		State.FALLING:
			$NetworkAnimationPlayer.play("Fall")
		State.ATTACKING:
			$NetworkAnimationPlayer.play("Attack")
		State.BLOCKING:
			$NetworkAnimationPlayer.play("Block") # TODO: add block animation
		State.HITSTUN:
			$NetworkAnimationPlayer.play("Hitstun") # TODO: add hitstun animation
		State.DEAD:
			$NetworkAnimationPlayer.play("Dead")
		_:
			$NetworkAnimationPlayer.play("Idle")

func _save_state() -> Dictionary:
	var control_buffer = []
	for item in controlBuffer:
		control_buffer.append(item)
	return {
		control_buffer = control_buffer,
		tick_count = tickCount,
		fixed_position_x = fixed_position.x,
		fixed_position_y = fixed_position.y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		is_on_floor = is_on_floor,
	}

func _load_state(state: Dictionary) -> void:
	controlBuffer = []
	for item in state['control_buffer']:
		controlBuffer.append(item)
	tickCount = state['tick_count']
	fixed_position.x = state['fixed_position_x']
	fixed_position.y = state['fixed_position_y']
	velocity.x = state['velocity_x']
	velocity.y = state['velocity_y']
	is_on_floor = state['is_on_floor']
	sync_to_physics_engine()

func update_dubug_label(input_vector):
	var debugLabel = get_parent().get_node("DebugOverlay").get_node(self.name + "DebugLabel")
	if self.name == "ServerPlayer":
		debugLabel.text = "PLAYER ONE DEBUG:\nPOSITION: " + str(fixed_position.x / ONE) + ", " + str(fixed_position.y / ONE) + "\nVELOCITY: " + str(velocity.x / ONE) + ", " + str(velocity.y / ONE) + "\nINPUT VECTOR: " + str(input_vector.x / ONE) + ", " + str(input_vector.y / ONE) + "\nSTATE: " + str(playerState)
	else:
		debugLabel.text = "PLAYER TWO DEBUG:\nPOSITION: " + str(fixed_position.x / ONE) + ", " + str(fixed_position.y / ONE) + "\nVELOCITY: " + str(velocity.x / ONE) + ", " + str(velocity.y / ONE) + "\nINPUT VECTOR: " + str(input_vector.x / ONE) + ", " + str(input_vector.y / ONE) + "\nSTATE: " + str(playerState)
	
func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	fixed_position = old_state['fixed_position'].linear_interpolate(new_state['fixed_position'], weight)
