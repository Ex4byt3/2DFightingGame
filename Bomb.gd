extends Node2D

const Explosion = preload("res://Explosion.tscn")

onready var explosion_timer = $ExplosionTimer
onready var animation_player = $NetworkAnimationPlayer

func _network_spawn(data: Dictionary) -> void:
	global_position = data['fixed_position']
	explosion_timer.start()
	animation_player.play("Tick")

func _on_ExplosionTimer_timeout() -> void:
	SyncManager.spawn("Explosion", get_parent(), Explosion, {
		position = global_position,
	})
	SyncManager.despawn(self)
