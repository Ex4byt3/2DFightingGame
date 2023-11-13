extends KinematicBody2D

onready var states = $State

#Player
export var id: int

#Knockback
var hdecay
var vdecay
var knockback
var hitstun
var connected:bool

#Attributes
export var percentage = 0
export var stocks = 3
export var weight = 100

var velocity = Vector2(0,0)
var dash_duration = 10
var frame = 0
var freezeframes = 0

#Landing stuff
var landing_frames = 2
var lag_frames = 0
var jump_squat = 3
var perfect_wavedash_modifier = 1

#Air stuff
var airJump = 0
export var airJumpMax = 1
var fastfall = false
var l_cancel = 0
var cooldown = 0

#Ledges 
var last_ledge = false
var regrab = 30
var catch = false

#Hitboxes
export var hitbox: PackedScene
var selfState

#Temporary Variables
var temp_pos = Vector2(0,0)
var temp_vel = Vector2(0,0)
var hit_pause_dur = 0

onready var GroundL = get_node('Raycasts/GroundL')
onready var GroundR = get_node('Raycasts/GroundR')
onready var Ledge_Grab_F= get_node('Raycasts/Ledge_Grab_F') #NEW
onready var Ledge_Grab_B = get_node('Raycasts/Ledge_Grab_B') #NEW

var RUNSPEED = 340
var DASHSPEED = 390
var WALKSPEED = 200
var GRAVITY = 1800
var JUMPFORCE = 500
var MAX_JUMPFORCE = 800
var DOUBLEJUMPFORCE = 1000
var MAXAIRSPEED = 300
var AIR_ACCEL = 25
var FALLSPEED = 60
var FALLINGSPEED = 900
var MAXFALLSPEED = 900
var TRACTION = 40
var ROLL_DISTANCE = 350
var air_dodge_speed = 500
var UP_B_LAUNCHSPEED = 700

func updateframes(delta):
	frame += floor(delta *60)
	$Frames.text = str(frame)
	if freezeframes > 0:
		freezeframes -=1
	freezeframes = clamp(freezeframes,0,freezeframes)
	l_cancel -= floor(delta *60)
	clamp(l_cancel, 0, l_cancel)
	cooldown -= 1
	cooldown = clamp(cooldown,0,cooldown)

func turn(direction):
	var dir = 0
	if direction:
		dir = -1
	else:
		dir = 1
	$Sprite.set_flip_h(direction)
	Ledge_Grab_F.set_cast_to(Vector2(dir*abs(Ledge_Grab_F.get_cast_to().x),Ledge_Grab_F.get_cast_to().y))
	Ledge_Grab_F.position.x = dir * abs(Ledge_Grab_F.position.x)
	Ledge_Grab_B.position.x = dir * abs(Ledge_Grab_B.position.x)
	Ledge_Grab_B.set_cast_to(Vector2(-dir*abs(Ledge_Grab_F.get_cast_to().x),Ledge_Grab_F.get_cast_to().y))
	

func create_hitbox(width, height, damage,angle,base_kb, kb_scaling,duration,type,points,angle_flipper,hitlag=1):
	var hitbox_instance = hitbox.instance()
	self.add_child(hitbox_instance)
	#Rotates The Points 
	if direction() == 1:
		hitbox_instance.set_parameters(width, height, damage,angle,base_kb, kb_scaling,duration,type,points,angle_flipper,hitlag)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage,-angle+180,base_kb, kb_scaling,duration,type,flip_x_points,angle_flipper,hitlag)
	return hitbox_instance

func direction(): #NEW
	if Ledge_Grab_F.get_cast_to().x > 0: #NEW
		return 1 #NEW
	else: #NEW
		return -1 #NEW

func reset_Jumps():
	airJump = airJumpMax

func reset_ledge():
	last_ledge = false

func frame():
	frame = 0

func play_animation(animation_name):
	$Sprite/AnimationPlayer.play(animation_name)


#Tilt Attacks
func JAB():
	if frame == 2:
		pass#	create_grabbox(30,40,0,3,Vector2(64,0))
	if frame == 5:
		pass
			#if grabbing == true:
			#	return false
				#create_grabbox(40,50,0,13,Vector2(64,0))
	if frame >= 20:
		return true

func JAB_1():
	if frame == 1:
		pass#grabbing = false
		#create_grabbox(30,40,0,13,Vector2(64,0))
	if frame == 14:
		create_hitbox(40,20,8,90,250,0,5,'normal',Vector2(48,8),0,1)
	if frame == 26:
		pass
		#create_projectile(0,-1,Vector2(34.089,-70.645))
	if frame == 32:
		pass
		#create_projectile(0,-1,Vector2(34.089,-70.645))
	if frame == 39:
		pass
		#create_projectile(0,-1,Vector2(34.089,-70.645))
	if frame == 43:
		return true

func DOWN_TILT():
	if frame == 5:
		create_hitbox(40,20,8,90,70,60,3,'normal',Vector2(64,32),0,1)
	if frame >=10:
		return true

func UP_TILT():
	if frame == 5:
		create_hitbox(48,68,8,76,200,60,3,'normal',Vector2(-22,-15),0,1)
	if frame >=12:
		return true

func FORWARD_TILT():
	if frame == 3:
		create_hitbox(52,20,6,120,40,80,3,'normal',Vector2(22,8),0,1)
	if frame >=8:
		return true

#Air attacks
func NAIR():
	if frame == 1:
		create_hitbox(56,56,12,361,0,100,3,'normal',Vector2(0,0),0,.4)
	if frame > 1:
		if connected == true:
			#print ("sweetspot")
			if frame == 36:
				connected = false
				return true 
		else:
			if frame == 5:
				create_hitbox(46,56,9,361,0,100,10,'normal',Vector2(0,0),0,.1)
			if frame == 36:
				return true 

func UAIR():
	if frame == 2:
		create_hitbox(32,36,5,90,130,0,2,'normal',Vector2(0,-45),0,1)
	if frame == 6:
		create_hitbox(56,46,10,90,20,108,3,'normal',Vector2(0,-48),0,2)
	if frame == 35:
		return true 

func BAIR():
	if frame == 2:
		create_hitbox(52,55,15,45,1,100,5,'normal',Vector2(-47,7),6,1)
	if frame > 1:
		if connected == true:
			#print ("sweetspot")
			if frame == 18:
				connected = false
				return true 
		else:
			if frame == 7:
				create_hitbox(52,55,5,45,3,140,10,'normal',Vector2(-47,7),6,1)
			if frame == 18:
				return true

func FAIR():
	if frame == 2:
		create_hitbox(35,47,3,76,10,150,3,'normal',Vector2(60,-7),0,1)
	if frame == 11:
		create_hitbox(35,47,3,76,10,150,3,'normal',Vector2(60,-7),0,1)
	if frame == 18:
		return true 

func DAIR():
	if frame == 2:
		create_hitbox(36,58,2,290,140,0,2,'normal',Vector2(28,17),0,1)
	if frame == 3:
		create_hitbox(36,58,2,290,140,0,2,'normal',Vector2(28,17),0,1)
	if frame == 5:
		create_hitbox(36,58,2,290,140,0,2,'normal',Vector2(28,17),0,1)
	if frame == 7:
		create_hitbox(36,58,2,290,140,0,2,'normal',Vector2(28,17),0,1)
	if frame == 9:
		create_hitbox(36,58,2,290,140,0,2,'normal',Vector2(28,17),0,1)
	if frame == 11:
		create_hitbox(36,58,2,290,140,0,2,'normal',Vector2(28,17),0,1)
	if frame == 14:
		create_hitbox(36,58,4,45,12,120,2,'normal',Vector2(28,17),0,1)
	if frame == 37:
		return true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

func _physics_process(delta):
	selfState = states.text
	$Health.text = str(percentage)
