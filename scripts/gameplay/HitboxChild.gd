extends Hitbox

@onready var collision_shape = $Hitbox_Shape
@onready var map = get_parent().get_parent().get_parent()

var idx : int = 0

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
	
	# hitbox properties
	hitboxShapes = data['hitboxShapes']
	damage = data['damage']
	knockbackForce = data['knockbackForce']
	if attacking_player.facingRight:
		knockbackAngle = data['knockbackAngle']
	else:
		knockbackAngle = SGFixed.PI - data['knockbackAngle']
	
	hitstun = data['hitstun']
	blockstun = data['blockstun']
	mask = data['mask']

	idx = 1
	tick = 0
	used = false
	attacking_player.attack_ended = false

	# set the first shape
	set_shape(hitboxShapes[0]["width"], hitboxShapes[0]["height"])

# Processing the hitbox
func _game_process() -> void:
	# animate the hitbox
	if idx >= len(hitboxShapes) - 1:
		if tick >= despawnAt:
			set_shape(0, 0)
			attacking_player.thrownHits -= 1
			attacking_player.attack_ended = true
			attacking_player.recovery = false
			SyncManager.despawn(self)
	elif tick >= hitboxShapes[idx]["ticks"]:
		set_shape(hitboxShapes[idx]["width"], hitboxShapes[idx]["height"])
		idx += 1
		tick = 0
		if idx == len(hitboxShapes) - 1:
			attacking_player.recovery = true
	tick += 1

func set_shape(w: int, h: int) -> void:
	collision_shape.shape._set_extents_x(w * SGFixed.HALF)
	collision_shape.shape._set_extents_y(h * SGFixed.HALF)

func _save_state() -> Dictionary:
	return {
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		width = collision_shape.shape._get_extents_x(),
		height = collision_shape.shape._get_extents_y(),
		used = used,
		tick = tick,
		idx = idx,
	}

func _load_state(loadState: Dictionary) -> void:
	fixed_position_x = loadState['fixed_position_x']
	fixed_position_y = loadState['fixed_position_y']
	collision_shape.shape._set_extents_x(loadState['width'])
	collision_shape.shape._set_extents_y(loadState['height'])
	used = loadState['used']
	tick = loadState['tick']
	idx = loadState['idx']
	sync_to_physics_engine()
