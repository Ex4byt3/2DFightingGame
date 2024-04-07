extends Node

@onready var serverPlayer = get_node("../ServerPlayer")
@onready var clientPlayer = get_node("../ClientPlayer")
@onready var serverHitbox = serverPlayer.get_node("Hitbox")
@onready var clientHitbox = clientPlayer.get_node("Hitbox")
var frame = 0

func _network_process(input: Dictionary) -> void:
	sync_postions()
	sync_hurtboxes()
	sync_hitboxes()
	if !frame:
		check_collisions()
		serverPlayer.hitstop = 0
		clientPlayer.hitstop = 0
		hitbox_game_process()
		frame = player_game_process()
		animate_process()
		# sound_process()
	elif frame > 0:
		serverPlayer.get_node("StateMachine").update_pressed(serverPlayer.input)
		clientPlayer.get_node("StateMachine").update_pressed(clientPlayer.input)
		serverPlayer.hitstopBuffer |= serverPlayer.input # note, input vector buffered this way get's fucky, don't use that
		clientPlayer.hitstopBuffer |= clientPlayer.input
		frame -= 1

# func sound_process() -> void:
# 	serverPlayer.get_node("SoundPlayer")._game_process()
# 	clientPlayer.get_node("SoundPlayer")._game_process()

func animate_process() -> void:
	serverPlayer.get_node("AnimatedSprite2D/FixedAnimationPlayer")._game_process()
	clientPlayer.get_node("AnimatedSprite2D/FixedAnimationPlayer")._game_process()

func check_collisions() -> void:
	clientPlayer.hit_landed = serverPlayer.check_collisions()
	serverPlayer.hit_landed = clientPlayer.check_collisions()

func hitbox_game_process() -> void:
	serverHitbox._game_process()
	clientHitbox._game_process()

func player_game_process() -> int:
	var f : int = 0
	f += serverPlayer._game_process(serverPlayer.input)
	f += clientPlayer._game_process(clientPlayer.input)
	return f

func sync_postions() -> void:
	serverPlayer.sync_to_physics_engine()
	clientPlayer.sync_to_physics_engine()

func sync_hurtboxes() -> void:
	serverPlayer.get_node("HurtBox").sync_to_physics_engine()
	clientPlayer.get_node("HurtBox").sync_to_physics_engine()
	serverPlayer.get_node("PushBox").sync_to_physics_engine()
	clientPlayer.get_node("PushBox").sync_to_physics_engine()

func sync_hitboxes() -> void:
	serverHitbox.sync_to_physics_engine()
	clientHitbox.sync_to_physics_engine()

func _save_state() -> Dictionary:
	return {
		frame = frame,
	}

func _load_state(loadState: Dictionary) -> void:
	frame = loadState["frame"]
