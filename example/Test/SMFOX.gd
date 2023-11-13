extends StateMachine
onready var id = parent.id
var l_cancel:bool

func _ready():
	add_state('STAND')
	add_state('JUMP_SQUAT')
	add_state('FULL_HOP')
	add_state('SHORT_HOP')
	add_state('MOONWALK')
	add_state('DASH')
	add_state('RUN')
	add_state('WALK')
	add_state('TURN')
	add_state('CROUCH')
	add_state('AIR')
	add_state('FREE_FALL')
	add_state('AIR_DODGE')
	add_state("LANDING")
	add_state('LEDGE_CATCH')
	add_state('LEDGE_HOLD')
	add_state('LEDGE_CLIMB')
	add_state('LEDGE_JUMP')
	add_state('LEDGE_ROLL')
	add_state('HITSTUN')
	add_state('HITFREEZE')
	add_state('TUMBLE')
	add_state('PARRY')
	add_state('ROLL_RIGHT')
	add_state('ROLL_LEFT')
	add_state('TECH')
	add_state('TECH_GROUND')
	add_state('TECH_FORWARD')
	add_state('TECH_BACKWARD')
	add_state('GROUND_ATTACK')
	add_state("UP_TILT") #could make it so that uptilt code is stored
#in players own script and returns a true value when carried out
	add_state('DOWN_TILT')
	add_state('FORWARD_TILT')
	add_state('JAB')
	add_state('JAB_1')
	add_state('SPECIAL')
	add_state('DOWN_SPECIAL')
	add_state('FORWARD_SPECIAL')
	add_state('NEUTRAL_SPECIAL')
	add_state('UP_SPECIAL')
	add_state('UP_SPECIAL_1')
	add_state('AIR_ATTACK')
	add_state('NAIR')
	add_state('UAIR')
	add_state('BAIR')
	add_state('FAIR')
	add_state('DAIR')
	add_state('SMASH_ATTACK')
	add_state('DOWN_SMASH')
	add_state('DOWN_SMASH_1')
	add_state('UP_SMASH')
	add_state('UP_SMASH_1')
	add_state('FORWARD_SMASH')
	add_state('FORWARD_SMASH_1')
	add_state('RESPAWN')
	add_state('DEAD')
	call_deferred("set_state", states.STAND)

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)
	if parent.regrab > 0:
		parent.regrab-=1
	
func get_transition(delta):
	parent.move_and_slide_with_snap(parent.velocity*2,Vector2.ZERO,Vector2.UP)

	if Landing() == true:
		parent.frame()
		return states.LANDING

	if Falling() == true:
		return states.AIR

	if Ledge() == true:
		print ("Connecting")
		parent.frame()
		return states.LEDGE_CATCH
	else:
		parent.reset_ledge()

	if Input.is_action_just_pressed("attack_%s" % id) && AIREAL() == true:
			if Input.is_action_pressed("up_%s" % id):
				parent.frame()
				return states.UAIR
			if Input.is_action_pressed("down_%s" % id):
				parent.frame()
				return states.DAIR
			match parent.direction():
				1:
					if Input.is_action_pressed("left_%s" % id):
						parent.frame()
						return states.BAIR
					if Input.is_action_pressed("right_%s" % id):
						parent.frame()
						return states.FAIR
				-1:
					if Input.is_action_pressed("right_%s" % id):
						parent.frame()
						return states.BAIR
					if Input.is_action_pressed("left_%s" % id):
						parent.frame()
						return states.FAIR
			parent.frame()
			return states.NAIR

	if Input.is_action_just_pressed("shield_%s" % id) && !AIREAL() && parent.cooldown == 0:
		parent.l_cancel = 11
		parent.cooldown = 40
		print ("presses l cancel")
	if Input.is_action_just_pressed("attack_%s" % id) && TILT() == true:
		parent.frame()
		return states.GROUND_ATTACK

	match state:
		states.STAND:
			parent.reset_Jumps()
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if Input.is_action_pressed("down_%s" % id):
				parent.frame()
				return states.CROUCH
			if Input.get_action_strength("right_%s" % id) == 1:
				parent.velocity.x = parent.RUNSPEED
				parent.frame()
				parent.turn(false)
				return states.DASH
			if Input.get_action_strength("left_%s" % id) == 1:
				parent.velocity.x = -parent.RUNSPEED
				parent.frame()
				parent.turn(true)
				return states.DASH
			if parent.velocity.x > 0 and state == states.STAND:
				parent.velocity.x += -parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)

		states.JUMP_SQUAT:
			if parent.frame == parent.jump_squat:
				if (Input.is_action_pressed("shield_%s" % id)) and (Input.is_action_pressed("left_%s" % id) or Input.is_action_pressed("right_%s" % id)):
					if Input.is_action_pressed("right_%s" % id):
						parent.velocity.x = parent.air_dodge_speed/parent.perfect_wavedash_modifier
					if Input.is_action_pressed("left_%s" % id):
						parent.velocity.x = -parent.air_dodge_speed/parent.perfect_wavedash_modifier
					parent.lag_frames = 6
					parent.frame()
					return states.LANDING
				if not Input.is_action_pressed("jump_%s" % id):
					parent.velocity.x = lerp(parent.velocity.x,0,0.08)
					parent.frame()
					return states.SHORT_HOP	
				else:
					parent.velocity.x = lerp(parent.velocity.x,0,0.08)
					parent.frame()
					return states.FULL_HOP


		states.SHORT_HOP:
			parent.velocity.y = -parent.JUMPFORCE
			parent.frame()
			return states.AIR

		states.FULL_HOP:
			parent.velocity.y = -parent.MAX_JUMPFORCE
			parent.frame()
			return states.AIR

		states.DASH:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT

			elif Input.is_action_pressed("left_%s" % id):
				if parent.velocity.x > 0:
					parent.frame()
				parent.velocity.x = -parent.DASHSPEED
				if parent.frame <= parent.dash_duration-1:
					if Input.is_action_just_pressed("down_%s" % id):
						parent.frame()
						return states.MOONWALK
					parent.turn(true)
					return states.DASH
				else:
					parent.turn(true)
					parent.frame()
					return states.RUN

			elif Input.is_action_pressed("right_%s" % id):
				if parent.velocity.x < 0:
					parent.frame()
				parent.velocity.x =parent.DASHSPEED
				if parent.frame <= parent.dash_duration-1:
					if Input.is_action_just_pressed("down_%s" % id):
						parent.frame()
						return states.MOONWALK
					parent.turn(false)
					return states.DASH
				else:
					parent.turn(false)
					parent.frame()
					return states.RUN
			else:
				if parent.frame >= parent.dash_duration-1:
					for state in states:
						if state != "JUMP_SQUAT":
							parent.frame()
							return states.STAND

		states.MOONWALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT

			elif Input.is_action_pressed("left_%s" % id) && parent.direction() == 1:
				if parent.velocity.x > 0:
					parent.frame()
				parent.velocity.x += -parent.AIR_ACCEL * Input.get_action_strength("left_%s" % id)
				parent.velocity.x = clamp(parent.velocity.x,-parent.DASHSPEED*1.4,parent.velocity.x)
				if parent.frame <= parent.dash_duration*2:
					parent.turn(false)
					return states.MOONWALK
				else:
					parent.turn(true)
					parent.frame()
					return states.STAND

			elif Input.is_action_pressed("right_%s" % id) && parent.direction() == -1:
				if parent.velocity.x < 0:
					parent.frame()
				parent.velocity.x += parent.AIR_ACCEL * Input.get_action_strength("right_%s" % id)
				parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,parent.DASHSPEED*1.5)
				if parent.frame <= parent.dash_duration*2:
					parent.turn(true)
					return states.MOONWALK
				else:
					parent.turn(false)
					parent.frame()
					return states.STAND

			else:
				if parent.frame >= parent.dash_duration-1:
					for state in states:
						if state != "JUMP_SQUAT":
							return states.STAND
		states.WALK:
#			if parent.frame < 5:
#				if Input.get_action_strength("left_%s" % id) == 1:
#					parent.velocity.x = -parent.RUNSPEED
#					parent.frame()
#					parent.turn(true)
#					return states.DASH
#				if Input.get_action_strength("right_%s" % id) == 1:
#					parent.velocity.x = parent.RUNSPEED
#					parent.frame()
#					parent.turn(false)
#					return states.DASH
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT 
			if Input.is_action_just_pressed("down_%s" % id):
				parent.frame()
				return states.CROUCH
			if Input.get_action_strength("left_%s" % id):
				parent.velocity.x = -parent.WALKSPEED* Input.get_action_strength("left_%s" % id)
				parent.turn(true)
			elif Input.get_action_strength("right_%s" % id):
				parent.velocity.x = parent.WALKSPEED* Input.get_action_strength("right_%s" % id)
				parent.turn(false)
			else:
				parent.frame()
				return states.STAND

		states.RUN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT 
			if Input.is_action_just_pressed("down_%s" % id):
				parent.frame()
				return states.CROUCH
			if Input.get_action_strength("left_%s" % id):
				if parent.velocity.x <= 0:
					parent.velocity.x = -parent.RUNSPEED
					parent.turn(true)
				else:
					parent.frame()
					return states.TURN
			elif Input.get_action_strength("right_%s" % id):
				if parent.velocity.x >= 0:
					parent.velocity.x = parent.RUNSPEED
					parent.turn(false)
				else:
					parent.frame()
					return states.TURN
			else:
				#if parent.velocity.x > 0:
				#	parent.velocity.x =  parent.velocity.x - parent.TRACTION*1
				#	parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				#elif parent.velocity.x < 0:
				#	parent.velocity.x =  parent.velocity.x + parent.TRACTION*1
				#	parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			#	#Add a "DashStop" Animation here to show fox slowing down
				#else:
				parent.frame()
				return states.STAND

		states.TURN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT 
			if parent.velocity.x > 0:
				parent.turn(true)
				parent.velocity.x += -parent.TRACTION*2
				parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0:
				parent.turn(false)
				parent.velocity.x += parent.TRACTION*2
				parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			else:
				if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
					parent.frame()
					return states.STAND
				else:
					parent.frame()
					return states.RUN

		states.CROUCH:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT 
			if Input.is_action_just_released("down_%s" % id):
				parent.frame()
				return states.STAND
			elif parent.velocity.x > 0:
				if parent.velocity.x>parent.RUNSPEED:		
					parent.velocity.x +=  -(parent.TRACTION*4)
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				else:	
					parent.velocity.x +=  -(parent.TRACTION/2)
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0:
				if abs(parent.velocity.x)>parent.RUNSPEED:		
					parent.velocity.x +=  (parent.TRACTION*4)
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
				else:	
					parent.velocity.x += (parent.TRACTION/2)
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)


		states.AIR:
			AIRMOVEMENT()
			if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump -= 1
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.MAXAIRSPEED

		states.LANDING:
			if parent.frame == 1:
				if parent.l_cancel >= 0:
					parent.lag_frames = floor(parent.lag_frames / 2)
					print("L cancel")
					l_cancel = true
				else:
					l_cancel = false
			if parent.frame <= parent.landing_frames + parent.lag_frames:
#				if Input.is_action_just_pressed("jump_%s" % id): #and Input.is_action_pressed("shield"):
#					parent.frame()
#					return states.JUMP_SQUAT
				if l_cancel == false:
					print ("false")
					if parent.velocity.x > 0:
						parent.velocity.x -=  parent.TRACTION
						parent.velocity.x = clamp(parent.velocity.x, 0 , parent.velocity.x)
					elif parent.velocity.x < 0:
						parent.velocity.x +=  parent.TRACTION
						parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0 )
				else:
					print ("true")
					if parent.velocity.x > 0:
						parent.velocity.x -=  parent.TRACTION/100
						parent.velocity.x = clamp(parent.velocity.x, 0 , parent.velocity.x)
					elif parent.velocity.x < 0:
						parent.velocity.x +=  parent.TRACTION/100
						parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0 )
			else:
				parent.lag_frames = 0
				if Input.is_action_pressed("down_%s" % id):
					parent.lag_frames = 0
					parent.frame()
					return states.CROUCH
				elif Input.get_action_strength("right_%s" % id) == 1 and l_cancel == false:
					parent.velocity.x = parent.WALKSPEED
					parent.frame()
					parent.turn(false)
					return states.WALK
				elif Input.get_action_strength("left_%s" % id) == 1 and l_cancel == false:
					parent.velocity.x = -parent.WALKSPEED
					parent.frame()
					parent.turn(true)
					return states.WALK
				else:
					l_cancel = false
					parent.frame()
					parent.lag_frames = 0
					return states.STAND

		states.LEDGE_CATCH:
				if parent.frame > 7:
					parent.lag_frames = 0
					parent.reset_Jumps()
					parent.frame()
					return states.LEDGE_HOLD



		states.LEDGE_HOLD:
			if parent.frame >=390: #3.5 seconds
				self.parent.position.y += -25
				parent.frame()
				return states.TUMBLE
			if Input.is_action_just_pressed("down_%s" % id):
				parent.fastfall = true
				parent.regrab = 30
				parent.reset_ledge()
				self.parent.position.y += -25
				parent.catch = false
				parent.frame()
				return states.AIR
			#Facing Right
			elif parent.Ledge_Grab_F.get_cast_to().x>0:
				if Input.is_action_just_pressed("left_%s" % id):
					parent.velocity.x = (parent.AIR_ACCEL/2)
					parent.regrab = 30
					parent.reset_ledge()
					self.parent.position.y += -25
					parent.catch = false
					parent.frame()
					return states.AIR
				elif Input.is_action_just_pressed("right_%s" % id):
					parent.frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield_%s" % id):
					parent.frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					parent.frame()
					return states.LEDGE_JUMP

			#Facing Left
			elif parent.Ledge_Grab_F.get_cast_to().x<0:
				if Input.is_action_just_pressed("right_%s" % id):
					parent.velocity.x = (parent.AIR_ACCEL/2)
					parent.regrab = 30
					parent.reset_ledge()
					self.parent.position.y += -25
					parent.frame()
					return states.AIR
				elif Input.is_action_just_pressed("left_%s" % id):
					parent.frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield_%s" % id):
					parent.frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					parent.frame()
					return states.LEDGE_JUMP

		states.LEDGE_CLIMB:
			if parent.frame == 1:
				pass
			#	parent.hurtbox.disabled = true
			if parent.frame == 5:
				parent.position.y -=25
			if parent.frame == 10:
				parent.position.y -=25
			if parent.frame == 20:
				parent.position.y -=25	
			if parent.frame == 22:
				parent.catch = false
				parent.position.y -=25
				parent.position.x +=50*parent.direction()
			if parent.frame==25:
				parent.velocity.y=0
				parent.velocity.x=0
				parent.move_and_collide(Vector2(parent.direction()*20,50))
				#parent.hurtbox.disabled = false
			if parent.frame==30:
				parent.reset_ledge()
				parent.frame()
				return states.STAND

		states.LEDGE_JUMP:
				if parent.frame >14:
					if Input.is_action_just_pressed("attack_%s" % id):
						parent.frame()
						return states.AIR_ATTACK
					if Input.is_action_just_pressed("special_%s" % id):
						parent.frame()
						return states.SPECIAL
				if parent.frame == 5:
					parent.reset_ledge()
					parent.position.y -=20
				if parent.frame == 10:
					parent.catch = false
					parent.position.y -=20
					if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
						parent.fastfall = false
						parent.velocity.y = -parent.DOUBLEJUMPFORCE
						parent.velocity.x = 0
						parent.airJump -= 1
						parent.frame()
						return states.AIR
				if parent.frame == 15:
					parent.position.y -=20	
					parent.velocity.y -=parent.DOUBLEJUMPFORCE#*1.5
					parent.velocity.x +=220*parent.direction()
					if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
						parent.fastfall = false
						parent.velocity.y = -parent.DOUBLEJUMPFORCE
						parent.velocity.x = 0
						parent.airJump -= 1
						parent.frame()
						return states.AIR
					if Input.is_action_just_pressed("attack_%s" % id):
						parent.frame()
						return states.AIR_ATTACK
				elif parent.frame > 15 and parent.frame <20:
					parent.velocity.y+=parent.FALLSPEED
					if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
						parent.fastfall = false
						parent.velocity.y = -parent.DOUBLEJUMPFORCE
						parent.velocity.x = 0
						parent.airJump -= 1
						parent.frame()
						return states.AIR
					if Input.is_action_just_pressed("attack_%s" % id):
						parent.frame()
						return states.AIR_ATTACK
				if parent.frame==20:
					parent.frame()
					return states.AIR

		states.LEDGE_ROLL:
			if parent.frame == 1:
				pass
				#parent.hurtbox.disabled = true
			if parent.frame == 5:
				parent.position.y -=30
			if parent.frame == 10:
				parent.position.y -=30
			
			if parent.frame == 20:
				parent.catch = false
				parent.position.y -=30
			
			if parent.frame == 22:
				parent.position.y -=30
				parent.position.x +=50*parent.direction()
			
			if parent.frame >22 and parent.frame<28:
				parent.position.x +=30*parent.direction()
#				parent.hurtbox.disabled = false
		
			if parent.frame==29:
				parent.move_and_collide(Vector2(parent.direction()*20,50))
			if parent.frame==30:
				parent.velocity.y=0
				parent.velocity.x=0
				parent.reset_ledge()
				parent.frame()
				return states.STAND

		states.AIR_ATTACK:
			AIRMOVEMENT()
			if Input.is_action_pressed("up_%s" % id):
				parent.frame()
				return states.UAIR
			if Input.is_action_pressed("down_%s" % id):
				parent.frame()
				return states.DAIR
			match parent.direction():
				1:
					if Input.is_action_pressed("left_%s" % id):
						parent.frame()
						return states.BAIR
					if Input.is_action_pressed("right_%s" % id):
						parent.frame()
						return states.FAIR
				-1:
					if Input.is_action_pressed("right_%s" % id):
						parent.frame()
						return states.BAIR
					if Input.is_action_pressed("left_%s" % id):
						parent.frame()
						return states.FAIR
			parent.frame()
			return states.NAIR

		states.NAIR:
			
			AIRMOVEMENT()
			if parent.frame == 0:
				print ('nair')
				parent.NAIR()
			if parent.NAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR
			elif parent.frame < 5:
				parent.lag_frames = 0
			elif parent.frame > 15:
				parent.lag_frames = 0
			else:
				parent.lag_frames = 5

		states.UAIR:
			
			AIRMOVEMENT()
			if parent.frame == 0:
				print ('uair')
				parent.UAIR()
			if parent.UAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR
			elif parent.frame < 5:
				parent.lag_frames = 0
			elif parent.frame > 15:
				parent.lag_frames = 0
			else:
				parent.lag_frames = 10


		states.BAIR:
			
			AIRMOVEMENT()
			if parent.frame == 0:
				print ('bair')
				parent.BAIR()
			if parent.BAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR
			else:
				parent.lag_frames = 15

		states.FAIR:
			
			AIRMOVEMENT()
			if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump -= 1
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.MAXAIRSPEED
				return states.AIR
			if parent.frame == 0:
				print ('fair')
				parent.FAIR()
			if parent.FAIR() == true:
				parent.lag_frames = 30
				parent.frame()
				return states.FAIR
			else:
				parent.lag_frames = 10

		states.DAIR:
			
			AIRMOVEMENT()
			if parent.frame == 0:
				print ('bair')
				parent.DAIR()
			if parent.DAIR() == true:
				parent.lag_frames = 0
				return states.AIR
			elif parent.frame < 5:
				parent.lag_frames = 0
			else:
				parent.lag_frames = 8

		states.GROUND_ATTACK:
			if Input.is_action_pressed("up_%s" % id):
				parent.frame()
				return states.UP_TILT
			if Input.is_action_pressed("down_%s" % id):
				parent.frame()
				return states.DOWN_TILT
			if (Input.is_action_pressed("left_%s" % id) or Input.is_action_pressed("right_%s" % id)):
				parent.frame()
				if Input.is_action_pressed("left_%s" % id):
					parent.turn(true)
					parent.frame()
					return states.FORWARD_TILT
				if Input.is_action_pressed("right_%s" % id):
					parent.turn(false)
					parent.frame()
					return states.FORWARD_TILT
			parent.frame()
			return states.JAB

		states.JAB:
			
			if parent.frame <= 1:
				if parent.velocity.x > 0:
					if parent.velocity.x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x =  parent.velocity.x - parent.TRACTION*20
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x =  parent.velocity.x + parent.TRACTION*20
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
				parent.JAB()
			if parent.JAB() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.frame()
					return states.CROUCH
				else:
					parent.frame()
					return states.STAND
			if parent.JAB() == false:
				parent.frame()
				return states.JAB_1
		states.JAB_1:
			
			if parent.frame <= 1:
				if parent.velocity.x > 0:
					if parent.velocity.x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x =  parent.velocity.x - parent.TRACTION*20
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x =  parent.velocity.x + parent.TRACTION*20
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
				parent.JAB_1()
			if parent.JAB_1() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.frame()
					return states.CROUCH
				else:
					parent.frame()
					return states.STAND

		states.DOWN_TILT:
			if parent.frame == 0:
				parent.DOWN_TILT()
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x +=  parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			if parent.DOWN_TILT() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.frame()
					return states.CROUCH
				else:
					parent.frame()
					return states.STAND

		states.UP_TILT:
			if parent.frame == 0:
				parent.frame()
				parent.UP_TILT()
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x +=  parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			if parent.UP_TILT() == true:
				parent.frame()
				return states.STAND

		states.FORWARD_TILT:
			if parent.frame == 0:
				parent.frame()
				parent.FORWARD_TILT()
			if parent.frame <= 1:
				if parent.velocity.x > 0:
					if parent.velocity.x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x =  parent.velocity.x - parent.TRACTION*2
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x =  parent.velocity.x + parent.TRACTION*2
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			if parent.FORWARD_TILT() == true:
				if Input.is_action_pressed("left_%s" % id):
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x =  parent.velocity.x + parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
					parent.frame()
					return states.WALK
				if Input.is_action_pressed("right_%s" % id):
					if parent.velocity.x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x =  parent.velocity.x - parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
					parent.frame()
					return states.WALK
				else:
					parent.frame()
					return states.STAND

		states.HITFREEZE:
			if parent.freezeframes == 0:
				parent.frame()
				parent.velocity.x = kbx
				parent.velocity.y = kby
				parent.hdecay = hd
				parent.vdecay = vd
				return states.HITSTUN
			parent.position = pos

		states.HITSTUN:
			print (str(parent.frame) + " is frame")
			print (str(parent.hitstun) + " is hitstun")
			if parent.knockback >= 18:
				var bounce = parent.move_and_collide(parent.velocity *delta)
				if bounce:
					parent.velocity = parent.velocity.bounce(bounce.normal) * .8
					parent.hitstun = round(parent.hitstun * .8)
			if parent.velocity.y < 0:
				parent.velocity.y +=parent.vdecay*0.5 * Engine.time_scale
				parent.velocity.y = clamp(parent.velocity.y,parent.velocity.y,0)
			if parent.velocity.x < 0:
				parent.velocity.x += (parent.hdecay)*0.4 *-1 * Engine.time_scale#/5 * -1 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			elif parent.velocity.x > 0:
				parent.velocity.x -= parent.hdecay*0.4 * Engine.time_scale#/5 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)

			if parent.frame >= parent.hitstun:
				#print ("knocback is" + str(parent.knockback))
				if parent.knockback >= 24:
					parent.frame()
					return states.AIR
				else:
					parent.frame()
					return states.AIR
			elif parent.frame >60*5:
				return states.AIR


func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			parent.play_animation('IDLE')
			parent.states.text = str('STAND')
		states.RUN:
			parent.play_animation('RUN')
			parent.states.text = str('RUN')
		states.WALK:
			parent.play_animation('WALK')
			parent.states.text = str('WALK')
		states.FULL_HOP:
			parent.play_animation('AIR')
			parent.states.text = str('FULL_HOP')
		states.SHORT_HOP:
			parent.play_animation('AIR')
			parent.states.text = str('SHORT_HOP')
		states.MOONWALK:
			parent.play_animation('WALK')
			parent.states.text = str('MOONWALK')
		states.DASH:
			parent.play_animation('DASH')
			parent.states.text = str('DASH')
		states.JUMP_SQUAT:
			parent.play_animation('JUMP_SQUAT')
			parent.states.text = str('JUMP_SQUAT')
		states.TURN:
			parent.play_animation('TURN')
			parent.states.text = str('TURN')
		states.CROUCH:
			parent.play_animation('CROUCH')
			parent.states.text = str('CROUCH')
		states.AIR:
			parent.play_animation('AIR')
			parent.states.text = str('AIR')
		states.FREE_FALL:
			parent.play_animation('FREE_FALL')
			parent.states.text = str('FREE_FALL')
		states.LANDING:
			parent.play_animation('LANDING')
			parent.states.text = str('LANDING')
		states.AIR_DODGE:
			parent.play_animation('AIR_DODGE')
			parent.states.text = str('AIR_DODGE')
		states.LEDGE_CATCH:
			parent.play_animation('LEDGE_CATCH')
			parent.states.text = str('LEDGE_CATCH')
		states.LEDGE_HOLD:
			parent.play_animation('LEDGE_CATCH')
			parent.states.text = str('LEDGE_HOLD')
		states.LEDGE_JUMP:
			parent.play_animation('AIR')
			parent.states.text = str('LEDGE_JUMP')
		states.LEDGE_CLIMB:
			parent.play_animation('ROLL_FORWARD')
			parent.states.text = str('LEDGE_CLIMB')
		states.LEDGE_ROLL:
			parent.play_animation('ROLL_FORWARD')
			parent.states.text = str('LEDGE_ROLL')
		states.HITSTUN:
			parent.play_animation('HITSTUN')
			parent.states.text = str('HITSTUN')
		states.HITFREEZE:
			parent.play_animation('HITSTUN')
			parent.states.text = str('HITFREEZE')
		states.TUMBLE:
			parent.play_animation('TUMBLE')
			parent.states.text = str('TUMBLE')
		states.PARRY:
			parent.play_animation('PARRY')
			parent.states.text = str('PARRY')
		states.ROLL_RIGHT:
			parent.play_animation('TECH_GROUND')
			parent.states.text = str('ROLL_RIGHT')
		states.ROLL_LEFT:
			parent.play_animation('TECH_GROUND')
			parent.states.text = str('ROLL_LEFT')
		states.TECH_GROUND:
			parent.play_animation('TECH_GROUND')
			parent.states.text = str('TECH_GROUND')
		states.TECH_FORWARD:
			parent.play_animation('TECH_GROUND')
			parent.states.text = str('TECH_FORWARD')
		states.TECH_BACKWARD:
			parent.play_animation('TECH_GROUND')
			parent.states.text = str('TECH_BACKWARD')
		states.UP_TILT:
			parent.play_animation('UP_TILT')
			parent.states.text = str('UP_TILT')
		states.DOWN_TILT:
			parent.play_animation('DOWN_TILT')
			parent.states.text = str('DOWN_TILT')
		states.FORWARD_TILT:
			parent.play_animation('FORWARD_TILT')
			parent.states.text = str('FORWARD_TILT')
		states.JAB:
			parent.play_animation('JAB')
			parent.states.text = str('JAB')
		states.JAB_1:
			parent.play_animation('JAB_1')
			parent.states.text = str('JAB_1')
		states.GROUND_ATTACK:
			parent.states.text = str('GROUND_ATTACK')
		states.SPECIAL:
			parent.states.text = str('SPECIAL')
		states.FORWARD_SPECIAL:
			parent.play_animation('FORWARD_SPECIAL')
			parent.states.text = str('FORWARD_SPECIAL')
		states.NEUTRAL_SPECIAL:
			parent.play_animation('NEUTRAL_SPECIAL')
			parent.states.text = str('NEUTRAL_SPECIAL')
		states.UP_SPECIAL:
			parent.play_animation('UP_SPECIAL')
			parent.states.text = str('UP_SPECIAL')
		states.UP_SPECIAL_1:
			parent.play_animation('UP_SPECIAL_1')
			parent.states.text = str('UP_SPECIAL_1')
		states.DOWN_SPECIAL:
			parent.play_animation('DOWN_SPECIAL')
			parent.states.text = str('DOWN_SPECIAL')
		states.NAIR:
			parent.play_animation('NAIR')
			parent.states.text = str('NAIR')
		states.UAIR:
			parent.play_animation('UAIR')
			parent.states.text = str('UAIR')
		states.BAIR:
			parent.play_animation('BAIR')
			parent.states.text = str('BAIR')
		states.FAIR:
			parent.play_animation('FAIR')
			parent.states.text = str('FAIR')
		states.DAIR:
			parent.play_animation('DAIR')
			parent.states.text = str('DAIR')
		states.DOWN_SMASH:
			parent.play_animation('DOWN_SMASH')
			parent.states.text = str('DOWN_SMASH')
		states.DOWN_SMASH_1:
			parent.play_animation('DOWN_SMASH_1')
			parent.states.text = str('DOWN_SMASH_1')
		states.UP_SMASH:
			parent.play_animation('UP_SMASHS')
			parent.states.text = str('UP_SMASH')
		states.UP_SMASH_1:
			parent.play_animation('UP_SMASHS_1')
			parent.states.text = str('UP_SMASH_1')
		states.FORWARD_SMASH:
			parent.play_animation('FORWARD_SMASHS')
			parent.states.text = str('FORWARD_SMASH')
		states.FORWARD_SMASH_1:
			parent.play_animation('FORWARD_SMASHS_1')
			parent.states.text = str('FORWARD_SMASH_1')
		states.RESPAWN:
			parent.play_animation('STAND')
			parent.states.text = str('RESPAWN')
		states.DEAD:
			parent.play_animation('STAND')
			parent.states.text = str('DEAD')
func exit_state(old_state, new_state):
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func TILT():
	if state_includes([states.STAND,states.MOONWALK,states.DASH,states.RUN,states.WALK,states.CROUCH]):
		return true

func AIREAL():
	if state_includes([states.UP_SPECIAL,states.DOWN_SPECIAL,states.NEUTRAL_SPECIAL,states.FORWARD_SPECIAL,states.JUMP_SQUAT,states.AIR,states.DOWN_SMASH,states.DOWN_SMASH_1,states.FORWARD_SMASH,states.FORWARD_SMASH_1,states.UP_SMASH,states.UP_SMASH_1,states.TUMBLE]):
		if !(parent.GroundL.is_colliding() and parent.GroundR.is_colliding()):
			return true
		else:
			return false

func AIRMOVEMENT():
#	if parent.is_on_ceiling() == true:
#		parent.velocity.y = 1
	if parent.velocity.y <= parent.FALLINGSPEED:
		parent.velocity.y +=parent.FALLSPEED
	if Input.is_action_just_pressed("down_%s" % id) and parent.velocity.y > -150 and not parent.fastfall :
	#	sound_play($"../Fastfall")
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true:
		parent.set_collision_mask_bit(2,false)
		parent.velocity.y = parent.MAXFALLSPEED
	if  abs(parent.velocity.x) >=  abs(parent.MAXAIRSPEED):
		if parent.velocity.x > 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x += -parent.AIR_ACCEL
			elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.velocity.x
		if parent.velocity.x < 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x = parent.velocity.x
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x += parent.AIR_ACCEL
					
				
	elif abs(parent.velocity.x) < abs(parent.MAXAIRSPEED):
		if Input.is_action_pressed("left_%s" % id):
			parent.velocity.x += -parent.AIR_ACCEL#*2
		if Input.is_action_pressed("right_%s" % id):
			parent.velocity.x += parent.AIR_ACCEL#*2
		
	if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
		#print('Air Deaccel')
		if parent.velocity.x < 0:
			parent.velocity.x += parent.AIR_ACCEL/ 5#10
		elif parent.velocity.x > 0:
			parent.velocity.x += -parent.AIR_ACCEL / 5#10

func Landing():
	if state_includes([states.AIR,states.NAIR,states.UAIR,states.BAIR,states.FAIR,states.DAIR]):
		if (parent.GroundL.is_colliding()) and parent.velocity.y > 0:
			parent.reset_Jumps()
			var collider =parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true
			
		elif parent.GroundR.is_colliding() and parent.velocity.y > 0:
			parent.reset_Jumps()
			var collider2 =parent.GroundR.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true

func Falling():
	if state_includes([states.RUN,states.WALK,states.STAND,states.CROUCH,states.DASH,states.LANDING,states.TURN,states.JUMP_SQUAT,states.MOONWALK,states.ROLL_RIGHT,states.ROLL_LEFT,states.PARRY]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true

func Ledge():
	if state_includes([states.AIR,states.FREE_FALL,states.UP_SPECIAL_1,states.TUMBLE]):
		if (parent.Ledge_Grab_F.is_colliding()): 
			var collider = parent.Ledge_Grab_F.get_collider()
			if collider.get_node('Label').text =='Ledge_L' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:# and parent.Ledge_Grab_F.get_cast_to().x>0:# and not collider.is_grabbed:
#			Play Audio																																													audio.playsfx(audio_path('ledge'),0.7)
				if state_includes([states.AIR,states.FREE_FALL,]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x=0
				parent.velocity.y=0
				self.parent.position.x = collider.position.x - 20#- collider.get_collision().shape.get_extents().x
				self.parent.position.y = collider.position.y - 2#+ collider.get_collision().shape.get_extents().y
				parent.turn(false)
				parent.reset_Jumps()
				parent.fastfall = false
				#parent.last_ledge = collider
				#collider.get_node('Label').text = 'Ledge_LC'
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				#state = LEDGE_CATCH

			if collider.get_node('Label').text =='Ledge_R' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:# and parent.Ledge_Grab_F.get_cast_to().x<0: and not collider.is_grabbed:
				#audio.playsfx(audio_path('ledge'),0.7)
				if state_includes([states.AIR,states.FREE_FALL,]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x=0
				parent.velocity.y=0
				self.parent.position.x = collider.position.x + 20# + (parent.shapez.shape.get_extents().x)*2
				self.parent.position.y = collider.position.y + 1# + parent.shapez.shape.get_extents().y
				parent.turn(true)
				parent.reset_Jumps()
				parent.fastfall = false
				#parent.last_ledge = collider
			#	collider.get_node('Label').text = 'Ledge_RC'
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true

		if (parent.Ledge_Grab_B.is_colliding()): 
			var collider = parent.Ledge_Grab_B.get_collider()
			if collider.get_node('Label').text =='Ledge_L' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:# and parent.Ledge_Grab_F.get_cast_to().x>0:# and not collider.is_grabbed:
#			Play Audio																																													audio.playsfx(audio_path('ledge'),0.7)
				if state_includes([states.AIR,states.FREE_FALL,]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x=0
				parent.velocity.y=0
				self.parent.position.x = collider.position.x - 20#- collider.get_collision().shape.get_extents().x
				self.parent.position.y = collider.position.y - 1#+ collider.get_collision().shape.get_extents().y
				parent.turn(false)
				parent.reset_Jumps()
				parent.fastfall = false
				#parent.last_ledge = collider
			#	collider.get_node('Label').text = 'Ledge_LC'
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				#state = LEDGE_CATCH

			if collider.get_node('Label').text =='Ledge_R' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:# and parent.Ledge_Grab_F.get_cast_to().x<0: and not collider.is_grabbed:
				#audio.playsfx(audio_path('ledge'),0.7)
				if state_includes([states.AIR,states.FREE_FALL,]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x=0
				parent.velocity.y=0
				self.parent.position.x = collider.position.x + 20# + (parent.shapez.shape.get_extents().x)*2
				self.parent.position.y = collider.position.y + 1# + parent.shapez.shape.get_extents().y
				parent.turn(true)
				parent.reset_Jumps()
				parent.fastfall = false
			#	parent.last_ledge = collider
			#	collider.get_node('Label').text = 'Ledge_RC'
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true

var kbx
var kby
var hd
var vd
var pos

var bounce_hs = false

func hitfreeze(duration,knocback):
	pos = parent.get_position()
	parent.freezeframes = duration
	kbx = knocback[0]
	kby = knocback[1]
	hd = knocback[2]
	vd = knocback[3]
