extends Node

@onready var serverPlayer = get_node("../ServerPlayer")
@onready var clientPlayer = get_node("../ClientPlayer")
var frame = 0
var serverHitstopBuffer = {}
var clientHitstopBuffer = {}

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
		if serverPlayer.input.size() > 2:
			serverHitstopBuffer = serverPlayer.hitstopBuffer
			print(str(serverHitstopBuffer))
		if clientPlayer.input.size() > 2:
			clientHitstopBuffer = clientPlayer.hitstopBuffer
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
	var server_hitstop_buffer = {}
	var client_hitstop_buffer = {}
	for input in serverHitstopBuffer:
		server_hitstop_buffer[input] = serverHitstopBuffer[input]
	for input in clientHitstopBuffer:
		client_hitstop_buffer[input] = clientHitstopBuffer[input]
	return {
		frame = frame,
		serverHitstopBuffer = server_hitstop_buffer,
		clientHitstopBuffer = client_hitstop_buffer
	}

func _load_state(loadState: Dictionary) -> void:
	frame = loadState["frame"]
	serverHitstopBuffer = {}
	for input in loadState["serverHitstopBuffer"]:
		serverHitstopBuffer[input] = loadState["serverHitstopBuffer"][input]
	clientHitstopBuffer = {}
	for input in loadState["clientHitstopBuffer"]:
		clientHitstopBuffer[input] = loadState["clientHitstopBuffer"][input]
