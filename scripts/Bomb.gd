extends SGFixedNode2D

const Explosion = preload("res://scenes//Explosion.tscn")

onready var explosion_timer = $ExplosionTimer
onready var animation_player = $NetworkAnimationPlayer

func _network_spawn(data: Dictionary) -> void:
	fixed_position.x = data['fixed_positionX']
	fixed_position.y = data['fixed_positionY']
	explosion_timer.start()
	animation_player.play("Tick")

func _on_ExplosionTimer_timeout() -> void:
	SyncManager.spawn("Explosion", get_parent(), Explosion, {
		fixed_positionX = fixed_position.x,
		fixed_positionY = fixed_position.y
	})
	SyncManager.despawn(self)
