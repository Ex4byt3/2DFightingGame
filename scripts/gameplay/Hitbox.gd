extends SGArea2D

onready var despawn_timer = $Hitbox_Shape/DespawnTimer

func _network_spawn(data: Dictionary) -> void:
	fixed_position.x = data['fixed_position_x']
	fixed_position.y = data['fixed_position_y']
	despawn_timer.start()

func _on_DespawnTimer_timeout() -> void:
	SyncManager.despawn(self)
