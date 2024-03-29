extends Node

@onready var serverPlayer = get_node("../ServerPlayer")
@onready var clientPlayer = get_node("../ClientPlayer")

func _network_process(input: Dictionary) -> void:
	sync_postions()
	sync_hurtboxes()
	sync_hitboxes()
	check_collisions()
	hitbox_game_process()
	player_game_process()
	animate_process()

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

func player_game_process() -> void:
	serverPlayer._game_process(serverPlayer.input)
	clientPlayer._game_process(clientPlayer.input)

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
