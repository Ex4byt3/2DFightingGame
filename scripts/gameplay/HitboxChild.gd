extends Hitbox

@onready var despawn_timer = $DespawnTimer
@onready var collision_shape = $Hitbox_Shape

var width = 0
var height = 0
var despawnAt = 1000

func _network_spawn(data: Dictionary) -> void:
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

func _network_process(_input: Dictionary) -> void:
	if despawnAt < 1000:
		if tick >= despawnAt:
			SyncManager.despawn(self)
	else:
		collision_shape.shape._set_extents_x(width * SGFixed.HALF)
		collision_shape.shape._set_extents_y(height * SGFixed.HALF)
		var timer = 0
		for shapeItem in hitboxShapes:
			if get_parent().get_parent().frame > shapeItem["ticks"] + timer:
				timer += shapeItem["ticks"]
			else:
				width = shapeItem["width"]
				height = shapeItem["height"]
				break
	tick += 1

func _on_despawn_timer_timeout():
	width = 0
	height = 0
	despawnAt = tick + 20
	despawn_timer.stop()

func _save_state() -> Dictionary:
	return {
		height = height,
		width = width,
		used = used,
		tick = tick,
		despawnAt = despawnAt
	}

func _load_state(loadState: Dictionary) -> void:
	height = loadState['height']
	width = loadState['width']
	used = loadState['used']
	tick = loadState['tick']
	despawnAt = loadState['despawnAt']
	sync_to_physics_engine()
