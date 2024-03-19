extends Hitbox

@onready var despawn_timer = $DespawnTimer
@onready var collision_shape = $Hitbox_Shape

var width = 0
var height = 0
var despawnAt = 1000
var canHitHitbox = false

func _network_spawn(data: Dictionary) -> void:
	fixed_position_x = data['fixed_position_x']
	fixed_position_y = data['fixed_position_y']
	damage = data['damage']
	attacking_player = data['attacking_player']
	if attacking_player == "ClientPlayer":
		set_collision_layer_bit(2, false)
		set_collision_layer_bit(1, true)
	hitboxShapes = data['hitboxShapes']
	var timer = 0
	for shapeItem in hitboxShapes:
		timer += shapeItem["ticks"]
	despawn_timer.wait_ticks = timer
	despawn_timer.start()

func _network_despawn() -> void:
	get_parent().get_node(NodePath(attacking_player)).thrownHits -= 1

func _network_process(_input: Dictionary) -> void:
	fixed_position_x = get_parent().get_node(NodePath(attacking_player)).fixed_position_x
	fixed_position_y = get_parent().get_node(NodePath(attacking_player)).fixed_position_y
	sync_to_physics_engine()
	
	if len(get_overlapping_areas()) > 0 and !used:
		if attacking_player == "ClientPlayer":
			get_parent().get_node("ServerPlayer").takeDamage = true
			get_parent().get_node("ServerPlayer").damage = damage
		else:
			get_parent().get_node("ClientPlayer").takeDamage = true
			get_parent().get_node("ClientPlayer").damage = damage
		used = true
	
	if despawnAt < 1000:
		if tick >= despawnAt:
			SyncManager.despawn(self)
	else:
		var timer = 0
		for shapeItem in hitboxShapes:
			if get_parent().get_node(NodePath(attacking_player)).frame > shapeItem["ticks"] + timer:
				timer += shapeItem["ticks"]
			else:
				collision_shape.shape._set_extents_x(shapeItem["width"] * SGFixed.HALF)
				collision_shape.shape._set_extents_y(shapeItem["height"] * SGFixed.HALF)
				break
	tick += 1

func _on_despawn_timer_timeout():
	width = 0
	height = 0
	despawnAt = tick + 20
	despawn_timer.stop()

func _save_state() -> Dictionary:
	return {
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		width = collision_shape.shape._get_extents_x(),
		height = collision_shape.shape._get_extents_y(),
		canHitHitbox = canHitHitbox,
		used = used,
		tick = tick,
		despawnAt = despawnAt
	}

func _load_state(loadState: Dictionary) -> void:
	fixed_position_x = loadState['fixed_position_x']
	fixed_position_y = loadState['fixed_position_y']
	collision_shape.shape._set_extents_x(loadState['width'])
	collision_shape.shape._set_extents_y(loadState['height'])
	canHitHitbox = loadState['canHitHitbox']
	used = loadState['used']
	tick = loadState['tick']
	despawnAt = loadState['despawnAt']
	sync_to_physics_engine()
