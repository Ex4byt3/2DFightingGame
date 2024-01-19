extends SGFixedNode2D

onready var despawn_timer = $DespawnTimer
onready var animation_player = $NetworkAnimationPlayer

const sound = preload("res://assets/explosion.wav")

func _network_spawn(data: Dictionary) -> void:
	fixed_position.x = data['fixed_positionX']
	fixed_position.y = data['fixed_positionY']
	despawn_timer.start()
	animation_player.play("Explode")
	SyncManager.play_sound(str(get_path()) + ":explode", sound)

func _on_DespawnTimer_timeout() -> void:
	SyncManager.despawn(self)
