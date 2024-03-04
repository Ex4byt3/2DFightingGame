extends SGFixedNode2D

@onready var despawn_timer = $DespawnTimer
@onready var animation_player = $NetworkAnimationPlayer

const sound = preload("res://assets/sound/explosion.wav")

func _network_spawn(data: Dictionary) -> void:
	fixed_position.x = data['fixed_position_x']
	fixed_position.y = data['fixed_position_y']
	despawn_timer.start()
	animation_player.play("Explode")
	SyncManager.play_sound(str(get_path()) + ":explode", sound)

func _on_DespawnTimer_timeout() -> void:
	SyncManager.despawn(self)
