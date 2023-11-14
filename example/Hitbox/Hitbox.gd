extends Area2D

var parent = get_parent()
export var width = 300
export var height = 400
export var damage = 50
export var angle = 90
export var base_kb = 100
export var kb_scaling  = 2
export var duration = 1500
export var hitlag_modifier = 1
export var type  = 'normal'
export var angle_flipper = 0
onready var hitbox = get_node("Hitbox_Shape")
onready var parentState = get_parent().selfState
var knockbackVal
var framez  = 0.0
var player_list = []

func set_parameters(w,h,d,a,b_kb,kb_s,dur,t,p,af,hit,parent=get_parent()):
	self.position = Vector2(0,0)
	player_list.append(parent)
	player_list.append(self)
	width = w
	height = h
	damage = d
	angle = a
	base_kb = b_kb
	kb_scaling = kb_s
	duration = dur
	type = t
	self.position = p
	hitlag_modifier = hit
	angle_flipper = af
	update_extents()
	connect("body_entered", self, "Hitbox_Collide")
	set_physics_process(true)

func Hitbox_Collide(body):
#	body = body.get_parent()
	if !(body in player_list):
		player_list.append(body)
		var charstate
		charstate = body.get_node("StateMachine")
		weight = body.weight
		body.percentage += damage
		knockbackVal = knockback(body.percentage,damage,weight,kb_scaling,base_kb,1)
		s_angle(body)
		angle_flipper(body)
		body.knockback = knockbackVal
		body.hitstun = getHitstun(knockbackVal/0.3)
		get_parent().connected = true
		body.frame()
		charstate.state = charstate.states.HITSTUN

func update_extents():
	hitbox.shape.extents = Vector2(width,height)

func _ready():
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	pass

func _physics_process(delta):
	if framez<duration:
		framez += 1
	elif framez == duration:
		Engine.time_scale = 1
		queue_free()
		return
	if get_parent().selfState != parentState:
		Engine.time_scale = 1
		queue_free()
		return

func getHitstun (knockback):
	#return floor(knockback * 0.533);
	return floor(knockback * 0.4);

func hitlag(d,hit):
	damage = d
	hitlag_modifier = hit
	#return ((floor(d/3)+4)) 
	return floor((((floor(d) * 0.65) + 6) * hit))

export var percentage = 0
export var weight =  100
export var base_knockback = 40
export var ratio =1 

func knockback(p,d,w,ks,bk,r):
	percentage = p 
	damage = d
	weight = w
	kb_scaling = ks
	base_kb = bk
	ratio = r
	return ((((((((percentage/10) + (percentage*damage/20))*(200/ (weight+100)) *1.4) +18)*(kb_scaling))+base_kb)*1))*.004 #Smash Ultimate Version

func s_angle(body):
		if angle == 361:
			if knockbackVal > 28:
				if !body.is_on_floor() == true:
					angle = 40
				else:
					angle = 38
			else:
				if !body.is_on_floor() == true:
					angle = 40
				else:
					angle = 25
		elif angle == -181:
			if knockbackVal > 28:
				if !body.is_on_floor() == true:
					angle = (-40)+180
				else:
					angle = (-38)+180
			else:
				if !body.is_on_floor() == true:
					angle = (-40)+180
				else:
					angle = (-25)+180

const angleConversion = PI / 180

func getHorizontalDecay (angle): #The rate at which the opponant will slow down after knockback
	var decay = 0.051 * cos(angle * angleConversion) #Rate of decay is 0.051, to get horizontal rate; multiply by horizontal(cos) angle in radians
	decay = round(decay * 100000) / 100000 #Round to a whole number
	decay = decay * 1000 #Enlarge the rate of decay
	return decay

func getVerticalDecay (angle):
	var decay = 0.051 * sin(angle * angleConversion)
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return abs(decay)

func getHorizontalVelocity (knockback, angle): # Function gets the horizontal knockback speed with total knockback and angle
	var initialVelocity = knockback * 30; #Gets the initial velocity by multiplying knockback by 30
	var horizontalAngle = cos(angle * angleConversion); #Horizontal angle is calculated by cos formula, angle conversion puts the angle in Radians
	var horizontalVelocity = initialVelocity * horizontalAngle; #Horizontal velocity is found by multiplying initial velocity by horizontal angle
	horizontalVelocity = round(horizontalVelocity * 100000) / 100000; #Round to a whole number
	return horizontalVelocity;

func getVerticalVelocity (knockback, angle):
	var initialVelocity = knockback * 30;
	var verticalAngle = sin(angle * angleConversion);
	var verticalVelocity = initialVelocity * verticalAngle;
	verticalVelocity = round(verticalVelocity * 100000) / 100000;
	return verticalVelocity

func angle_flipper(body):
	var xangle
	if get_parent().direction() == -1:
		xangle = (-(((body.global_position.angle_to_point(get_parent().global_position))*180)/PI))
	else:
		xangle = (((body.global_position.angle_to_point(get_parent().global_position))*180)/PI)
	match angle_flipper:
		0:
			body.velocity.x = (getHorizontalVelocity (knockbackVal, -angle))
			body.velocity.y = (getVerticalVelocity (knockbackVal, -angle))
			body.hdecay = (getHorizontalDecay(-angle))
			body.vdecay = (getVerticalDecay(angle))
		1:
			if get_parent().direction() == -1:
				xangle = -(((self.global_position.angle_to_point(body.get_parent().global_position))*180)/PI)
			else:
				xangle = (((self.global_position.angle_to_point(body.get_parent().global_position))*180)/PI)
			body.velocity.x = ((getHorizontalVelocity (knockbackVal, xangle+180)))
			body.velocity.y = ((getVerticalVelocity (knockbackVal, -xangle)))
			body.hdecay = (getHorizontalDecay(angle+180))
			body.vdecay = (getVerticalDecay(xangle))
			#away
			#return angle
		2:
			if get_parent().direction() == -1:
				xangle = -(((body.get_parent().global_position.angle_to_point(self.global_position))*180)/PI)
			else:
				xangle = (((body.get_parent().global_position.angle_to_point(self.global_position))*180)/PI)
			body.velocity.x = ((getHorizontalVelocity (knockbackVal, -xangle+180)))
			body.velocity.y = ((getVerticalVelocity (knockbackVal, -xangle)))
			body.hdecay = (getHorizontalDecay(xangle+180))
			body.vdecay = (getVerticalDecay(xangle))
			#towards
			#return angle
		3:
			if get_parent().direction() == -1:
				xangle = (-(((body.global_position.angle_to_point(self.global_position))*180)/PI))+180
			else:
				xangle = (((body.global_position.angle_to_point(self.global_position))*180)/PI)
			body.velocity.x = (getHorizontalVelocity (knockbackVal,xangle))
			body.velocity.y = (getVerticalVelocity (knockbackVal, -angle))
			body.hdecay = (getHorizontalDecay(xangle))
			body.vdecay = (getVerticalDecay(angle))
		4:
			if get_parent().direction() == -1:
				xangle = -(((body.global_position.angle_to_point(self.global_position))*180)/PI)+180
			else:
				xangle = (((body.global_position.angle_to_point(self.global_position))*180)/PI)
			body.velocity.x = (getHorizontalVelocity (knockbackVal,-xangle*180))
			body.velocity.y = (getVerticalVelocity (knockbackVal, -angle))
			body.hdecay = (getHorizontalDecay(angle))
			body.vdecay = (getVerticalDecay(angle))
		5:
			body.velocity.x = (getHorizontalVelocity (knockbackVal,angle+180))
			body.velocity.y = (getVerticalVelocity (knockbackVal, -angle))
			body.hdecay = (getHorizontalDecay(angle+180))
			body.vdecay = (getVerticalDecay(angle))
		6:
			body.velocity.x = (getHorizontalVelocity ((knockbackVal),xangle))
			body.velocity.y = (getVerticalVelocity (knockbackVal, -angle))
			body.hdecay = (getHorizontalDecay(xangle))
			body.vdecay = (getVerticalDecay(angle))
			#away
		7:
			body.velocity.x = (getHorizontalVelocity (knockbackVal,-xangle+180))
			body.velocity.y = (getVerticalVelocity (knockbackVal, -angle))
			body.hdecay = (getHorizontalDecay(angle))
			body.vdecay = (getVerticalDecay(angle))
			#towards

	#0 - sends at the exact knockback_angle every time

	#1 - sends away from center of the enemy player

	#2 - sends toward center of the enemy player

	#3 - horizontal knockback sends away from the center of the hitbox

	#4 - horizontal knockback sends toward the center of the hitbox

	#5 - horizontal knockback is reversed

	#6 - horizontal knockback sends away from the enemy player

	#7 - horizontal knockback sends toward the enemy player

	#8 - sends away from the center of the hitbox

	#9 - sends towards the center of the hitbox
