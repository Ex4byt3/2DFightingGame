extends Node2D
class_name MatchController

# Onready variable to preload the MapHolder scene
@onready var map_holder = preload("res://scenes/maps/MapHolder.tscn")

var map
var host_character_id: String = "Robot"
var client_character_id: String = "Robot"
var host_character
var client_character

var is_host: bool
var host_ready: bool
var client_ready: bool
var in_combat: bool

var selected_map: String = "TheBox"

# Dictionary containing for match settings
var match_settings: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


##################################################
# ONREADY FUNCTIONS
##################################################
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "create_match", "_create_match")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "leave_match", "_leave_match")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_match_settings", "_update_match_settings")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "round_over", "_round_over")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "player_ready", "_player_ready")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "character_selected", "_on_character_selected")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "debug_name", "_debug_name")


##################################################
# MATCH CONTROL FUNCTIONS
##################################################
func _create_match() -> void:
	_setup_combat()


func _leave_match() -> void: ## TODO: Get randy to fix this
	match NetworkGlobal.NETWORK_TYPE:
		NetworkGlobal.NetworkType.ENET:
			var peer = multiplayer.multiplayer_peer
			if peer:
				peer.close()
		NetworkGlobal.NetworkType.STEAM:
			Steam.closeSessionWithUser("STEAM_OPP_ID")
		_:
			print("Sync error, but not in a networked game")
	
	SyncManager.stop()
	SyncManager.clear_peers()
	SyncManager.reset_network_adaptor()
	
	for child in get_children():
		child.queue_free()


func _update_match_settings(new_settings:Dictionary) -> void:
	match_settings = new_settings
	MenuSignalBus.emit_apply_match_settings(match_settings)


func _player_ready(player_id: String) -> void:
	match player_id:
		"ServerPlayer":
			host_ready = not host_ready
		"ClientPlayer":
			client_ready = not client_ready
	
	if host_ready and client_ready:
		MenuSignalBus.emit_start_match()


func _on_character_selected(character_id: String, selected_by: Dictionary) -> void:
	if selected_by.Host == true:
		host_character_id = character_id
	if selected_by.Client == true:
		client_character_id = character_id


##################################################
# COMBAT CONTROL FUNCTIONS
##################################################
func _setup_combat() -> void:
	var new_map_holder = map_holder.instantiate()
	add_child(new_map_holder)
	MenuSignalBus.emit_send_match_settings()


func _start_combat() -> void:
	pass


func _combat_over() -> void:
	pass


##################################################
# ROUND CONTROL FUNCTIONS
##################################################
func _round_over() -> void:
	host_ready = false
	client_ready = false
	print("[COMBAT] Round has ended")
	
	if get_child(0).get_child(0).get_node("ServerPlayer").num_lives > 0 and get_child(0).get_child(0).get_node("ClientPlayer").num_lives > 0:
		print("[COMBAT] Starting new round...")
		MenuSignalBus.emit_setup_round()
	else:
		MenuSignalBus.emit_combat_over()


func _debug_name(player_id: String) -> void:
	print("[DEBUG] player id: " + player_id)
