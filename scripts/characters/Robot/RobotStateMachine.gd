extends StateMachine

@onready var player = self.get_parent()
#@onready var spawnHitBox = player.get_node("SpawnHitbox")
var ONE = SGFixed.ONE
#const Hitbox = preload("res://scenes//gameplay//Hitbox.tscn")

func _ready():
	add_state('IDLE')
	add_state('CROUCH')
	add_state('CRAWL')
	add_state('WALK')
	add_state('SPRINT')
	add_state('SLIDE')
	add_state('DASH')
	add_state('JUMPSQUAT')
	add_state('SHORTHOP')
	add_state('FULLHOP')
	add_state('AIRBORNE')
	add_state('BLOCK')
	add_state('LOW_BLOCK')
	add_state('AIR_BLOCK')
	add_state('BLOCKSTUN')
	add_state('LOW_BLOCKSTUN')
	add_state('AIR_BLOCKSTUN')
	add_state('HITSTUN')
	add_state('KNOCKDOWN')
	add_state('QGETUP')
	add_state('DEAD')
	add_state('DISABLED')

	# Normals
	add_state('NEUTRAL_LIGHT')
	add_state('NEUTRAL_MEDIUM')
	add_state('NEUTRAL_HEAVY')
	add_state('NEUTRAL_IMPACT')
	add_state('FORWARD_HEAVY')
	add_state('CROUCHING_LIGHT')
	add_state('CROUCHING_MEDIUM')
	add_state('CROUCHING_HEAVY')
	add_state('CROUCHING_IMPACT')
	add_state('CROUCHING_FORWARD_MEDIUM')
	add_state('AIR_LIGHT')
	add_state('BACK_AIR_LIGHT')
	add_state('AIR_MEDIUM')
	add_state('BACK_AIR_MEDIUM')
	add_state('AIR_HEAVY')
	add_state('BACK_AIR_HEAVY')
	add_state('AIR_IMPACT')
	add_state('BACK_AIR_IMPACT')
	add_state('QCF_LIGHT')
	add_state('QCF_MEDIUM')
	add_state('QCF_HEAVY')

	# Initial State
	#set_state('IDLE')
	set_state('DISABLED')

### Prase Motion Inputs ###
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
### End Parse Motion Inputs ###

func check_buffer_for_attack() -> int:
	var buttons = [player.Buttons.light, player.Buttons.medium, player.Buttons.heavy, player.Buttons.impact] # in order of priority
	for i in buttons:
		if player.inputBuffer & i:
			return i
	return -1

func check_input(input: int) -> int:
	var buttons = [player.Buttons.light, player.Buttons.medium, player.Buttons.heavy, player.Buttons.impact] # in order of priority
	for i in buttons:
		if input & i:
			return i
	return -1

func neutral_attack(attack: int) -> String:
	# TODO: motion input for qcf_light
	if attack != -1:
		if not player.pressed & attack:
			player.pressed += attack
			return "neutral_" + player.ReverseButtons[attack]
	return ""

func crouching_attack(attack: int) -> String:
	if attack != -1 and !player.pressed & attack:
		player.pressed += attack
		if player.input_vector.x != 0:
			player.facingRight = player.input_vector.x > 0
			if attack == player.Buttons.medium:
				return "crouching_forward_medium"
		else:
			return "crouching_" + player.ReverseButtons[attack]
	return ""

func qcf_attack(attack: int) -> String:
	if attack != -1 and !player.pressed & attack:
		player.pressed += attack
		return "qcf_" + player.ReverseButtons[attack]
	return ""

func forward_attack(attack: int) -> String:
	if attack == player.Buttons.heavy: # forward heavy is the only forward attack
		if not player.pressed & attack:
			player.pressed += attack
			return "forward_heavy"
		else:
			return ""
	else: # forward light and medium are the same as neutral light and medium
		return neutral_attack(attack)

func air_attack(attack: int) -> String:
	if attack != -1 and !player.pressed & attack:
		player.pressed += attack
		if player.input_vector.x == 0:
			return "air_" + player.ReverseButtons[attack]
		elif player.input_vector.x > 0 == player.facingRight:
			return "air_" + player.ReverseButtons[attack]
		else:
			return "back_air_" + player.ReverseButtons[attack]
	return ""

func any_attack(attack: int) -> String:
	var motionInput = parse_motion_inputs()
	if attack != -1:
		if player.isOnFloor:
			if (player.facingRight and motionInput == 236) or (!player.facingRight and motionInput == 214):
				return qcf_attack(attack)
			elif player.input_vector.y == -1:
				return crouching_attack(attack)
			elif player.input_vector.x != 0:
				return forward_attack(attack)
			else:
				return neutral_attack(attack)
		else:
			return air_attack(attack)
	return ""

func get_attack_button(input: int) -> int:
	if input & player.Buttons.light:
		return player.Buttons.light
	elif input & player.Buttons.medium:
		return player.Buttons.medium
	elif input & player.Buttons.heavy:
		return player.Buttons.heavy
	elif input & player.Buttons.impact:
		return player.Buttons.impact
	else:
		return -1

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
	player.sprite.flip_h = !player.facingRight

	# TODO: parse_motion_inputs should only get called when we need to look for a possible motion input rahter thanevery frame
	# if buffer_has("light"): # enable to only check when light gets pressed, also for debugging, otherwise checks every frame, this is inefficient
	parse_motion_inputs()

	# can currently almost *always* dash, this will work for now but there will later be states where you cannot
	if player.inputBuffer & player.Buttons.dash and not player.isOnFloor and player.meterVal > 0:
		# TODO: scaling meter cost the first dash costs one meter - when you hit the floor it resets - if you don't hit the floor the dash increases every other +1 
		start_dash(player.input_vector)

	# ## DEBUG for HITSTOP
	# if input.get("shield", false):
	# 	#player.apply_hitstop(0.075)
	# 	player.frame = 0
	# 	player.hitstunFrames = 30
	# 	player.apply_knockback(40 * ONE, SGFixed.mul(SGFixed.PI_DIV_4, 7*ONE))
	# 	player.isOnFloor = false
	# 	set_state('HITSTOP')
	
	if player.health <= 0 and not state == 'DEAD' and not state == 'DISABLED':
		player.is_dead = true
		set_state('DEAD')
	elif MatchData.player_control_disabled and not player.is_dead:
		player.is_disabled = true
		set_state('DISABLED')
	elif player.hurtboxCollision.size() > 0 and !player.involnrable:
		do_hit()


	#################
	# State Changes #
	#################
	match states[state]:
		states.IDLE:
			do_decerlerate(player.groundDeceleration)
			if do_attack(any_attack(check_buffer_for_attack())):
				pass
			elif player.input_vector.y == -1:
				player.animation.play("Crouch")
				set_state('CROUCH')
			elif player.inputBuffer & player.Buttons.shield:
				player.blockMask = 6 # 110
				player.animation.play("Block")
				set_state("BLOCK")
			elif player.input_vector.x != 0:
				# Update which direction the character is facing
				player.facingRight = player.input_vector.x > 0

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
			if jump_check():
				# The player is attempting to jump
				start_jump()
		states.CROUCH:
			do_decerlerate(player.groundDeceleration)
			if do_attack(any_attack(check_buffer_for_attack())):
				pass
			elif player.input_vector.y != -1:
				player.animation.play("Stand")
				player.animation.queue("Idle")
				set_state('IDLE')
			elif player.inputBuffer & player.Buttons.shield:
				player.blockMask = 6 # 110
				# player.animation.play("LowBlock") # TODO: add low block animation
				player.animation.play("LowBlocking")
				set_state("LOW_BLOCK")

			if player.input_vector.x != 0:
				player.facingRight = player.input_vector.x > 0
				do_walk(player.crawlSpeed, player.crawlAcceleration)
				player.animation.play("Crawl")
				set_state('CRAWL')
		states.CRAWL:
			if do_attack(any_attack(check_buffer_for_attack())):
				pass
			elif player.inputBuffer & player.Buttons.shield:
				player.blockMask = 3 # 011
				# player.animation.play("LowBlock") # TODO: add low block animation
				player.animation.play("LowBlocking")
				set_state("LOW_BLOCK")
			elif player.input_vector.y != -1:
				player.animation.play("Idle")
				set_state('IDLE')
			elif player.input_vector.x != 0:
				player.facingRight = player.input_vector.x > 0
				do_walk(player.crawlSpeed, player.crawlAcceleration)
			else:
				player.velocity.x = 0
				player.animation.play("Crouching")
				set_state('CROUCH')

			if jump_check():
				start_jump()
		states.WALK:
			if do_attack(any_attack(check_buffer_for_attack())):
				pass
			elif player.input_vector.y == -1:
				player.animation.play("Crouch")
				set_state('CROUCH')
			elif player.inputBuffer & player.Buttons.shield:
				player.blockMask = 6 # 110
				player.animation.play("Block")
				set_state("BLOCK")
			elif player.input_vector.x != 0:
				# Face the direction based on where you are trying to move
				player.facingRight = player.input_vector.x > 0

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
			if jump_check():
				start_jump()
		states.SLIDE:
			if do_attack(any_attack(get_attack_button(player.inputBuffer))):
				pass
			if jump_check():
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
			if do_attack(any_attack(check_buffer_for_attack())):
				pass
			if player.inputBuffer & player.Buttons.shield:
				player.blockMask = 6 # 110
				player.animation.play("Block")
				set_state("BLOCK")
			elif player.input_vector.y == -1:
				player.animation.play("Crouch")
				set_state('CROUCH')
			elif player.input_vector.x != 0:
				player.facingRight = player.input_vector.x > 0
				do_walk(player.sprintSpeed, player.sprintAcceleration)
			elif player.input_vector.y == -1:
				player.velocity.x = 0
				player.animation.play("Crawl")
				set_state('CRAWL')
			else:
				player.animation.play("Idle")
				set_state('IDLE')

			if jump_check():
				start_jump()
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
		states.JUMPSQUAT:
			# Increment timer for the frames
			player.frame += 1
			if player.isOnFloor:
			# Stopped jumping before it would be fullhop, it turns into shorthop
				if !jump_check():
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
				if jump_check() and player.airJump > 0:
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
			if do_attack(air_attack(check_buffer_for_attack())):
				pass
			elif player.inputBuffer & player.Buttons.shield:
				player.animation.play("AirBlock")
				player.blockMask = 7 # 111, no high/lows in the air
				set_state("AIR_BLOCK")
		states.BLOCK:
			do_decerlerate(player.groundDeceleration)
			if player.input_vector.x != 0:
				player.facingRight = player.input_vector.x > 0
			if !player.inputBuffer & player.Buttons.shield:
				player.animation.play("Unblock")
				player.blockMask = 0 # 000
				player.animation.queue("Idle")
				set_state("IDLE")
			elif player.input_vector.y == -1:
				player.animation.play("BlockCrouch")
				player.blockMask = 3 # 011
				set_state("LOW_BLOCK")
			elif jump_check():
				player.blockMask = 0 # 000
				start_jump()
		states.LOW_BLOCK:
			do_decerlerate(player.groundDeceleration)
			player.animation.play("LowBlocking")
			if player.input_vector.x != 0:
				player.facingRight = player.input_vector.x > 0
			if !player.inputBuffer & player.Buttons.shield:
				player.animation.play("LowUnblock")
				player.animation.queue("Crouching")
				player.blockMask = 0 # 000
				set_state("CROUCH")
			elif player.input_vector.y != -1:
				player.animation.play("BlockStand")
				player.animation.queue("Blocking")
				player.blockMask = 6 # 110
				set_state("BLOCK")
			elif jump_check():
				player.blockMask = 0 # 000
				start_jump()
		states.AIR_BLOCK:
			if !player.inputBuffer & player.Buttons.shield:
				player.animation.play("AirUnblock")
				player.animation.queue("Airborne")
				player.blockMask = 0 # 000
				set_state("AIRBORNE")
			elif player.isOnFloor:
				# TODO: LANDING
				player.blockMask = 6 # 011
				player.animation.play("Block")
				set_state('BLOCK')
			elif jump_check() and player.airJump > 0:
				player.blockMask = 0 # 000
				start_jump()
		states.BLOCKSTUN:
			do_decerlerate(player.groundDeceleration)
			if player.frame >= player.blockstunFrames:
				player.blockstunFrames = 0
				player.frame = 0
				player.animation.play("Blocking")
				set_state('BLOCK')
			else:
				if player.frame >= player.blockstunFrames - 3:
					player.animation.play("BlockstunEnd")
				else:
					player.animation.play("Blockstun")
				player.frame += 1
		states.LOW_BLOCKSTUN:
			do_decerlerate(player.groundDeceleration)
			if player.frame >= player.blockstunFrames:
				player.blockstunFrames = 0
				player.frame = 0
				player.animation.play("LowBlocking")
				set_state('LOW_BLOCK')
			else:
				if player.frame >= player.blockstunFrames - 3:
					player.animation.play("LowBlockstunEnd")
				else:
					player.animation.play("LowBlockstun")
				player.frame += 1
		states.AIR_BLOCKSTUN:
			if player.frame >= player.blockstunFrames:
				player.blockstunFrames = 0
				player.frame = 0
				player.animation.play("AirBlock")
				set_state('AIR_BLOCK')
			else:
				if player.frame >= player.blockstunFrames - 3:
					player.animation.play("AirBlockstunEnd")
				else:
					player.animation.play("AirBlockstun")
				player.frame += 1
		# states.HITSTOP:
		# 	if player.frame >= 100: # TODO: set frame variable
		# 		player.frame = 0
		# 		player.animation.play()
		# 		player.velocity.x = player.prevVelocity.x
		# 		player.velocity.y = player.prevVelocity.y
		# 		set_state('HITSTUN')
		# 	elif player.frame == 0:
		# 		player.frame += 1
		# 		player.prevVelocity.x = player.velocity.x
		# 		player.prevVelocity.y = player.velocity.y
		# 		player.velocity = SGFixed.vector2(0, 0)
		# 		player.animation.pause()
		# 		# TODO: pause and unpause stage timer
		# 	else:
		# 		player.velocity = SGFixed.vector2(0, 0)
		# 		player.frame += 1
		states.HITSTUN:
			#set_state('KNOCKDOWN')
			if player.frame >= player.hitstunFrames:
				player.hitstunFrames = 0
				set_state('AIRBORNE')
			else:
				player.frame += 1
				if player.isOnWallL or player.isOnWallR:
					if player.changedVelocity == false and (abs(player.wallBounceVelocity.x/ONE) > player.wallBounceThreshold):
						player.velocity.x = -player.wallBounceVelocity.x
						player.changedVelocity = true
						player.hitstop = 10 # hitstop for wallbounce
				if player.frame >= player.hitstunFrames - 3:
					if player.isOnFloor:
						player.animation.play("HitstunEnd")
					elif player.velocity.y < 0:
						player.animation.play("AirHitstunEnd")
				else:
					if player.isOnFloor:
						player.animation.play("Hitstun")
					elif player.velocity.y < 0:
						player.animation.play("AirHitstun")

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
			if input.get("dash", false) and player.meterVal > 1:
				# TODO: interrupt animation with dash
				player.meterVal -= 1
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
			if player.is_dead and not player.is_disabled:
				player.armg = 3
				player.num_lives -= 1
				player.velocity.x = 0
				player.velocity.y = 0
				#print("[COMBAT] " + str(player.name) + " has been KO'd!")
				#print("[COMBAT] " + player.name + "'s lives: " + str(player.num_lives))
				player.is_dead = false
				MatchData._update_winners(player.name)
				MatchSignalBus.emit_round_stop()
		states.DISABLED:
			player.velocity.x = 0
			player.velocity.y = 0
			player.animation.play("Idle")
			if not MatchData.player_control_disabled:
				player.is_disabled = false
				#print("[SYSTEM][COMBAT] " + player.name +"'s controls enabled")
				set_state('IDLE')
		states.NEUTRAL_LIGHT:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("neutral_light")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.NEUTRAL_MEDIUM:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("neutral_medium")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.NEUTRAL_HEAVY:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("neutral_heavy")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.NEUTRAL_IMPACT:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("neutral_impact")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.FORWARD_HEAVY:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("forward_heavy")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.CROUCHING_LIGHT:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("crouching_light")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.CROUCHING_MEDIUM:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("crouching_medium")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.CROUCHING_HEAVY:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("crouching_heavy")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.CROUCHING_FORWARD_MEDIUM:
			if player.hitbox.active:
				player.velocity.x = player.advancingLowSpeed if player.facingRight else -player.advancingLowSpeed
			else:
				player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("crouching_forward_medium")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.CROUCHING_IMPACT:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("crouching_impact")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.AIR_LIGHT:
			if player.hitstopBuffer:
				do_hitstop_buffer("air_light")
			#SyncManager.play_sound(str(get_path()) + ":neutral_impact", player.boom, player.boomINFO)
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.BACK_AIR_LIGHT:
			if player.hitstopBuffer:
				do_hitstop_buffer("back_air_light")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.AIR_MEDIUM:
			if player.hitstopBuffer:
				do_hitstop_buffer("air_medium")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.BACK_AIR_MEDIUM:
			if player.hitstopBuffer:
				do_hitstop_buffer("back_air_medium")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.AIR_HEAVY:
			if player.hitstopBuffer:
				do_hitstop_buffer("air_heavy")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.BACK_AIR_HEAVY:
			if player.hitstopBuffer:
				do_hitstop_buffer("back_air_heavy")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.AIR_IMPACT:
			if player.hitstopBuffer:
				do_hitstop_buffer("air_impact")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.BACK_AIR_IMPACT:
			if player.hitstopBuffer:
				do_hitstop_buffer("back_air_impact")
			elif player.frame == -1:
				player.frame = 0
				set_actionable_state()
		states.QCF_LIGHT:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("qcf_light")
			elif player.frame == player.attacks["qcf_light"]["spawnDelay"]:
				SyncManager.spawn("Projectile", player.get_node("Projectiles"), player.projectile, player.attacks["qcf_light"])
				player.frame += 1
			elif player.frame == player.attacks["qcf_light"]["castTime"]:
				player.frame = 0
				set_actionable_state()
			else:
				player.frame += 1
		states.QCF_MEDIUM:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("qcf_medium")
			elif player.frame == player.attacks["qcf_medium"]["spawnDelay"]:
				SyncManager.spawn("Projectile", player.get_node("Projectiles"), player.projectile, player.attacks["qcf_medium"])
				player.frame += 1
			elif player.frame == player.attacks["qcf_medium"]["castTime"]:
				player.frame = 0
				set_actionable_state()
			else:
				player.frame += 1
		states.QCF_HEAVY:
			player.velocity.x = 0
			if player.hitstopBuffer:
				do_hitstop_buffer("qcf_heavy")
			elif player.frame == player.attacks["qcf_heavy"]["spawnDelay"]:
				SyncManager.spawn("Projectile", player.get_node("Projectiles"), player.projectile, player.attacks["qcf_heavy"])
				player.frame += 1
			elif player.frame == player.attacks["qcf_heavy"]["castTime"]:
				player.frame = 0
				set_actionable_state()
			else:
				player.frame += 1

	# Updating input buffer
	update_input_buffer(player.input_vector)

func do_hitstop_buffer(attack_name: String) -> void:
	var properties = player.attacks[attack_name]
	if properties["cancelable"]["jump"]:
		if player.hitstopBuffer & player.Buttons.up: # still don't have input vecotor here
			start_jump()
		
	var attack = any_attack(get_attack_button(player.inputBuffer)) # check for [TODO: valid] buffered attack
	if attack in properties["cancelable"]["moves"]: # TODO: not handling attack type cancels, only jump and by name
		player.frame = 0
		player.hitbox.disabled = true
		do_attack(attack)
	
# checks the current inputs and floor and sets the player's state
func set_actionable_state():
	if player.isOnFloor:
		if player.input_vector.x != 0:
			if player.input_vector.y == -1:
				player.facingRight = player.input_vector.x > 0
				do_walk(player.crawlSpeed, player.crawlAcceleration)
				player.animation.play("Crawl")
				set_state('CRAWL')
			else:
				if sprint_check(player.input):
					do_walk(player.sprintSpeed, player.sprintAcceleration)
					player.animation.play("Sprint")
					set_state('SPRINT')
				else:
					do_walk(player.walkSpeed, player.walkAcceleration)
					player.animation.play("Walk")
					set_state('WALK')
		else:
			if player.input_vector.y == -1:
				player.animation.play("Crouching")
				set_state('CROUCH')
			else:
				player.animation.play("Idle")
				set_state('IDLE')
	else:
		player.animation.play("Airborne")
		set_state('AIRBORNE')

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
	if !player.pressed & player.Buttons.jump and !player.pressed & player.Buttons.up:
		# player.pressed += player.Buttons.jump
		player.pressed += player.Buttons.up
		if player.isOnFloor:
			player.animation.play("Jumpsquat")
		else:
			player.animation.play("AirJumpsquat")
			player.airJump -= 1
		set_state('JUMPSQUAT')

func update_pressed(input: int = -1) -> void:
	if input == -1:
		player.pressed &= player.inputBuffer
	else:
		player.pressed &= input

func start_dash(input_vector):
	if !player.pressed & player.Buttons.dash:
		player.pressed += player.Buttons.dash
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
			
		if player.isOnFloor:
			if not player.last_dash_on_floor:
				player.dash_meter_cost = 1
				#print("Player touched the floor. Dash meter cost reset to:", player.dash_meter_cost)
			player.last_dash_on_floor = true
		else:
			if player.last_dash_on_floor:
				player.dash_meter_cost += 1
				#print("Player has not touched the floor since last dash. Dash meter cost increased to:", player.dash_meter_cost)
			player.last_dash_on_floor = false

		# Transition to the DASH state
		if player.meterVal >= player.dash_meter_cost:
			player.meterVal -= player.dash_meter_cost
			# Transition to the DASH state
			player.velocity.x = 0
			player.velocity.y = 0
			player.animation.play(player.dash_animaiton_map.get([input_vector.x, input_vector.y], "DashR"))
			set_state('DASH')
			#print("Dash initiated. Current meter value:", player.meterVal)

func jump_check() -> bool: # might be redundant
	# this if statement might be fucked but I can't tell
	if player.input_vector.y == 1: # or player.hitstopBuffer & 8:
		return true
	else:
		return false

func sprint_check(input) -> bool:
	# if a direction is double tapped, the player sprints, no more than sprintInputLeinency frames between taps
	if input & player.Buttons.sprint:
		return true
	elif player.controlBuffer.size() > 3: # if the top of the buffer hold a direction, then neutral, then the same direction, the player sprints
		if player.controlBuffer[0][2] < player.sprintInputLeinency and player.controlBuffer[1][2] < player.sprintInputLeinency and player.controlBuffer[2][2] < player.sprintInputLeinency:
			if player.controlBuffer[0][0] == player.controlBuffer[2][0] and player.controlBuffer[0][1] == player.controlBuffer[2][1] and player.controlBuffer[1][0] == 0 and player.controlBuffer[1][1] == 0:
				return true
	return false

# Reset the number of jumps you have
func reset_jumps():
	player.airJump = player.maxAirJump

func get_stun_frames(hitboxes: Array, advantage: int) -> int:
	var moveFrames = 0
	for i in range(hitboxes.size()):
		if i == 0:
			continue
		moveFrames += hitboxes[i]["ticks"]
	return moveFrames + advantage

func do_hit():
	player.hitbox.disabled = true
	var sxfIdx : int = player.currentGameFrame % 3
	var sfx : String = "hit" + str(sxfIdx)
	SyncManager.play_sound(str(get_path()) + ":hit", player.sounds[sfx], player.sounds["hitI"])
	# TODO: meter gain
	if player.blockMask & player.hurtboxCollision["onBlock"]["mask"] == player.hurtboxCollision["onBlock"]["mask"]: # if blocked
		var onBlock = player.hurtboxCollision["onBlock"]
		player.frame = 0
		if !player.hurtboxCollision["projectile"]:
			player.blockstunFrames = get_stun_frames(player.hurtboxCollision["hitboxes"], onBlock["adv"])
		else:
			player.blockstunFrames = onBlock["blockstun"]
		if player.opponent.facingRight:
			player.apply_knockback(onBlock["knockback"]["force"], onBlock["knockback"]["angle"])
		else:
			player.apply_knockback(onBlock["knockback"]["force"], SGFixed.PI - onBlock["knockback"]["angle"])
		player.hitstop = onBlock["blockstop"]
		if player.isOnFloor and player.velocity.y < 0: # if blocked on the floor you can't be hit airborne
			player.velocity.y = 0
		match player.blockMask:
			6:
				player.animation.play("Blockstun")
				set_state("BLOCKSTUN")
			3:
				player.animation.play("LowBlockstun")
				set_state("LOW_BLOCKSTUN")
			7:
				player.animation.play("AirBlockstun")
				set_state("AIR_BLOCKSTUN")
	else:
		# TODO: hitstun/knockback/damage scaling
		var onHit = player.hurtboxCollision["onHit"]
		player.take_damage(onHit["damage"])
		do_knockback(onHit["knockback"])
		if !player.hurtboxCollision["projectile"]:
			player.hitstunFrames = get_stun_frames(player.hurtboxCollision["hitboxes"], onHit["adv"]) * 2 # note: doubled for testing
		else:
			player.hitstunFrames = onHit["hitstun"] * 2 # note: doubled for testing
		player.frame = 0
		player.hitstunMultiplier += onHit["gain"]
		player.hitstop = onHit["hitstop"]
		if player.velocity.y < 0:
			player.animation.play("AirHitstun")
		else:
			player.animation.play("Hitstun")
		set_state("HITSTUN")

func do_knockback(knockback: Dictionary): # TODO: static flag does not work
	if knockback["mult"]:
		player.knockbackMultiplier = SGFixed.mul(player.knockbackMultiplier, knockback["gain"] + ONE)
	else:
		player.knockbackMultiplier = player.knockbackMultiplier + knockback["gain"]
	if knockback["static"]:
		if player.opponent.facingRight:
			player.apply_knockback(knockback["force"], knockback["angle"])
		else:
			player.apply_knockback(knockback["force"], SGFixed.PI - knockback["angle"])
	else:
		if player.opponent.facingRight:
			player.apply_knockback(SGFixed.mul(knockback["force"], player.knockbackMultiplier), knockback["angle"])
		else:
			player.apply_knockback(SGFixed.mul(knockback["force"], player.knockbackMultiplier), SGFixed.PI - knockback["angle"])

# Throw attack
func do_attack(attack_name: String):
	if attack_name == "" or !player.hitbox.collisionShape.attacks.has(attack_name):
		return
	# TODO: meter gain on hit
	# TODO: know if an attack landed, we'll need to know if an attack hit for several things

	player.frame = 0
	if !player.hitbox.collisionShape.attacks[attack_name]["projectile"]: # projectile attacks spawn their hitboxes in state
		player.hitbox.do_attack(attack_name)
	player.animation.play(attack_name.to_pascal_case())
	if attack_name in player.sounds:
		SyncManager.play_sound(str(get_path()) + ":" + attack_name, player.sounds[attack_name], 
		player.sounds[attack_name + "I"])
	set_state(attack_name.to_upper())
	# print("state is now " + attack_name.to_upper())

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
		"state": str(state),
		"knockback_multiplier": "%.3f" % (player.knockbackMultiplier / 65536.0),
		"hitstun_multiplier": "%.3f" % (player.hitstunMultiplier / 65536.0),
		"frame": str(player.frame)
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
