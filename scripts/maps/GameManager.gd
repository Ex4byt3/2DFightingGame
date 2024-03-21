extends Node

@onready var serverPlayer = get_node("../ServerPlayer")
@onready var clientPlayer = get_node("../ClientPlayer")

# character script fills in the input dictionary
var server_input = {}
var client_input = {}

func _network_process(input: Dictionary) -> void:
	sync_postions()
	sync_hurtboxes()
	sync_hitboxes()

	hitbox_game_process()
	player_game_process()

func hitbox_game_process() -> void:
	var hitboxes = null
	hitboxes = serverPlayer.get_node("SpawnHitbox").get_children()
	for hitbox in hitboxes:
		hitbox._game_process()
	hitboxes = clientPlayer.get_node("SpawnHitbox").get_children()
	for hitbox in hitboxes:
		hitbox._game_process()

func player_game_process() -> void:
	serverPlayer._game_process(server_input)
	clientPlayer._game_process(client_input)

func sync_postions() -> void:
	serverPlayer.sync_to_physics_engine()
	clientPlayer.sync_to_physics_engine()

func sync_hurtboxes() -> void:
	serverPlayer.get_node("HurtBox").sync_to_physics_engine()
	clientPlayer.get_node("HurtBox").sync_to_physics_engine()

func sync_hitboxes() -> void:
	var hitboxes = null
	hitboxes = serverPlayer.get_node("SpawnHitbox").get_children()
	for hitbox in hitboxes:
		hitbox.sync_to_physics_engine()
	hitboxes = clientPlayer.get_node("SpawnHitbox").get_children()
	for hitbox in hitboxes:
		hitbox.sync_to_physics_engine()