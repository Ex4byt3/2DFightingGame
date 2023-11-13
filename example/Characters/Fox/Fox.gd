extends KinematicBody2D

#Globals Variables
var frame = 0
export var id: int

#Attributes
export var percentage = 0
export var stocks = 3
export var weight = 100

#Knockback
var hdecay
var vdecay
var knockback
var hitstun
var connected:bool

#Ground Variables
var velocity = Vector2(0,0)
var dash_duration = 10

#Landing Variables
var landing_frames = 0
var lag_frames = 0

#Air Variables
var jump_squat = 3
var fastfall = false
var airJump = 0
export var airJumpMax = 1

#Ledges 
var last_ledge = false
var regrab = 30
var catch = false

#Hitboxes
export var hitbox: PackedScene
var selfState

#Onready Variables
onready var GroundL = get_node('Raycasts/GroundL')
onready var GroundR = get_node('Raycasts/GroundR')
onready var Ledge_Grab_F = get_node("Raycasts/Ledge_Grab_F")
onready var Ledge_Grab_B = get_node("Raycasts/Ledge_Grab_B")
onready var states = $State
onready var anim = $Sprite/AnimationPlayer

#FOX's main attributes
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

func updateframes(delta):
	frame += 1

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

func direction(): 
	if Ledge_Grab_F.get_cast_to().x > 0:
		return 1 
	else:
		return -1

func frame():
	frame = 0

func play_animation(animation_name):
	anim.play(animation_name)

func reset_Jumps():
	airJump = airJumpMax

func reset_ledge():
	last_ledge = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

func _physics_process(delta):
	$Frames.text = str(frame)
	selfState = states.text


#TIlt Attacks
func DOWN_TILT():
	if frame == 5:
		create_hitbox(40,20,8,90,70,50,3,'normal',Vector2(64,32),0,1)
		#My version create_hitbox(40,20,8,90,3,120,3,'normal',Vector2(64,32),0,1)
	if frame >=10:
		return true

func UP_TILT():
	if frame == 5:
		create_hitbox(48,68,8,76,20,110,3,'normal',Vector2(-22,-15),0,1)
		#My version create_hitbox(48,68,6,76,8,140,4,'normal',Vector2(-22,-15),0,1)
	if frame >=12:
		return true

func FORWARD_TILT():
	if frame == 3:
		create_hitbox(52,20,6,120,40,80,3,'normal',Vector2(22,8),0,1)
		#My version create_hitbox(52,20,7,120,13,100,3,'normal',Vector2(22,8),0,.5)
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
	if frame == 15:
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
	if frame == 17:
		return true
