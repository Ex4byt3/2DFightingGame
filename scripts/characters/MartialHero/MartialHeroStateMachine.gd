extends StateMachine
var parent = null
var ONE = SGFixed.ONE

var walkingSpeed = 4
var sprintingSpeed = 8
var frame = 0
var sprintInputLeinency = 6
var airAcceleration : int = 0
var maxAirSpeed = 6
var gravity = 2
var airJumpMax = 0
var airJump = 0
var knockback_multiplier = 1
var weight = 100
var shortHopForce = 8
var fullHopForce = 16
var jumpSquatFrames = 4
var jumpSquatTimer = 0

var facingRight := true # for flipping the sprite

const Bomb = preload("res://scenes//gameplay//Bomb.tscn")
const Attack_Light = preload("res://scenes//gameplay//Hitbox.tscn")

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

func _ready():
	add_state('IDLE')
	add_state('CROUCHING')
	add_state('WALKING')
	add_state('SPRINTING')
	add_state('DASHING')
	add_state('JUMPSQUAT')
	add_state('JUMPING')
	add_state('SHORTHOP')
	add_state('FULLHOP')
	add_state('AIRBORNE')
	add_state('ATTACKING')
	add_state('BLOCKING')
	add_state('HITSTUN')
	add_state('DEAD')
	add_state('NEUTRAL_L')
	add_state('NEUTRAL_M')
	add_state('NEUTRAL_H')
	add_state('FORWARD_L')
	add_state('FORWARD_M')
	add_state('FORWARD_H')
	add_state('DOWN_L')
	add_state('DOWN_M')
	add_state('DOWN_H')
	set_state('IDLE')
	gravity = ONE / gravity
	maxAirSpeed *= ONE
	fullHopForce *= -ONE
	shortHopForce *= -ONE
	airAcceleration = ONE / 5
	if self.name == "ClientPlayer":
		facingRight = false

func transition_state(input: Dictionary):
	# Get everything that is being rolled back from the character
	var input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	var velocity = parent.velocity
	var is_on_floor = parent.is_on_floor

	# Updating debug label
	update_debug_label(input_vector)
	
	# Updating input buffer
	update_input_buffer(input_vector)

	# Handle attacks
	handle_attacks(input_vector, input)
	
	# Universal changes
	velocity.y += gravity
	if is_on_floor:
		reset_jumps()

	match states[state]:
		states.IDLE:
			if is_on_floor:
				if input_vector.x != 0:
					# Update which direction the character is facing
					if input_vector.x > 0:
						facingRight = true
					else:
						facingRight = false
					
					# Update the direction the character is attempting to walk
					if input.get("sprint_macro", false):
						# If the character is using sprint_macro (default SHIFT) they sprint
						velocity.x = sprintingSpeed * (input_vector.x * ONE)
						set_state('SPRINTING')
					else:
						# If the character isn't and they are moving in a direction, they are walking
						velocity.x = walkingSpeed * (input_vector.x * ONE)
						set_state('WALKING')
				elif input_vector.x == 0:
					# If the player is not moving left/right, don't move/stop moving
					velocity.x = 0
					set_state('IDLE')
				if input_vector.y == 1:
					# The player is attempting to jump, enter jumpsquat state
					set_state('JUMPSQUAT')
			else:
				set_state('AIRBORNE')
		states.CROUCHING:
			pass
		states.WALKING:
			if is_on_floor:
				# If you are on the floor and moving, walk/sprint left/right if applicable
				if input_vector.x != 0:
					# Face the direction based on where you are trying to move
					if input_vector.x > 0:
						facingRight = true
					else:
						facingRight = false
					
					if input.get("sprint_macro", false) or sprint_check():
						# Sprint if you are trying to sprint
						velocity.x = sprintingSpeed * (input_vector.x * ONE)
						set_state("SPRINTING")
					else:
						# Continue walking if you are trying to walk
						velocity.x = walkingSpeed * (input_vector.x * ONE)
						set_state('WALKING')
				else:
					velocity.x = 0
					set_state('IDLE')
				if input_vector.y == 1:
					# The player is attempting to jump, enter jumpsquat state
					set_state('JUMPSQUAT')
			else:
				# Not on the ground while walking somehow, you are now airborne, goodluck!
				set_state('AIRBORNE')
		states.SPRINTING:
			if is_on_floor:
				# If you are on the floor and moving, walk/sprint left/right if applicable
				if input_vector.x != 0:
					# Face the direction based on where you are trying to move
					if input_vector.x > 0:
						facingRight = true
					else:
						facingRight = false
					
					if input.get("sprint_macro", false) or sprint_check():
						# Sprint if you are trying to sprint
						velocity.x = sprintingSpeed * (input_vector.x * ONE)
						set_state("SPRINTING")
				else:
					velocity.x = 0
					set_state('IDLE')
			else:
				# Not on the ground while walking somehow, you are now airborne, goodluck!
				set_state('AIRBORNE')
			pass
		states.DASHING:
			pass
		states.JUMPSQUAT:
			# Increment timer for the frames
			jumpSquatTimer += 1
			# Stopped jumping before it would be fullhop, it turns into shorthop
			if input_vector.y != 1:
				velocity.y = shortHopForce
				jumpSquatTimer = 0
				set_state('JUMPING')
			# Jump has been held for more than 4 frames, fullhop
			if jumpSquatTimer > jumpSquatFrames:
				velocity.y = fullHopForce
				jumpSquatTimer = 0
				set_state('JUMPING')
		states.JUMPING:
			if is_on_floor:
				set_state('IDLE')
			else:
				if velocity.y >= 0:
					set_state('AIRBORNE')
				# Handle air acceleration
				if input_vector.x != 0:
					velocity.x += SGFixed.mul(airAcceleration, (input_vector.x * ONE))
					if velocity.x > maxAirSpeed:
						velocity.x = maxAirSpeed
					elif velocity.x < -maxAirSpeed:
						velocity.x = -maxAirSpeed
		states.AIRBORNE:
			if is_on_floor:
				# TO BE ADDED: LANDING
				set_state('IDLE')
			# This logic needs to be fixed, for jumping again in air (double jump?)
			if input_vector.y == 1 and airJump > 0:
				set_state('JUMPSQUAT')
				airJump -= 1
			# If in the air and you are moving, update the velocity based on
			# air acceleration and air speed (for air drift implementation)
			if input_vector.x != 0:
				velocity.x += SGFixed.mul(airAcceleration, (input_vector.x * ONE))
				if velocity.x > maxAirSpeed:
					velocity.x = maxAirSpeed
				elif velocity.x < -maxAirSpeed:
					velocity.x = -maxAirSpeed
		states.ATTACKING:
			pass
		states.BLOCKING:
			pass
		states.HITSTUN:
			pass
		states.DEAD:
			pass
		states.NEUTRAL_L:
			pass
		states.NEUTRAL_M:
			pass
		states.NEUTRAL_H:
			pass
		states.FORWARD_L:
			pass
		states.FORWARD_M:
			pass
		states.FORWARD_H:
			pass
		states.DOWN_L:
			pass
		states.DOWN_M:
			pass
		states.DOWN_H:
			pass
	
	update_animation()
	return velocity

func sprint_check() -> bool:
	# input buffer has [x, y, ticks] for each input, this will need to expand to [x, y, [button list], ticks] or something of the like later
	# if a direction is double tapped, the player sprints, no more than sprintInputLeinency frames between taps
	if parent.controlBuffer.size() > 3: # if the top of the buffer hold a direction, then neutral, then the same direction, the player sprints
		if parent.controlBuffer[0][2] < sprintInputLeinency and parent.controlBuffer[1][2] < sprintInputLeinency and parent.controlBuffer[2][2] < sprintInputLeinency:
			if parent.controlBuffer[0][0] == parent.controlBuffer[2][0] and parent.controlBuffer[0][1] == parent.controlBuffer[2][1] and parent.controlBuffer[1][0] == 0 and parent.controlBuffer[1][1] == 0:
				return true
	return false

# Reset the number of jumps you have
func reset_jumps():
	airJump = airJumpMax

func update_animation():
	if facingRight:
		parent.get_node('Sprite').flip_h = false
	else:
		parent.get_node('Sprite').flip_h = true
	match states[state]:
		states.IDLE:
			parent.get_node('NetworkAnimationPlayer').play("Idle")
		states.WALKING:
			parent.get_node('NetworkAnimationPlayer').play("Walk")
		states.SPRINTING:
			parent.get_node('NetworkAnimationPlayer').play("Walk")  # TODO: add sprint animation, for now it's the same as walking
		states.JUMPSQUAT:
			parent.get_node('NetworkAnimationPlayer').play("Jump") # plays the first frame of the jump animation
		states.SHORTHOP:
			parent.get_node('NetworkAnimationPlayer').play("Jump")
			parent.get_node('Sprite').frame = 1 # the second frame is jumping
		states.FULLHOP:
			parent.get_node('NetworkAnimationPlayer').play("Jump")
			parent.get_node('Sprite').frame = 1 # the second frame is jumping
		states.AIRBORNE:
			parent.get_node('NetworkAnimationPlayer').play("Fall")
		states.ATTACKING:
			parent.get_node('NetworkAnimationPlayer').play("Attack")
		states.BLOCKING:
			parent.get_node('NetworkAnimationPlayer').play("Block") # TODO: add block animation
		states.HITSTUN:
			parent.get_node('NetworkAnimationPlayer').play("Hitstun") # TODO: add hitstun animation
		states.DEAD:
			parent.get_node('NetworkAnimationPlayer').play("Dead")
		_:
			parent.get_node('NetworkAnimationPlayer').play("Idle")

# TODO: parse input buffer
func handle_attacks(input_vector, input):
	# Because if it is not true it is null, need to add the false argument to default it to false instead of null
	if input.get("drop_bomb", false):
		SyncManager.spawn("Bomb", get_parent().get_parent(), Bomb, { fixed_position_x = parent.fixed_position.x, fixed_position_y = parent.fixed_position.y })
	if input.get("attack_light", false):
		SyncManager.spawn("Attack_Light", get_parent().get_parent(), Attack_Light, { fixed_position_x = parent.fixed_position.x, fixed_position_y = parent.fixed_position.y })
	if input.get("attack_medium", false):
		SyncManager.spawn("Attack_Light", get_parent().get_parent(), Attack_Light, { fixed_position_x = parent.fixed_position.x, fixed_position_y = parent.fixed_position.y })
	if input.get("attack_heavy", false):
		SyncManager.spawn("Attack_Light", get_parent().get_parent(), Attack_Light, { fixed_position_x = parent.fixed_position.x, fixed_position_y = parent.fixed_position.y })
	if input.get("impact", false):
		SyncManager.spawn("Attack_Light", get_parent().get_parent(), Attack_Light, { fixed_position_x = parent.fixed_position.x, fixed_position_y = parent.fixed_position.y })
	if input.get("dash", false):
		SyncManager.spawn("Attack_Light", get_parent().get_parent(), Attack_Light, { fixed_position_x = parent.fixed_position.x, fixed_position_y = parent.fixed_position.y })
	if input.get("block", false):
		SyncManager.spawn("Attack_Light", get_parent().get_parent(), Attack_Light, { fixed_position_x = parent.fixed_position.x, fixed_position_y = parent.fixed_position.y })


func update_debug_label(input_vector):
	var debugLabel = parent.get_parent().get_node("DebugOverlay").get_node(parent.name + "DebugLabel")
	if self.name == "ServerPlayer":
		debugLabel.text = "PLAYER ONE DEBUG:\nPOSITION: " + str(parent.fixed_position.x / ONE) + ", " + str(parent.fixed_position.y / ONE) + "\nVELOCITY: " + str(parent.velocity.x / ONE) + ", " + str(parent.velocity.y / ONE) + "\nINPUT VECTOR: " + str(input_vector.x) + ", " + str(input_vector.y) + "\nSTATE: " + str(state)
	else:
		debugLabel.text = "PLAYER TWO DEBUG:\nPOSITION: " + str(parent.fixed_position.x / ONE) + ", " + str(parent.fixed_position.y / ONE) + "\nVELOCITY: " + str(parent.velocity.x / ONE) + ", " + str(parent.velocity.y / ONE) + "\nINPUT VECTOR: " + str(input_vector.x) + ", " + str(input_vector.y) + "\nSTATE: " + str(state)
	
func update_input_buffer(input_vector):
	var inputBuffer = parent.get_parent().get_node("DebugOverlay").get_node(parent.name + "InputBuffer")
	if parent.controlBuffer.size() > 20:
		parent.controlBuffer.pop_back()
	
	if parent.controlBuffer.front()[0] == input_vector.x and parent.controlBuffer.front()[1] == input_vector.y:
		var ticks = parent.controlBuffer.front()[2]
		parent.controlBuffer.pop_front()
		parent.controlBuffer.push_front([input_vector.x, input_vector.y, ticks+1])
	else:
		parent.controlBuffer.push_front([input_vector.x, input_vector.y, 1])
	
	if self.name == "ServerPlayer":
		inputBuffer.text = "PLAYER ONE INPUT BUFFER:\n"
	else:
		inputBuffer.text = "PLAYER TWO INPUT BUFFER:\n"
	
	for item in parent.controlBuffer:
		var direction = direction_mapping.get([item[0], item[1]], "NEUTRAL")
		inputBuffer.text += str(direction) + " " + str(item[2]) + " TICKS\n"
