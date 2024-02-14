# This script current hold all the player logic,
# later Character.gd will need to handel only the bare framework of a character
# and then character logic will get moved to a seperate script for each character
# that will then extend this
extends SGKinematicBody2D

const Bomb = preload("res://scenes//gameplay//Bomb.tscn")
const Attack_Light = preload("res://scenes//gameplay//Hitbox.tscn")
const ONE := SGFixed.ONE # fixed point 1
var last_input_time = 0

onready var state = $State
onready var stateMachine = $StateMachine
onready var rng = $NetworkRandomNumberGenerator

# attributes // to be tuned
var velocity := SGFixed.vector2(0, 0)
export var walkingSpeed := 4
export var sprintingSpeed := 8
var sprintInputLeinency := 6
var airAcceleration := 0.2
var maxAirSpeed := 6
var gravity := 2 # this is a divisor, so 1/2
export var airJumpMax := 1
var airJump = 0
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
	AIR,
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
	
	stateMachine.character_node = self

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
	# perhaps have the input vector just be 1 instead of ONE and scale where nessary
	# because update input buffer has to do a lot of dividing, minor optimazation

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
	if Input.is_action_just_pressed(input_prefix + "light"):
		input["attack_light"] = true
	if Input.is_action_just_pressed(input_prefix + "medium"):
		input["attack_medium"] = true
	if Input.is_action_just_pressed(input_prefix + "heavy"):
		input["attack_heavy"] = true
	if Input.is_action_just_pressed(input_prefix + "impact"):
		input["impact"] = true
	if Input.is_action_just_pressed(input_prefix + "dash"):
		input["dash"] = true
	if Input.is_action_just_pressed(input_prefix + "block"):
		input["block"] = true
	
	return input

func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	input.erase("drop_bomb")
	if ticks_since_real_input > 2:
		input.erase("input_vector")
	return input

func _network_process(input: Dictionary) -> void:
	# Get input vector
	var input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	
	stateMachine.transition_state(input)
	
	# Handle movement TODO: MOVE TO STATE MACHINE
	handle_movement(input_vector, input)
	
	# Handle attacks TODO: MOVE TO STATE MACHINE
	handle_attacks(input_vector, input)
	
	# Updating animation TODO: MOVE TO STATE MACHINE
	update_animation()
	
	# Update is_on_floor, does not work if called before move_and_slide, works if called a though
	is_on_floor = is_on_floor() 

# TODO: parse input buffer
func handle_attacks(input_vector, input):
	# Because if it is not true it is null, need to add the false argument to default it to false instead of null
	if input.get("drop_bomb", false):
		SyncManager.spawn("Bomb", get_parent(), Bomb, { fixed_position_x = fixed_position.x, fixed_position_y = fixed_position.y })
	if input.get("attack_light", false):
		SyncManager.spawn("Attack_Light", get_parent(), Attack_Light, { fixed_position_x = fixed_position.x, fixed_position_y = fixed_position.y })
	if input.get("attack_medium", false):
		SyncManager.spawn("Attack_Light", get_parent(), Attack_Light, { fixed_position_x = fixed_position.x, fixed_position_y = fixed_position.y })
	if input.get("attack_heavy", false):
		SyncManager.spawn("Attack_Light", get_parent(), Attack_Light, { fixed_position_x = fixed_position.x, fixed_position_y = fixed_position.y })
	if input.get("impact", false):
		SyncManager.spawn("Attack_Light", get_parent(), Attack_Light, { fixed_position_x = fixed_position.x, fixed_position_y = fixed_position.y })
	if input.get("dash", false):
		SyncManager.spawn("Attack_Light", get_parent(), Attack_Light, { fixed_position_x = fixed_position.x, fixed_position_y = fixed_position.y })
	if input.get("block", false):
		SyncManager.spawn("Attack_Light", get_parent(), Attack_Light, { fixed_position_x = fixed_position.x, fixed_position_y = fixed_position.y })
	

func handle_movement(input_vector, input):
	# calculate velocity
	velocity.y += gravity
	if is_on_floor:
		airJump = airJumpMax
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
		if input_vector.y == ONE and airJump > 0:
				velocity.y = jumpHeight
				playerState = State.JUMPING
				airJump -= 1
		if input_vector.x != 0:
			velocity.x += airAcceleration * input_vector.x
			if velocity.x > maxAirSpeed:
				velocity.x = maxAirSpeed
			elif velocity.x < -maxAirSpeed:
				velocity.x = -maxAirSpeed
	
	# update position based velocity vector // position += velocity
	fixed_position = fixed_position.add(velocity)
	velocity = move_and_slide(velocity, SGFixed.vector2(0, -ONE))

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

func reset_Jumps():
	airJump = airJumpMax

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
	fixed_position.x = state['fixed_position_x']
	fixed_position.y = state['fixed_position_y']
	velocity.x = state['velocity_x']
	velocity.y = state['velocity_y']
	is_on_floor = state['is_on_floor']
	sync_to_physics_engine()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	fixed_position = old_state['fixed_position'].linear_interpolate(new_state['fixed_position'], weight)
