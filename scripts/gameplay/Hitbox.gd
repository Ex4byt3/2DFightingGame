# !!!
# This script does nothing, it does not work. I took it from that one platform fighter tutorial
# It is incomplete
# We need to look into how we should be doing hitboxes with SG Physics
# !!!

extends SGArea2D

# hitbox properties
var width
var height
var damage
var angle
var base_knockback
var knockback_scaling
var duration
var type
var angle_flipper
var hitlag_modifier
var hitbox = Hitbox.new()
var hitbox_shape = RectangleShape2D.new()
var hitbox_collision = CollisionShape2D.new()


onready var parent_state = get_parent().self_state
var knockback_value
var frames := 0
var player_list = []

func set_parameters(w, h, d, a, b_kb, kb_s, dur, t, p_x, p_y, af, hit, parent = get_parent()):
	self.fixed_position_x = 0
	self.fixed_position_y = 0
	player_list.append(parent)
	player_list.append(self)
	width = w
	height = h
	damage = d
	angle = a
	base_knockback = b_kb
	knockback_scaling = kb_s
	duration = dur
	type = t
	self.fixed_position_x = p_x
	self.fixed_position_y = p_y
	angle_flipper = af
	hitlag_modifier = hit
	update_extents()
	connect("body_entered", self, "_on_body_entered")
	set_physics_process(true)

func update_extents():
	hitbox.shape.extents = SGFixed.vector2(width, height)
	
func _on_body_entered(body):
	if not body in player_list:
		player_list.append(body)
		var character_state = body


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
