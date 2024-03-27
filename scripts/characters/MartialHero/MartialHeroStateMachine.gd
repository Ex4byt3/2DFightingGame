extends StateMachine

@onready var player = self.get_parent()
@onready var spawnHitBox = player.get_node("SpawnHitbox")
var ONE = SGFixed.ONE

const Bomb = preload("res://scenes//gameplay//Bomb.tscn")
const Hitbox = preload("res://scenes//gameplay//Hitbox.tscn")

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
	add_state('BLOCK')
	add_state('HITSTOP')
	add_state('HITSTUN')
	add_state('KNOCKDOWN')
	add_state('QGETUP')
	add_state('DEAD')
	add_state('NEUTRAL_LIGHT')
	add_state('NEUTRAL_MEDIUM')
	add_state('NEUTRAL_HEAVY')
	add_state('FORWARD_LIGHT')
	add_state('FORWARD_MEDIUM')
	add_state('FORWARD_HEAVY')
	add_state('DOWN_LIGHT')
	add_state('DOWN_MEDIUM')
	add_state('DOWN_HEAVY')
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
			# print(player.motion_inputs[motion])
			return motion

func transition_state(input):
	update_debug_label(player.input_vector)
	update_pressed()
	
	#####################
	# Universal Changes #
	#####################
	if states[state] != states.DASH:
		# If not dashing, apply gravity
		player.velocity.y += player.gravity

	if player.isOnFloor:
		reset_jumps()

	if player.pushVector.x != 0 or player.pushVector.y != 0:
		player.velocity.x += player.pushVector.x
		player.velocity.y += player.pushVector.y
		# player.pushvector = SGFixed.vector2(0, 0)
		
	# Update the sprite's facing direction
	if player.facingRight:
		player.sprite.flip_h = false
	else:
		player.sprite.flip_h = true

	# if input.has("light"): # enable to only check when light gets pressed, also for debugging, otherwise checks every frame, this is inefficient
	parse_motion_inputs()

	# can currently almost *always* dash, this will work for now but there will later be states where you cannot
	if input.get("dash", false) and not player.isOnFloor:
		# TODO: scaling meter cost
		start_dash(player.input_vector)

	## DEBUG for HITSTOP
	if input.get("shield", false): 
		#player.apply_hitstop(0.075)
		player.frame = 0
		player.hitstun = 30
		player.apply_knockback(40 * ONE, SGFixed.mul(SGFixed.PI_DIV_4, 7*ONE))
		player.isOnFloor = false
		set_state('HITSTOP')

	if player.health <= 0:
		if not player.is_dead:
			set_state('DEAD')
	elif player.hurtboxCollision.size() > 0:
		do_hit()
		set_state('HITSTUN')
	elif input.get("attack_light", false) and player.thrownHits == 0:
		do_attack("neutral_light")
	
	#################
	# State Changes #
	#################
	match states[state]:
		states.IDLE:
			if player.isOnFloor:
				do_decerlerate(player.groundDeceleration)
				if player.input_vector.y == -1:
					player.animation.play("Crouch")
					set_state('CROUCH')
				elif player.input_vector.x != 0:
					# Update which direction the character is facing
					if player.input_vector.x > 0:
						player.facingRight = true
					else:
						player.facingRight = false
					
					# Update the direction the character is attempting to walk
					if sprint_check(input):
						# If the character is using sprint_macro (default SHIFT) they sprint
						do_walk(player.sprintSpeed, player.sprintAcceleration)
						player.animation.play("Sprint")
						set_state('SPRINT')
					else:
						# If the character isn't and they are moving in a direction, they are walking
						do_walk(player.walkSpeed, player.walkAcceleration)
						player.animation.play("Walk")
						set_state('WALK')
				elif player.input_vector.x == 0:
					# If the player is not moving left/right, don't move/stop moving
					#player.velocity.x = 0
					player.animation.play("Idle")
					set_state('IDLE')
				if jump_check(input):
					# The player is attempting to jump
					start_jump()
			else:
				player.animation.play("Airborne")
				set_state('AIRBORNE')
		states.CROUCH:
			if player.input_vector.y != -1:
				player.animation.play("Idle")
				set_state('IDLE')

			if player.input_vector.x != 0:
				if player.input_vector.x > 0:
					player.facingRight = true
				else:
					player.facingRight = false
				do_walk(player.crawlSpeed, player.crawlAcceleration)
				player.animation.play("Crawl")
				set_state('CRAWL')
		states.CRAWL:
			if player.input_vector.y != -1:
				set_state('IDLE')

			if player.input_vector.x != 0:
				if player.input_vector.x > 0:
					player.facingRight = true
				else:
					player.facingRight = false
				do_walk(player.crawlSpeed, player.crawlAcceleration)
			else:
				player.velocity.x = 0
				player.animation.play("Crouching")
				set_state('CROUCH')
		states.WALK:
			if player.isOnFloor:
				# If you are on the floor and moving, walk/sprint left/right if applicable
				if player.input_vector.y == -1:
					player.animation.play("Crouch")
					set_state('CROUCH')
				elif player.input_vector.x != 0:
					# Face the direction based on where you are trying to move
					if player.input_vector.x > 0:
						player.facingRight = true
					else:
						player.facingRight = false
					
					if sprint_check(input):
						# Sprint if you are trying to sprint
						do_walk(player.sprintSpeed, player.sprintAcceleration)
						player.animation.play("Sprint")
						set_state("SPRINT")
					else:
						# Continue walking if you are trying to walk
						do_walk(player.walkSpeed, player.walkAcceleration)
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
					player.velocity.x -= player.slideDecay # TODO: same as in the previous if statement
				if player.velocity.x < player.sprintSpeed: # when the player reaches their sprint speed, they start sprinting instead of sliding
					player.velocity.x = player.sprintSpeed * (player.input_vector.x)
					player.animation.play("Sprint")
					set_state('SPRINT')
			else: # do the same for the other direction
				if player.input_vector.x == -1:
					player.velocity.x += player.slideDecay
				else:
					player.velocity.x += player.slideDecay
				if player.velocity.x > -player.sprintSpeed:
					player.velocity.x = player.sprintSpeed * (player.input_vector.x)
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
					
					if sprint_check(input):
						# Sprint if you are trying to sprint
						do_walk(player.sprintSpeed, player.sprintAcceleration)
						player.animation.play("Sprint")
						set_state("SPRINT")
				elif player.input_vector.y == -1:
					player.velocity.x = 0
					player.animation.play("Crouch")
					set_state('CROUCH')
				else:
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
			if player.frame < player.dashWindup:
				player.frame += 1
			elif player.frame < player.dashDuration:
				player.frame += 1
				player.velocity.x = player.dashSpeed * player.dashVector.x
				player.velocity.y = player.dashSpeed * -player.dashVector.y
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
					player.animation.play("Jump") # can have seperate animation for shothop without seperate state
					set_state('AIRBORNE')
				# Jump has been held for more than 4 frames, fullhop
				if player.frame > player.jumpSquatFrames:
					player.velocity.y = player.fullHopForce
					player.frame = 0
					player.animation.play("Jump")
					set_state('AIRBORNE')
			else: # air jump
				if player.frame > player.jumpSquatFrames:
					player.velocity.y = player.airHopForce
					player.animation.play("AirJump")
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
				if player.velocity.y > 0:
					player.animation.play("Airborne")
			# If in the air and you are moving, update the velocity based on
			# air acceleration and air speed (for air drift implementation)
			if abs(player.velocity.x) > player.maxAirSpeed: # if you are moving faster than max air speed, you may only slow down
				if player.velocity.x > 0:
					if player.input_vector.x == -1:
						player.velocity.x -= player.airAcceleration
				else:
					if player.input_vector.x == 1:
						player.velocity.x += player.airAcceleration
			elif player.input_vector.x != 0:
				player.velocity.x += player.input_vector.x * player.airAcceleration
				if player.velocity.x > player.maxAirSpeed:
					player.velocity.x = player.maxAirSpeed
				elif player.velocity.x < -player.maxAirSpeed:
					player.velocity.x = -player.maxAirSpeed
		states.NEUTRAL_LIGHT:
			# currently stops all movement while the attack is happening
			player.velocity.x = 0
			if player.recovery:
				# TODO: add recovery frames/cancel logic
				pass
			elif player.attack_ended:
				player.attack_ended = false
				set_state('IDLE')
		states.BLOCK:
			pass
		states.HITSTOP:
			if player.frame >= 100: # TODO: set frame variable
				player.frame = 0
				player.animation.play()
				player.velocity.x = player.prevVelocity.x
				player.velocity.y = player.prevVelocity.y
				set_state('HITSTUN')
			elif player.frame == 0:
				player.frame += 1
				player.prevVelocity.x = player.velocity.x
				player.prevVelocity.y = player.velocity.y
				player.velocity = SGFixed.vector2(0, 0)
				player.animation.pause()
				# TODO: pause and unpause stage timer
			else:
				player.velocity = SGFixed.vector2(0, 0)
				player.frame += 1
		states.HITSTUN:
			#set_state('KNOCKDOWN')
			if player.frame >= player.hitstun:
				player.hitstun = 0
				set_state('AIRBORNE')
			else:
				player.frame += 1
				
				if player.isOnWallL or player.isOnWallR:
					if player.changedVelocity == false and (abs(player.wallBounceVelocity.x/ONE) > player.wallBounceThreshold):
						player.velocity.x = -player.wallBounceVelocity.x
						player.changedVelocity = true
					#print("WALL")
				# NOT IMPLEMENTED YET
				# Expects player.frame to be set beforehand.
				# if player.isOnFloor:
				# 	if prevVelocity >= player.knockdownVelocity: 
				# 		player.frame = 0
				# 		player.velocity = SGFixed.vector2(0, 0)
				# 		set_state('KNOCKDOWN')
				# 	else: # Enter Hitstun slide
				# 		if player.velocity.x == 0 or player.frame == 0: # exit Hitstun slide
				# 			player.frame = 0
				# 			set_state('IDLE')
				# 		# Mimic slide during Hitstun
				# 		player.frame -= 1
				# 		if player.velocity.x > 0:
				# 			player.velocity.x -= player.slideDecay
				# 			if player.velocity.x < 0:
				# 				player.velocity.x = 0
				# 		else: # if velocity < 0
				# 			player.velocity.x += player.slideDecay
				# 			if player.velocity.x > 0:
				# 				player.velocity.x = 0
				# elif player.frame > 0:
				# 	prevVelocity = player.velocity.length() # Velocity before hitting floor
				# 	player.frame -= 1
				# else:
				# 	player.frame = 0
				# 	set_state('AIRBORNE')
		states.KNOCKDOWN:
			# TODO: add invulnerability when damage is finished
			if player.input_vector.y > 0:
				# if press up, quick get up facing your current direction
				player.frame = player.quickGetUpFrames
				set_state('QGETUP')
			elif player.input_vector.x != 0:
				# if press L/R, quick get up facing that direction
				player.facingRight = player.input_vector.x > 0
				player.frame = player.quickGetUpFrames
				set_state('QGETUP')
			elif input.get("light", false):
				# if press certain attacks, perform reversal
				# TODO: add reversal get up attack once attacks are added
				pass
		states.QGETUP:
			# Expects player.frame to be set beforehand
			# Quick get up from knockdown facing the current direction
			# Can be interrupted with a dash
			if input.get("dash", false):
				# TODO: interrupt animation with dash
				player.frame = 0
				if player.facingRight:
					start_dash(SGFixed.vector2(ONE, 0))
				else:
					start_dash(SGFixed.vector2(-ONE, 0))
			elif player.frame <= 0:
				# quick get up complete without dashing, exit into idle
				player.frame = 0
				set_state('IDLE')
			else:
				player.frame -= 1
		states.DEAD:
			player.is_dead = true
			player.num_lives -= 1
			print("[COMBAT] " + str(player.name) + " has been KO'd!")
			MenuSignalBus.emit_round_over()
			MenuSignalBus.emit_update_lives(player.num_lives, player.name)
			print("[COMBAT] " + player.name + "'s lives: " + str(player.num_lives))
		states.NEUTRAL_MEDIUM:
			pass
		states.NEUTRAL_HEAVY:
			pass
		states.FORWARD_LIGHT:
			pass
		states.FORWARD_MEDIUM:
			pass
		states.FORWARD_HEAVY:
			pass
		states.DOWN_LIGHT:
			pass
		states.DOWN_MEDIUM:
			pass
		states.DOWN_HEAVY:
			pass
	# Updating input buffer
	update_input_buffer(player.input_vector)

func do_decerlerate(deceleration):
	if player.velocity.x > 0:
		player.velocity.x -= deceleration
		if player.velocity.x < 0:
			player.velocity.x = 0
	elif player.velocity.x < 0:
		player.velocity.x += deceleration
		if player.velocity.x > 0:
			player.velocity.x = 0

func do_walk(speed, acceleration):
	if player.input_vector.x > 0:
		if player.velocity.x < speed:
			player.velocity.x += acceleration
		else:
			player.velocity.x = speed
	elif player.input_vector.x < 0:
		if player.velocity.x > -speed:
			player.velocity.x -= acceleration
		else:
			player.velocity.x = -speed

func start_jump():
	if player.usedJump == false: # you must let go of the jump button to jump again
		player.usedJump = true
		# update facing direction
		# if player.input_vector.x != 0:
		# 	if player.input_vector.x > 0:
		# 		player.facingRight = true
		# 	else:
		# 		player.facingRight = false

		if player.isOnFloor:
			player.animation.play("JumpSquat")
		else:
			pass
			# player.animation.play("AirJumpSquat") # TODO: add air jump squat animation

		set_state('JUMPSQUAT')

func update_pressed(): # note: will later update any buttons that must be let go of to be pressed again, currently only jump
	if player.input_vector.y != 1:
		player.usedJump = false

func start_dash(input_vector):
	# if the input vector is neutral, dash in the direction the player is facing
	player.dashVector = input_vector.normalized()
	if player.dashVector.x == 0 and player.dashVector.y == 0:
		if player.facingRight:
			player.dashVector.x = ONE
		else:
			player.dashVector.x = -ONE

	if input_vector.x != 0:
		# Update which direction the character is facing
		if input_vector.x > 0:
			player.facingRight = true
		else:
			player.facingRight = false

	# Transition to the DASH state
	player.velocity.x = 0
	player.velocity.y = 0
	player.animation.play(player.dash_animaiton_map.get([input_vector.x, input_vector.y], "DashR"))
	set_state('DASH')
	
func jump_check(input) -> bool:
	if player.input_vector.y == 1 or input.has("jump"):
		return true
	else:
		return false

func sprint_check(input) -> bool:
	# if a direction is double tapped, the player sprints, no more than sprintInputLeinency frames between taps
	if input.get("sprint_macro", false):
		return true
	elif player.controlBuffer.size() > 3: # if the top of the buffer hold a direction, then neutral, then the same direction, the player sprints
		if player.controlBuffer[0][2] < player.sprintInputLeinency and player.controlBuffer[1][2] < player.sprintInputLeinency and player.controlBuffer[2][2] < player.sprintInputLeinency:
			if player.controlBuffer[0][0] == player.controlBuffer[2][0] and player.controlBuffer[0][1] == player.controlBuffer[2][1] and player.controlBuffer[1][0] == 0 and player.controlBuffer[1][1] == 0:
				return true
	return false

# Reset the number of jumps you have
func reset_jumps():
	player.airJump = player.maxAirJump

func do_hit():
	player.take_damage(player.hurtboxCollision.damage)
	player.apply_knockback(player.hurtboxCollision.knockbackForce, player.hurtboxCollision.knockbackAngle)
	player.hitstun = player.hurtboxCollision.hitstun
	player.frame = 0

func do_attack(attack_type: String):
	# Throw attack
	SyncManager.spawn("Hitbox", player.get_node("SpawnHitbox"), Hitbox, {
		damage = spawnHitBox.get_damage(attack_type),
		hitboxShapes = spawnHitBox.get_hitbox_shapes(attack_type),
		knockbackForce = spawnHitBox.get_knockback(attack_type)["force"],
		knockbackAngle = spawnHitBox.get_knockback(attack_type)["angle"],
		hitstun = spawnHitBox.get_hitstun(attack_type)
	})
	player.thrownHits += 1 # Increment number of thrown attacks
	
	match attack_type:
		"neutral_light":
			player.attackAnimationPlayer.play("DebugAttack")
			set_state('NEUTRAL_LIGHT')
		"neutral_medium":
			pass
		"neutral_heavy":
			pass
		"forward_light":
			pass
		"forward_medium":
			pass
		"forward_heavy":
			pass
		"down_light":
			pass
		"down_medium":
			pass
		"down_heavy":
			pass
	

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

# input buffer has [x, y, ticks] for each input
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
