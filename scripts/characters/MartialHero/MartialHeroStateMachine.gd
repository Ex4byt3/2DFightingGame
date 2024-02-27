extends StateMachine

var parent = null
var ONE = SGFixed.ONE

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

var motion_inputs = {
	"QCF": [[0, -1], [1, -1], [1, 0]]
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

# very not working
#func parse_motion_inputs():
#	for motion in motion_inputs:
#		var motion_array = motion_inputs[motion]  # Get the array associated with the current key
#		if parent.controlBuffer.size() > motion_array.size():
#			var input_buffer = parent.controlBuffer
#			for i in range(motion_array.size() - 1, -1, -1):  # Start at the end of the array and decrement i
#				if i < 2:  # Check only the first two elements (x and y)
#					if input_buffer[i][0] != motion_array[i][0] or input_buffer[i][1] != motion_array[i][1]:
#						break
#				else:
#					if input_buffer[i][0] != motion_array[i][0] or input_buffer[i][1] != motion_array[i][1]:
#						break
#					else:
#						# return the motion input
#						return motion
#	return null


func transition_state(input):
	# Updating debug label
	update_debug_label(parent.input_vector)

	# Handle attacks
	handle_attacks(parent.input_vector, input)
	
	# Universal changes
	parent.velocity.y += parent.gravity
	if parent.is_on_floor:
		reset_jumps()

# very not working
#	var prased_input = parse_motion_inputs()
#	if prased_input != null:
#		print(str(prased_input))

	match states[state]:
		states.IDLE:
			if parent.is_on_floor:
				if parent.input_vector.x != 0:
					# Update which direction the character is facing
					if parent.input_vector.x > 0:
						parent.facingRight = true
					else:
						parent.facingRight = false
					
					# Update the direction the character is attempting to walk
					if input.get("sprint_macro", false):
						# If the character is using sprint_macro (default SHIFT) they sprint
						parent.velocity.x = parent.sprintingSpeed * (parent.input_vector.x * ONE)
						set_state('SPRINTING')
					else:
						# If the character isn't and they are moving in a direction, they are walking
						parent.velocity.x = parent.walkingSpeed * (parent.input_vector.x * ONE)
						set_state('WALKING')
				elif parent.input_vector.x == 0:
					# If the player is not moving left/right, don't move/stop moving
					parent.velocity.x = 0
					set_state('IDLE')
				if parent.input_vector.y == 1:
					# The player is attempting to jump, enter jumpsquat state
					set_state('JUMPSQUAT')
			else:
				set_state('AIRBORNE')
		states.CROUCHING:
			pass
		states.WALKING:
			if parent.is_on_floor:
				# If you are on the floor and moving, walk/sprint left/right if applicable
				if parent.input_vector.x != 0:
					# Face the direction based on where you are trying to move
					if parent.input_vector.x > 0:
						parent.facingRight = true
					else:
						parent.facingRight = false
					
					if input.get("sprint_macro", false) or sprint_check():
						# Sprint if you are trying to sprint
						parent.velocity.x = parent.sprintingSpeed * (parent.input_vector.x * ONE)
						set_state("SPRINTING")
					else:
						# Continue walking if you are trying to walk
						parent.velocity.x = parent.walkingSpeed * (parent.input_vector.x * ONE)
						set_state('WALKING')
				else:
					parent.velocity.x = 0
					set_state('IDLE')
				if parent.input_vector.y == 1:
					# The player is attempting to jump, enter jumpsquat state
					set_state('JUMPSQUAT')
			else:
				# Not on the ground while walking somehow, you are now airborne, goodluck!
				set_state('AIRBORNE')
		states.SPRINTING:
			if parent.is_on_floor:
				# If you are on the floor and moving, walk/sprint left/right if applicable
				if parent.input_vector.x != 0:
					# Face the direction based on where you are trying to move
					if parent.input_vector.x > 0:
						parent.facingRight = true
					else:
						parent.facingRight = false
					
					if input.get("sprint_macro", false) or sprint_check():
						# Sprint if you are trying to sprint
						parent.velocity.x = parent.sprintingSpeed * (parent.input_vector.x * ONE)
						set_state("SPRINTING")
				else:
					parent.velocity.x = 0
					set_state('IDLE')

				if parent.input_vector.y == 1:
					# The player is attempting to jump, enter jumpsquat state
					set_state('JUMPSQUAT')
			else:
				# Not on the ground while walking somehow, you are now airborne, goodluck!
				set_state('AIRBORNE')
			pass
		states.DASHING:
			pass
		states.JUMPING:
			if parent.is_on_floor:
				set_state('IDLE')
			else:
				if parent.velocity.y >= 0:
					set_state('AIRBORNE')
				# Handle air acceleration
				if parent.input_vector.x != 0:
					parent.velocity.x += SGFixed.mul(parent.airAcceleration, (parent.input_vector.x * ONE))
					if parent.velocity.x > parent.maxAirSpeed:
						parent.velocity.x = parent.maxAirSpeed
					elif parent.velocity.x < -parent.maxAirSpeed:
						parent.velocity.x = -parent.maxAirSpeed
		states.JUMPSQUAT:
			# Increment timer for the frames
			parent.frame += 1
			# Stopped jumping before it would be fullhop, it turns into shorthop
			if parent.input_vector.y != 1:
				parent.velocity.y = parent.shortHopForce
				parent.frame = 0
				set_state('JUMPING')
			# Jump has been held for more than 4 frames, fullhop
			if parent.frame > parent.jumpSquatFrames:
				parent.velocity.y = parent.fullHopForce
				parent.frame = 0
				set_state('JUMPING')
		states.AIRBORNE:
			if parent.is_on_floor:
				# TODO: LANDING
				set_state('IDLE')
			# This logic needs to be fixed, for jumping again in air (double jump?)
			if parent.input_vector.y == 1 and parent.airJump > 0:
				set_state('JUMPSQUAT')
				parent.airJump -= 1
			# If in the air and you are moving, update the velocity based on
			# air acceleration and air speed (for air drift implementation)
			if parent.input_vector.x != 0:
				parent.velocity.x += SGFixed.mul(parent.airAcceleration, (parent.input_vector.x * ONE))
				if parent.velocity.x > parent.maxAirSpeed:
					parent.velocity.x = parent.maxAirSpeed
				elif parent.velocity.x < -parent.maxAirSpeed:
					parent.velocity.x = -parent.maxAirSpeed
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
	
	# Updating input buffer
	update_input_buffer(parent.input_vector)

	update_animation()

func sprint_check() -> bool:
	# input buffer has [x, y, ticks] for each input, this will need to expand to [x, y, [button list], ticks] or something of the like later
	# if a direction is double tapped, the player sprints, no more than sprintInputLeinency frames between taps
	if parent.controlBuffer.size() > 3: # if the top of the buffer hold a direction, then neutral, then the same direction, the player sprints
		if parent.controlBuffer[0][2] < parent.sprintInputLeinency and parent.controlBuffer[1][2] < parent.sprintInputLeinency and parent.controlBuffer[2][2] < parent.sprintInputLeinency:
			if parent.controlBuffer[0][0] == parent.controlBuffer[2][0] and parent.controlBuffer[0][1] == parent.controlBuffer[2][1] and parent.controlBuffer[1][0] == 0 and parent.controlBuffer[1][1] == 0:
				return true
	return false

# Reset the number of jumps you have
func reset_jumps():
	parent.airJump = parent.airJumpMax

func update_animation():
	if parent.facingRight:
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
	var player_type: String = self.get_parent().name
	
	var debug_data: Dictionary = {
		"player_type": player_type,
		"pos_x": str(parent.fixed_position.x / ONE),
		"pos_y": str(parent.fixed_position.y / ONE),
		"velocity_x": str(parent.velocity.x / ONE),
		"velocity_y": str(parent.velocity.y / ONE),
		"input_vector_x": str(input_vector.x),
		"input_vector_y": str(input_vector.y),
		"state": str(state)
	}
	
	MenuSignalBus.emit_update_debug(debug_data)

	
func update_input_buffer(input_vector):
	var player_type: String = self.get_parent().name
	var inputs: Array = []

	if parent.controlBuffer.size() > 20:
		parent.controlBuffer.pop_back()
	
	if parent.controlBuffer.front()[0] == input_vector.x and parent.controlBuffer.front()[1] == input_vector.y:
		var ticks = parent.controlBuffer.front()[2]
		parent.controlBuffer.pop_front()
		parent.controlBuffer.push_front([input_vector.x, input_vector.y, ticks+1])
	else:
		parent.controlBuffer.push_front([input_vector.x, input_vector.y, 1])
	
	for item in parent.controlBuffer:
		var new_input: Array = []
		new_input.append(str(direction_mapping.get([item[0], item[1]], "NEUTRAL")))
		new_input.append(str(item[2]))
		inputs.append(new_input)

	var input_data: Dictionary = {
		"player_type": player_type,
		"inputs": inputs,
	}
	
	MenuSignalBus.emit_update_input_buffer(input_data)
