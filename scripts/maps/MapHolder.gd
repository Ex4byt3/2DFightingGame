extends MatchController


# Onready variables for the different networking scripts
@onready var LocalConnect = preload("res://scripts/networking/LocalConnect.gd")
@onready var RPCConnect = preload("res://scripts/networking/RPCConnect.gd")
@onready var SteamConnect = preload("res://scripts/networking/SteamConnect.gd")

@onready var GameManager = preload("res://scripts/maps/GameManager.gd")

@onready var combat_messages = preload("res://scenes/gui/gameplay/CombatMessages.tscn")
@onready var stage_camera = preload("res://scenes/maps/StageCamera.tscn")
@onready var gameplay_ui = preload("res://scenes/gui/gameplay/GameplayUI.tscn")


var character_starting_pos_y = 80084992
var host_starting_pos_x = 64749568
var client_starting_pos_x = 99287040


func _ready():
	_handle_connecting_signals()
	
	# Set the map for use in combat
	_set_map()
	
	# Set up the map
	_add_host_character()
	_add_client_character()
	_add_combat_messages()
	_add_stage_camera()
	_add_match_ui()
	_add_game_manager()
	
	# Set the network script to be used for combat
	_set_network_script()

	map._ready() # call the _ready function of the map
	map.set_process(true) # start the map's process function


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "setup_round", "_reset_character_position")


# The selected map is loaded, instanced then added as a child
# The map is renamed to "Map"
func _set_map():
	map = load("res://scenes/maps/" + selected_map + ".tscn")
	map = map.instantiate()
	add_child(map)
	map.name = "Map" # change the maps name to "Map" reguardless of what map it is


func _add_combat_messages() -> void:
	var new_message_overlay = combat_messages.instantiate()
	map.add_child(new_message_overlay)


func _add_match_ui() -> void:
	var new_canvas = CanvasLayer.new()
	var new_overlay = gameplay_ui.instantiate()
	new_canvas.add_child(new_overlay)
	map.add_child(new_canvas)


func _add_stage_camera() -> void:
	var new_camera = stage_camera.instantiate()
	map.add_child(new_camera)


func _add_game_manager() -> void:
	var game_manager = Node.new()
	game_manager.name = "GameManager"
	game_manager.add_to_group("network_sync")
	game_manager.set_script(GameManager)
	map.add_child(game_manager)


func get_character_scene_path(character_id: String):
	return "res://scenes/characters/" + character_id + ".tscn"


func _add_host_character() -> void:
	host_character = load(get_character_scene_path(host_character_id))
	host_character = host_character.instantiate()
	host_character.fixed_position_x = host_starting_pos_x
	host_character.fixed_position_y = character_starting_pos_y
	host_character.name = "ServerPlayer"
	map.add_child(host_character)


func _add_client_character() -> void:
	client_character = load(get_character_scene_path(client_character_id))
	client_character = client_character.instantiate()
	client_character.fixed_position_x = client_starting_pos_x
	client_character.fixed_position_y = character_starting_pos_y
	client_character.name = "ClientPlayer"
	map.add_child(client_character)


func _reset_character_position() -> void:
	print("[COMBAT] Reseting character positions...")
	host_character.fixed_position_x = host_starting_pos_x
	host_character.fixed_position_y = character_starting_pos_y
	client_character.fixed_position_x = client_starting_pos_x
	client_character.fixed_position_y = character_starting_pos_y


func _set_network_script() -> void:
	match NetworkGlobal.NETWORK_TYPE:
		NetworkGlobal.NetworkType.LOCAL:
			map.set_script(LocalConnect)
		NetworkGlobal.NetworkType.ENET:
			map.set_script(RPCConnect)
		NetworkGlobal.NetworkType.STEAM:
			map.set_script(SteamConnect)
		_:
			print("error: No network type selected.")

