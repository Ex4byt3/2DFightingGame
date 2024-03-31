extends SGArea2D

@onready var collision_shape = $Hitbox_Shape
@onready var map = get_parent().get_parent().get_parent()

# Hitbox parent class, all variables that are shared among all hitboxes
var attacking_player # Name of attacking player (client/server)
var attacked_player # Name of attacked player (client/server)

var properties = {} # Properties of the hitbox (damage, knockback, etc.)

var tick = 0 # Current tick the hitbox is on
var used = false # If the hitbox is used
var hitboxes = [] # The shapes of our hitbox over time (frames)

var idx : int = 0
var disabled = false

# Spawns in the hitbox with all the data passed to it
func _network_spawn(data: Dictionary) -> void:
	# The name of the attacking player (Client or Server)
	attacking_player = get_parent().get_parent()
	if attacking_player.name == "ClientPlayer":
		set_collision_layer_bit(2, false)
		set_collision_layer_bit(1, true)
		attacked_player = map.get_node("ServerPlayer")
	else:
		attacked_player = map.get_node("ClientPlayer")
	
	properties = data

	# flipping the angle currently is not rollback safe
	# if !attacking_player.facingRight:
	# 	properties["onHit"]["knockback"]["angle"] = SGFixed.PI - properties["onHit"]["knockback"]["angle"]
	# 	properties["onBlock"]["knockback"]["angle"] = SGFixed.PI - properties["onBlock"]["knockback"]["angle"]

	attacking_player.attack_ended = false
	# set the first shape
	hitboxes = properties['hitboxes']
	$Hitbox_Shape.shape = SGRectangleShape2D.new()
	set_shape(hitboxes[0]["width"], hitboxes[0]["height"])
	set_pos(hitboxes[0]["x"], hitboxes[0]["y"])

# Processing the hitbox
func _game_process() -> void:
	if disabled:
		set_shape(0, 0)
		attacking_player.thrownHits -= 1
		attacking_player.recovery = false
		attacking_player.attack_ended = true
		SyncManager.despawn(self)
		return
	elif tick >= hitboxes[idx]["ticks"]:
		idx += 1
		if idx > len(hitboxes) - 1:
			set_shape(0, 0)
			attacking_player.thrownHits -= 1
			attacking_player.recovery = false
			attacking_player.attack_ended = true
			SyncManager.despawn(self)
			return
		set_shape(hitboxes[idx]["width"], hitboxes[idx]["height"])
		set_pos(hitboxes[idx]["x"], hitboxes[idx]["y"])
		if idx == len(hitboxes) - 1:
			attacking_player.recovery = true
		tick = 0
	tick += 1

func set_shape(w: int, h: int) -> void:
	collision_shape.shape._set_extents_x(w * SGFixed.HALF)
	collision_shape.shape._set_extents_y(h * SGFixed.HALF)

func set_pos(x: int, y: int) -> void: # set_position was taken
	if attacking_player.facingRight:
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
		width = collision_shape.shape._get_extents_x(),
		height = collision_shape.shape._get_extents_y(),
		used = used,
		tick = tick,
		idx = idx,
	}

func _load_state(loadState: Dictionary) -> void:
	properties = loadState['properties']
	# properties["onHit"]["knockback"]["angle"] = loadState['onHitKnockbackAngle']
	# properties["onBlock"]["knockback"]["angle"] = loadState['onBlockKnockbackAngle']
	fixed_position_x = loadState['fixed_position_x']
	fixed_position_y = loadState['fixed_position_y']
	collision_shape.shape._set_extents_x(loadState['width'])
	collision_shape.shape._set_extents_y(loadState['height'])
	used = loadState['used']
	tick = loadState['tick']
	idx = loadState['idx']
	sync_to_physics_engine()
