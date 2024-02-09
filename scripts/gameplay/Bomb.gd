extends SGFixedNode2D

const Explosion = preload("res://scenes//gameplay//Explosion.tscn")

onready var explosion_timer = $ExplosionTimer
onready var animation_player = $NetworkAnimationPlayer

func _network_spawn(data: Dictionary) -> void:
	fixed_position.x = data['fixed_position_x']
	fixed_position.y = data['fixed_position_y']
	explosion_timer.start()
	animation_player.play("Tick")

func _on_ExplosionTimer_timeout() -> void:
	SyncManager.spawn("Explosion", get_parent(), Explosion, {
		fixed_position_x = fixed_position.x,
		fixed_position_y = fixed_position.y
	})
	SyncManager.despawn(self)
