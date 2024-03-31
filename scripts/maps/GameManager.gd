extends Node

@onready var serverPlayer = get_node("../ServerPlayer")
@onready var clientPlayer = get_node("../ClientPlayer")
var frame = 0

func _network_process(input: Dictionary) -> void:
	sync_postions()
	sync_hurtboxes()
	sync_hitboxes()
	check_collisions()
	if !frame:
		serverPlayer.hitstop = 0
		clientPlayer.hitstop = 0
		hitbox_game_process()
		frame = player_game_process()
		animate_process()
	elif frame > 0:
		serverPlayer.get_node("StateMachine").update_pressed(serverPlayer.input)
		clientPlayer.get_node("StateMachine").update_pressed(clientPlayer.input)
		if serverPlayer.input.size() > 2:
			serverPlayer.hitstopBuffer = serverPlayer.input
			# print(str(serverPlayer.hitstopBuffer))
		if clientPlayer.input.size() > 2:
			clientPlayer.hitstopBuffer = clientPlayer.input
		frame -= 1

# func sound_process() -> void:
# 	serverPlayer.get_node("SoundPlayer")._game_process()
# 	clientPlayer.get_node("SoundPlayer")._game_process()

func animate_process() -> void:
	serverPlayer.get_node("FixedAnimationPlayer")._game_process()
	clientPlayer.get_node("FixedAnimationPlayer")._game_process()

func check_collisions() -> void:
	serverPlayer.check_collisions()
	clientPlayer.check_collisions()

func hitbox_game_process() -> void:
	var hitboxes = null
	hitboxes = serverPlayer.get_node("SpawnHitbox").get_children()
	for hitbox in hitboxes:
		hitbox._game_process()
	hitboxes = clientPlayer.get_node("SpawnHitbox").get_children()
	for hitbox in hitboxes:
		hitbox._game_process()

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
	var hitboxes = null
	hitboxes = serverPlayer.get_node("SpawnHitbox").get_children()
	for hitbox in hitboxes:
		hitbox.sync_to_physics_engine()
	hitboxes = clientPlayer.get_node("SpawnHitbox").get_children()
	for hitbox in hitboxes:
		hitbox.sync_to_physics_engine()

func _save_state() -> Dictionary:
	return {
		frame = frame,
	}

func _load_state(loadState: Dictionary) -> void:
	frame = loadState["frame"]