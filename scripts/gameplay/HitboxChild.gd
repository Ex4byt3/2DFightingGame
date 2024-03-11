extends Hitbox

@onready var despawn_timer = $DespawnTimer
@onready var collision_shape = $Hitbox_Shape

# FUTURE:
# hitbox.shape.size = Vector2(width, height)


func _network_spawn(data: Dictionary) -> void:
	damage = data['damage']
	attacking_player = data['attacking_player']
	if attacking_player == "ClientPlayer":
		set_collision_mask_bit(2, false)
		set_collision_mask_bit(1, true)
	hitboxShapes = data['hitboxShapes']
	despawn_timer.start()

func _network_despawn() -> void:
	despawn_timer.stop()

func _network_process(_input: Dictionary) -> void:
	print(get_parent().get_parent().frame)

func _on_despawn_timer_timeout():
	SyncManager.despawn(self)

func _save_state() -> Dictionary:
	return {
		used = used,
		tick = tick
	}

func _load_state(loadState: Dictionary) -> void:
	used = loadState['used']
	tick = loadState['tick']
	sync_to_physics_engine()
