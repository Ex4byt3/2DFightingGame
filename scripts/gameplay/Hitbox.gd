extends SGArea2D

@onready var despawn_timer = $DespawnTimer
@onready var collision_shape = $Hitbox_Shape

var attacking_player
var damage := 1000
var tick = 0
var used = false
var areas = []
# FUTURE:
# hitbox.shape.size = Vector2(width, height)

func _network_spawn(data: Dictionary) -> void:
	fixed_position.x = data['fixed_position_x']
	fixed_position.y = data['fixed_position_y']
	fixed_scale.x = data['fixed_scale_x']
	fixed_scale.y = data['fixed_scale_y']
	fixed_rotation = data['fixed_rotation']
	damage = data['damage']
	attacking_player = data['attacking_player']
	despawn_timer.start()

func _network_despawn() -> void:
	despawn_timer.stop()

func _network_process(_input: Dictionary) -> void:
	tick += 1

func _on_despawn_timer_timeout():
	SyncManager.despawn(self)

func _save_state() -> Dictionary:
	return {
		fixed_rotation = fixed_rotation,
		used = used,
		tick = tick
	}

func _load_state(loadState: Dictionary) -> void:
	fixed_rotation = loadState['fixed_rotation']
	used = loadState['used']
	tick = loadState['tick']
	sync_to_physics_engine()
