extends SGArea2D

@onready var collisionShape = $SGCollisionShape2D
@onready var map = get_parent().get_parent()

# Hitbox parent class, all variables that are shared among all hitboxes
@onready var player = get_parent()# Name of attacking player (client/server)
@onready var opponet = map.get_node("ClientPlayer" if player.name == "ServerPlayer" else "ClientPlayer") # Name of attacked player (client/server)

var properties = {} # Properties of the hitbox (damage, knockback, etc.)

# var tick = 0 # Current tick the hitbox is on
var used = false # If the hitbox is used
var hitboxes = [] # The shapes of our hitbox over time (frames)

var idx : int = 0
var disabled = false

# TODO: kb direction does not get fliped when player is flipped

func do_attack(attack_name: String):
	properties = collisionShape.attacks[attack_name]
	hitboxes = properties['hitboxes']
	used = false
	idx = 0
	player.frame = 0
	player.attackDuration = properties["duration"]
	set_shape(hitboxes[0]["width"], hitboxes[0]["height"])
	set_pos(hitboxes[0]["x"], hitboxes[0]["y"])
	disabled = false

# Processing the hitbox
func _game_process() -> void:
	if properties == {}:
		return
	if disabled:
		set_shape(0, 0)
		properties = {}
		player.frame = -1
		return
	if player.frame >= hitboxes[idx]["ticks"]:
		idx += 1
		if idx > len(hitboxes) - 1:
			set_shape(0, 0)
			properties = {}
			player.frame = -1
			return
		set_shape(hitboxes[idx]["width"], hitboxes[idx]["height"])
		set_pos(hitboxes[idx]["x"], hitboxes[idx]["y"])
		player.frame = 0
	player.frame += 1

func set_shape(w: int, h: int) -> void:
	collisionShape.shape._set_extents_x(w * SGFixed.HALF)
	collisionShape.shape._set_extents_y(h * SGFixed.HALF)

func set_pos(x: int, y: int) -> void: # set_position was taken
	if player.facingRight:
		fixed_position_x = x * SGFixed.ONE
	else:
		fixed_position_x = -x * SGFixed.ONE
	fixed_position_y = y * SGFixed.NEG_ONE

func _save_state() -> Dictionary:
	return {
		properties = properties,
		# onHitKnockbackAngle = properties["onHit"]["knockback"]["angle"],
		# onBlockKnockbackAngle = properties["onBlock"]["knockback"]["angle"],
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		width = collisionShape.shape._get_extents_x(), # TODO: make sure this is safe
		height = collisionShape.shape._get_extents_y(),
		used = used,
		# tick = tick,
		idx = idx,
	}

func _load_state(loadState: Dictionary) -> void:
	properties = loadState['properties']
	# properties["onHit"]["knockback"]["angle"] = loadState['onHitKnockbackAngle']
	# properties["onBlock"]["knockback"]["angle"] = loadState['onBlockKnockbackAngle']
	fixed_position_x = loadState['fixed_position_x']
	fixed_position_y = loadState['fixed_position_y']
	collisionShape.shape._set_extents_x(loadState['width']) # TODO: make sure this is safe
	collisionShape.shape._set_extents_y(loadState['height'])
	used = loadState['used']
	# tick = loadState['tick']
	idx = loadState['idx']
	sync_to_physics_engine()
