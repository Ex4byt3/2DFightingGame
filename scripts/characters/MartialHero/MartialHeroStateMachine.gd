extends StateMachine

@onready var player = self.get_parent()
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
	add_state('SLIDE')
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
		inputString = str(player.directions[input]) + inputString
	return inputString

func parse_motion_inputs():
	var remainingLeinency = player.motionInputLeinency
	var validMotions = []
	# make a dict of only inputs within the last motionInputLeinency ticks
	for control in player.controlBuffer:
		if control[0] != 0 or control[1] != 0: # if the input is not neutral
			validMotions.append([control[0], control[1]]) # add the input to the validMotions list
		remainingLeinency -= control[2] # subtract frames the input was held
		if remainingLeinency <= 0:
			break
	
	var inputString = convert_inputs_to_string(validMotions)
	# print(inputString) # all currently valid inputs

	# // can use custom search to maybe be faster than regex
	var regex = RegEx.new() 
	for motion in player.motion_inputs:
		regex.compile(str(motion)) # compile the regex for the current motion
		if regex.search(inputString) != null: # if any match is found
			print(player.motion_inputs[motion])
			return motion

func transition_state(input):
	# Updating debug label
	update_debug_label(player.input_vector)

	# Update pressed actions
	update_pressed()

	# Handle attacks
	handle_attacks(player.input_vector, input)
	
	# Universal changes
	if states[state] != states.DASH:
		# If not dashing, apply gravity
		player.velocity.y += player.gravity

	if player.isOnFloor:
		reset_jumps()
		
	if player.facingRight:
		player.attackSprite.flip_h = false
		player.arrowSprite.flip_h = false
	else:
		player.attackSprite.flip_h = true
		player.arrowSprite.flip_h = true

	# if input.has("light"): # enable to only check when light gets pressed, also for debugging
	parse_motion_inputs()

	# can currently *always* dash, this will work for now but there will later be states where you cannot
	if input.get("dash", false) and not player.isOnFloor:
		# TODO: scaling meter cost
		start_dash(player.input_vector)

	match states[state]:
		states.IDLE:
			if player.takeDamage:
				set_state('ATTACKED')
			elif player.isOnFloor:
				if player.input_vector.x != 0:
					# Update which direction the character is facing
					if player.input_vector.x > 0:
						player.facingRight = true
					else:
						player.facingRight = false
					
					# Update the direction the character is attempting to walk
					if input.get("sprint_macro", false):
						# If the character is using sprint_macro (default SHIFT) they sprint
						player.velocity.x = player.sprintSpeed * (player.input_vector.x * ONE)
						player.animation.play("Sprint")
						set_state('SPRINT')
					else:
						# If the character isn't and they are moving in a direction, they are walking
						player.velocity.x = player.walkSpeed * (player.input_vector.x * ONE)
						player.animation.play("Walk")
						set_state('WALK')
				elif player.input_vector.x == 0:
					# If the player is not moving left/right, don't move/stop moving
					player.velocity.x = 0
					player.animation.play("Idle")
					set_state('IDLE')
				if jump_check(input):
					# The player is attempting to jump
					start_jump()
			else:
				player.animation.play("Airborne")
				set_state('AIRBORNE')
		states.CROUCH:
			pass
		states.WALK:
			if player.isOnFloor:
				# If you are on the floor and moving, walk/sprint left/right if applicable
				if player.input_vector.x != 0:
					# Face the direction based on where you are trying to move
					if player.input_vector.x > 0:
						player.facingRight = true
					else:
						player.facingRight = false
					
					if input.get("sprint_macro", false) or sprint_check():
						# Sprint if you are trying to sprint
						player.velocity.x = player.sprintSpeed * (player.input_vector.x * ONE)
						player.animation.play("Sprint")
						set_state("SPRINT")
					else:
						# Continue walking if you are trying to walk
						player.velocity.x = player.walkSpeed * (player.input_vector.x * ONE)
						# player.animation.play("Walk")
						# set_state('WALK')
				else:
					player.velocity.x = 0
					player.animation.play("Idle")
					set_state('IDLE')
				if jump_check(input):
					# The player is attempting to jump, enter jumpsquat state
					start_jump()
			else:
				# Not on the ground while walking somehow, you are now airborne, goodluck!
				player.animation.play("Airborne")
				set_state('AIRBORNE')
		states.SLIDE:
			if jump_check(input):
				# The player is attempting to jump
				player.velocity.x = SGFixed.mul(player.velocity.x, player.slideJumpBoost) # boost the player's velocity when they jump out of a slide
				start_jump()

			if player.velocity.x > 0:
				if player.input_vector.x == 1: # if the player is moving with the slide it decays slower, else it dwcays quickly
					player.velocity.x -= player.slideDecay
				else:
					player.velocity.x -= player.slideDecay
				if player.velocity.x < player.sprintSpeed * ONE: # when the player reaches their sprint speed, they start sprinting instead of sliding
					player.velocity.x = player.sprintSpeed * (player.input_vector.x * ONE)
					player.animation.play("Sprint")
					set_state('SPRINT')
			else: # do the same for the other direction
				if player.input_vector.x == -1:
					player.velocity.x += player.slideDecay
				else:
					player.velocity.x += player.slideDecay
				if player.velocity.x > -player.sprintSpeed * ONE:
					player.velocity.x = player.sprintSpeed * (player.input_vector.x * ONE)
					player.animation.play("Sprint")
					set_state('SPRINT')
		states.SPRINT:
			if player.isOnFloor:
				# If you are on the floor and moving, walk/sprint left/right if applicable
				if player.input_vector.x != 0:
					# Face the direction based on where you are trying to move
					if player.input_vector.x > 0:
						player.facingRight = true
					else:
						player.facingRight = false
					
					if input.get("sprint_macro", false) or sprint_check():
						# Sprint if you are trying to sprint
						player.velocity.x = player.sprintSpeed * (player.input_vector.x * ONE)
						player.animation.play("Sprint")
						set_state("SPRINT")
				else:
					player.velocity.x = 0
					player.animation.play("Idle")
					set_state('IDLE')

				if jump_check(input):
					# The player is attempting to jump, enter jumpsquat state
					start_jump()
			else:
				# Not on the ground while walking somehow, you are now airborne, goodluck!
				player.animation.play("Airborne")
				set_state('AIRBORNE')
			pass
		states.DASH:
			if player.isOnFloor: # if you ever hit the floor, you slide
				player.velocity.x = player.keptDashSpeed * player.dashVector.x
				player.velocity.y = player.keptDashSpeed * -player.dashVector.y # player is on the floor, so y velocity is 0
				player.frame = 0
				set_state('SLIDE')
			if player.frame < player.dashDuration:
				player.frame += 1
				pass
			else: # once the dash duration ends
				player.frame = 0
				player.velocity.x = player.keptDashSpeed * player.dashVector.x
				player.velocity.y = player.keptDashSpeed * -player.dashVector.y
				if player.isOnFloor: 
					set_state('SLIDE')
				else:
					player.animation.play("Airborne")
					set_state('AIRBORNE')
		states.JUMP:
			if player.isOnFloor:
				player.animation.play("Idle")
				set_state('IDLE')
			else:
				if player.velocity.y >= 0:
					player.animation.play("Airborne")
					set_state('AIRBORNE')
		states.JUMPSQUAT:
			# Increment timer for the frames
			player.frame += 1
			if player.isOnFloor:
			# Stopped jumping before it would be fullhop, it turns into shorthop
				if player.input_vector.y != 1:
					player.velocity.y = player.shortHopForce
					player.frame = 0
					player.animation.play("Airborne") # can have seperate animation for shothop without seperate state
					set_state('AIRBORNE')
				# Jump has been held for more than 4 frames, fullhop
				if player.frame > player.jumpSquatFrames:
					player.velocity.y = player.fullHopForce
					player.frame = 0
					player.animation.play("Airborne")
					set_state('AIRBORNE')
			else: # air jump
				if player.frame > player.jumpSquatFrames:
					player.velocity.y = player.airHopForce
					player.animation.play("Airborne") # TODO: double jump animation
					set_state('AIRBORNE')
		states.AIRBORNE:
			if player.isOnFloor:
				# TODO: LANDING
				player.animation.play("Idle")
				set_state('IDLE')
			else:
				if jump_check(input) and player.airJump > 0:
					if player.usedJump == false:
						player.airJump -= 1
						start_jump()
			# If in the air and you are moving, update the velocity based on
			# air acceleration and air speed (for air drift implementation)
			if abs(player.velocity.x) > player.maxAirSpeed: # if you are moving faster than max air speed, you may only slow down
				if player.velocity.x > 0:
					if player.input_vector.x == -1:
						player.velocity.x -= SGFixed.mul(player.airAcceleration, (ONE))
				else:
					if player.input_vector.x == 1:
						player.velocity.x += SGFixed.mul(player.airAcceleration, (ONE))
			elif player.input_vector.x != 0:
				player.velocity.x += SGFixed.mul(player.airAcceleration, (player.input_vector.x * ONE))
				if player.velocity.x > player.maxAirSpeed:
					player.velocity.x = player.maxAirSpeed
				elif player.velocity.x < -player.maxAirSpeed:
					player.velocity.x = -player.maxAirSpeed
		states.ATTACKED:
			player.health -= player.damage
			player.damage = 0
			player.takeDamage = false
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
	update_input_buffer(player.input_vector)

func start_jump():
	if player.usedJump == false: # you must let go of the jump button to jump again
		player.usedJump = true
		player.animation.play("JumpSquat")
		set_state('JUMPSQUAT')

func update_pressed(): # will later update any buttons that must be let go of to be pressed again
	if player.input_vector.y != 1:
		player.usedJump = false

func start_dash(input_vector):
	# if the input vector is neutral, dash in the direction the player is facing
	if player.meter >= 5000:
			player.meter -= 5000
			player.dashVector = input_vector.normalized()
			if player.dashVector.x == 0 and player.dashVector.y == 0:
				if player.facingRight:
					player.velocity.x = player.dashSpeed * ONE
				else:
					player.velocity.x = -player.dashSpeed * ONE
				player.velocity.y = 0
			else:
				# if the input vector is not neutral, dash in the direction of the input vector
				player.velocity.x = player.dashSpeed * player.dashVector.x
				player.velocity.y = player.dashSpeed * -player.dashVector.y # up is negative in godot
	else:
		print("Not enough meter to dash")

	# Transition to the DASH state
	player.animation.play("Dash")
	set_state('DASH')
	
func jump_check(input) -> bool:
	if player.input_vector.y == 1 or input.has("jump"):
		return true
	else:
		return false

func sprint_check() -> bool:
	# input buffer has [x, y, ticks] for each input, this will need to expand to [x, y, [button list], ticks] or something of the like later
	# if a direction is double tapped, the player sprints, no more than sprintInputLeinency frames between taps
	if player.controlBuffer.size() > 3: # if the top of the buffer hold a direction, then neutral, then the same direction, the player sprints
		if player.controlBuffer[0][2] < player.sprintInputLeinency and player.controlBuffer[1][2] < player.sprintInputLeinency and player.controlBuffer[2][2] < player.sprintInputLeinency:
			if player.controlBuffer[0][0] == player.controlBuffer[2][0] and player.controlBuffer[0][1] == player.controlBuffer[2][1] and player.controlBuffer[1][0] == 0 and player.controlBuffer[1][1] == 0:
				return true
	return false

# Reset the number of jumps you have
func reset_jumps():
	player.airJump = player.maxAirJump

# TODO: parse input buffer
func handle_attacks(input_vector, input):
	# Because if it is not true it is null, need to add the false argument to default it to false instead of null
	var spawn_position_x = player.fixed_position.x
	
	if player.facingRight:
		spawn_position_x = (55 * ONE)
	else:
		spawn_position_x = -(55 * ONE)
	
	#if input.get("drop_bomb", false):
		#SyncManager.spawn("Bomb", player.get_parent(), Bomb, { 
			#fixed_position_x = player.fixed_position.x,
			#fixed_position_y = player.fixed_position.y 
		#})
	if input.get("attack_light", false):
		if player.get_node("SpawnHitbox").get_child_count() == 0:
			player.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", player.get_node("SpawnHitbox"), Attack_Light, { 
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 1000,
				attacking_player = player.name
			})
	if input.get("attack_medium", false):
		if player.get_node("SpawnHitbox").get_child_count() == 0:
			player.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", player.get_node("SpawnHitbox"), Attack_Light, {
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 2000,
				attacking_player = player.name
			})
	if input.get("attack_heavy", false):
		if player.get_node("SpawnHitbox").get_child_count() == 0:
			player.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", player.get_node("SpawnHitbox"), Attack_Light, {
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 3000,
				attacking_player = player.name
			})
	if input.get("impact", false):
		if player.get_node("SpawnHitbox").get_child_count() == 0:
			player.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", player.get_node("SpawnHitbox"), Attack_Light, {
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 1000,
				attacking_player = player.name
			})
	if input.get("dash", false):
		if player.get_node("SpawnHitbox").get_child_count() == 0:
			player.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", player.get_node("SpawnHitbox"), Attack_Light, {
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 1000,
				attacking_player = player.name
			})
	if input.get("block", false):
		if player.get_node("SpawnHitbox").get_child_count() == 0:
			player.attackAnimationPlayer.play("DebugAttack")
			SyncManager.spawn("Attack_Light", player.get_node("SpawnHitbox"), Attack_Light, {
				fixed_position_x = spawn_position_x,
				fixed_position_y = 0,
				fixed_scale_x = 1 * ONE,
				fixed_scale_y = 1 * ONE,
				fixed_rotation = 0,
				damage = 1000,
				attacking_player = player.name
			})


func update_debug_label(input_vector):
	var player_type: String = self.get_parent().name
	
	var debug_data: Dictionary = {
		"player_type": player_type,
		"pos_x": str(player.fixed_position.x / ONE),
		"pos_y": str(player.fixed_position.y / ONE),
		"velocity_x": str(player.velocity.x / ONE),
		"velocity_y": str(player.velocity.y / ONE),
		"input_vector_x": str(input_vector.x),
		"input_vector_y": str(input_vector.y),
		"state": str(state)
	}
	
	MenuSignalBus.emit_update_debug(debug_data)

	
func update_input_buffer(input_vector):
	var player_type: String = self.get_parent().name
	var inputs: Array = []

	if player.controlBuffer.size() > 20:
		player.controlBuffer.pop_back()
	
	if player.controlBuffer.front()[0] == input_vector.x and player.controlBuffer.front()[1] == input_vector.y:
		var ticks = player.controlBuffer.front()[2]
		player.controlBuffer.pop_front()
		player.controlBuffer.push_front([input_vector.x, input_vector.y, ticks+1])
	else:
		player.controlBuffer.push_front([input_vector.x, input_vector.y, 1])
	
	for item in player.controlBuffer:
		var new_input: Array = []
		new_input.append(str(player.direction_mapping.get([item[0], item[1]], "NEUTRAL")))
		new_input.append(str(item[2]))
		inputs.append(new_input)

	var input_data: Dictionary = {
		"player_type": player_type,
		"inputs": inputs,
	}
	
	MenuSignalBus.emit_update_input_buffer(input_data)
