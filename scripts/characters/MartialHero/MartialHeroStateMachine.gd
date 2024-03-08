extends StateMachine

var parent = null
var ONE = SGFixed.ONE

var defaultDashDuration = 20



const Bomb = preload("res://scenes//gameplay//Bomb.tscn")
const Attack_Light = preload("res://scenes//gameplay//Hitbox.tscn")

func _ready():
	add_state('IDLE')
	add_state('CROUCH')
	add_state('CRAWL')
	add_state('WALK')
	add_state('SPRINT')
	add_state('DASH')
	add_state('JUMPSQUAT')
	add_state('JUMP')
	add_state('SHORTHOP')
	add_state('FULLHOP')
	add_state('AIRBORNE')
	add_state('ATTACKED')
	add_state('ATTACK')
	add_state('BLOCK')
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
	
func _on_dash_timer_timeout():
	set_state('IDLE')

func convert_inputs_to_string(inputs):
	var inputString = ""
	for input in inputs:
		inputString = str(parent.directions[input]) + inputString
	return inputString


func parse_motion_inputs():
	var remainingLeinency = parent.motionInputLeinency
	var validMotions = []
	# make a dict of only inputs within the last motionInputLeinency ticks
	for control in parent.controlBuffer:
		if control[0] != 0 or control[1] != 0: # if the input is not neutral
			validMotions.append([control[0], control[1]]) # add the input to the validMotions list
		remainingLeinency -= control[2] # subtract frames the input was held
		if remainingLeinency <= 0:
			break
	
	var inputString = convert_inputs_to_string(validMotions)
	# print(inputString) # all currently valid inputs

	# // can use custom search to maybe be faster than regex
	var regex = RegEx.new() 
	for motion in parent.motion_inputs:
		regex.compile(str(motion)) # compile the regex for the current motion
		if regex.search(inputString) != null: # if any match is found
			print(parent.motion_inputs[motion])
			return motion

func transition_state(input):
	# Updating debug label
	update_debug_label(parent.input_vector)

	# Update pressed actions
	update_pressed()

	# Handle attacks
	handle_attacks(parent.input_vector, input)
	
	# Universal changes
	parent.velocity.y += parent.gravity
	if parent.isOnFloor:
		reset_jumps()
		
	if parent.facingRight:
		parent.attackSprite.flip_h = false
		parent.arrowSprite.flip_h = false
	else:
		parent.attackSprite.flip_h = true
		parent.arrowSprite.flip_h = true

	# if input.has("light"): # enable to only check when light gets pressed, also for debugging
	parse_motion_inputs()

	if input.get("dash", false):
		initiate_dash(parent.input_vector)

	match states[state]:
		states.IDLE:
			if parent.takeDamage:
				set_state('ATTACKED')
			elif parent.isOnFloor:
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
						parent.animation.play("Sprint")
						set_state('SPRINT')
					else:
						# If the character isn't and they are moving in a direction, they are walking
						parent.velocity.x = parent.walkingSpeed * (parent.input_vector.x * ONE)
						parent.animation.play("Walk")
						set_state('WALK')
				elif parent.input_vector.x == 0:
					# If the player is not moving left/right, don't move/stop moving
					parent.velocity.x = 0
					parent.animation.play("Idle")
					set_state('IDLE')
				if parent.input_vector.y == 1:
					# The player is attempting to jump, enter jumpsquat state
					if parent.usedJump == false:
						start_jump()
			else:
				parent.animation.play("Airborne")
				set_state('AIRBORNE')
		states.CROUCH:
			pass
		states.WALK:
			if parent.isOnFloor:
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
						parent.animation.play("Sprint")
						set_state("SPRINT")
					else:
						# Continue walking if you are trying to walk
						parent.velocity.x = parent.walkingSpeed * (parent.input_vector.x * ONE)
						# parent.animation.play("Walk")
						# set_state('WALK')
				else:
					parent.velocity.x = 0
					parent.animation.play("Idle")
					set_state('IDLE')
				if parent.input_vector.y == 1:
					# The player is attempting to jump, enter jumpsquat state
					if parent.usedJump == false:
						start_jump()
			else:
				# Not on the ground while walking somehow, you are now airborne, goodluck!
				parent.animation.play("Airborne")
				set_state('AIRBORNE')
		states.SPRINT:
			if parent.isOnFloor:
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
						parent.animation.play("Sprint")
						set_state("SPRINT")
				else:
					parent.velocity.x = 0
					parent.animation.play("Idle")
					set_state('IDLE')

				if parent.input_vector.y == 1:
					# The player is attempting to jump, enter jumpsquat state
					if parent.usedJump == false:
						start_jump()
			else:
				# Not on the ground while walking somehow, you are now airborne, goodluck!
				parent.animation.play("Airborne")
				set_state('AIRBORNE')
			pass
		states.DASH:
			handle_dash_state()
			pass
		states.JUMP:
			if parent.isOnFloor:
				parent.animation.play("Idle")
				set_state('IDLE')
			else:
				if parent.velocity.y >= 0:
					parent.animation.play("Airborne")
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
				parent.animation.play("Airborne") # can have seperate animation for shothop without seperate state
				set_state('AIRBORNE')
			# Jump has been held for more than 4 frames, fullhop
			if parent.frame > parent.jumpSquatFrames:
				parent.velocity.y = parent.fullHopForce
				parent.frame = 0
				parent.animation.play("Airborne")
				set_state('AIRBORNE')
		states.AIRBORNE:
			if parent.isOnFloor:
				# TODO: LANDING
				parent.animation.play("Idle")
				set_state('IDLE')
			# This logic needs to be fixed, for jumping again in air (double jump?)
			else:
				if parent.input_vector.y == 1 and parent.airJump > 0:
					if parent.usedJump == false:
						parent.airJump -= 1
						start_jump()
			# If in the air and you are moving, update the velocity based on
			# air acceleration and air speed (for air drift implementation)
			if parent.input_vector.x != 0:
				parent.velocity.x += SGFixed.mul(parent.airAcceleration, (parent.input_vector.x * ONE))
				if parent.velocity.x > parent.maxAirSpeed:
					parent.velocity.x = parent.maxAirSpeed
				elif parent.velocity.x < -parent.maxAirSpeed:
					parent.velocity.x = -parent.maxAirSpeed
		states.ATTACKED:
			parent.health -= parent.damage
			parent.damage = 0
			parent.takeDamage = false
			set_state('IDLE')
		states.ATTACK:
			pass
		states.BLOCK:
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

func start_jump():
	parent.usedJump = true
	parent.animation.play("JumpSquat")
	set_state('JUMPSQUAT')

func update_pressed():
	# Update pressed
	if parent.input_vector.y != 1:
		parent.usedJump = false

func initiate_dash(input_vector):
	var dash_speed = parent.sprintingSpeed * SGFixed.ONE * 8

	
	var dash_direction = Vector2.ZERO
	if input_vector.x != 0:
		dash_direction.x = sign(input_vector.x)
	if input_vector.y != 0:
		
		dash_direction.y = -sign(input_vector.y) 

	
	dash_direction = dash_direction.normalized()

	
	if input_vector.y != 0:
		parent.velocity.y = -dash_speed if input_vector.y ==1 else dash_speed

	# Set the dash state duration, if applicable.
	parent.frame = 20

	# Transition to the DASH state.
	set_state('DASH')

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

func handle_dash_state():
	print("DASHING!")
	# Decrease the dash duration each frame.
	if !parent.frame == 0:
		parent.frame -= 1
	else:
		# Once the dash duration ends, transition back to IDLE or any appropriate state.
		set_state('IDLE')
	
	if !parent.isOnFloor:
		parent.velocity.y += parent.gravity
		if parent.velocity.y > parent.maxFallSpeed: 
			parent.velocity.y = parent.maxFallSpeed

# TODO: parse input buffer
func handle_attacks(input_vector, input):
	# Because if it is not true it is null, need to add the false argument to default it to false instead of null
	var spawn_position_x = parent.fixed_position.x
	
	if parent.facingRight:
		spawn_position_x = (55 * ONE)
	else:
		spawn_position_x = -(55 * ONE)
	
	if input.get("drop_bomb", false):
		SyncManager.spawn("Bomb", parent.get_parent(), Bomb, { 
			fixed_position_x = parent.fixed_position.x,
			fixed_position_y = parent.fixed_position.y 
		})
	if input.get("attack_light", false):
		if parent.get_node("SpawnHitbox").get_child_count() == 0:
			parent.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", parent.get_node("SpawnHitbox"), Attack_Light, { 
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 1000,
				attacking_player = parent.name
			})
	if input.get("attack_medium", false):
		if parent.get_node("SpawnHitbox").get_child_count() == 0:
			parent.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", parent.get_node("SpawnHitbox"), Attack_Light, {
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 2000,
				attacking_player = parent.name
			})
	if input.get("attack_heavy", false):
		if parent.get_node("SpawnHitbox").get_child_count() == 0:
			parent.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", parent.get_node("SpawnHitbox"), Attack_Light, {
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 3000,
				attacking_player = parent.name
			})
	if input.get("impact", false):
		if parent.get_node("SpawnHitbox").get_child_count() == 0:
			parent.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", parent.get_node("SpawnHitbox"), Attack_Light, {
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 1000,
				attacking_player = parent.name
			})
	if input.get("dash", false):
		if parent.get_node("SpawnHitbox").get_child_count() == 0:
			parent.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", parent.get_node("SpawnHitbox"), Attack_Light, {
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 1000,
				attacking_player = parent.name
			})
	if input.get("block", false):
		if parent.get_node("SpawnHitbox").get_child_count() == 0:
			parent.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", parent.get_node("SpawnHitbox"), Attack_Light, {
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 1000,
				attacking_player = parent.name
			})


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
		new_input.append(str(parent.direction_mapping.get([item[0], item[1]], "NEUTRAL")))
		new_input.append(str(item[2]))
		inputs.append(new_input)

	var input_data: Dictionary = {
		"player_type": player_type,
		"inputs": inputs,
	}
	
	MenuSignalBus.emit_update_input_buffer(input_data)
