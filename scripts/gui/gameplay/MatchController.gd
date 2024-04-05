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
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "create_match", "_create_match")
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "leave_match", "_leave_match")
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_match_settings", "_update_match_settings")
	MenuSignalBus.create_match.connect(_create_match)
	MenuSignalBus.leave_match.connect(_leave_match)
	MenuSignalBus.update_match_settings.connect(_update_match_settings)
	
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "round_over", "_round_over")
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "player_ready", "_player_ready")
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "character_selected", "_on_character_selected")
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "debug_name", "_debug_name")
	#MenuSignalBus.round_over.connect(_round_over)
	#MenuSignalBus.player_ready.connect(_player_ready)
	#MenuSignalBus.start_round.connect(_start_round)
	
	MatchSignalBus.combat_start.connect(_combat_start)
	#MatchSignalBus.combat_stop.connect()
	MatchSignalBus.round_start.connect(_round_start)
	MatchSignalBus.round_stop.connect(_round_stop)


##################################################
# MATCH CONTROL FUNCTIONS
##################################################
func _create_match() -> void:
	if MatchData.local_player_ready and MatchData.opposing_player_ready:
		_setup_combat()


# TODO: Move networking logic
func _leave_match() -> void: 
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


##################################################
# COMBAT CONTROL FUNCTIONS
##################################################
func _setup_combat() -> void:
	MatchData.player_control_disabled = true
	var new_map_holder = map_holder.instantiate()
	add_child(new_map_holder)
	MenuSignalBus.emit_send_match_settings()
	#MenuSignalBus.emit_apply_match_settings(match_settings)
	MatchSignalBus.emit_combat_start()


func _combat_start() -> void:
	#await MatchSignalBus.banner_done
	MatchSignalBus.emit_round_start()


func _combat_stop() -> void:
	await MatchSignalBus.banner_done
	MenuSignalBus.emit_leave_match()
	print("[SYSTEM][COMBAT] Combat has been stopped")


##################################################
# ROUND CONTROL FUNCTIONS
##################################################
func _round_start() -> void:
	# TODO: Move map and character reset functions here if possible
	MatchData.player_control_disabled = false


func _round_stop() -> void:
	#MatchData.local_player_ready = false
	#MatchData.opposing_player_ready = false
	
	# Disable player control and wait for the banners to
	# finish diplaying on screen
	MatchData.player_control_disabled = true
	
	
	if get_child(0).get_child(0).get_node("ServerPlayer").num_lives > 0 and get_child(0).get_child(0).get_node("ClientPlayer").num_lives > 0:
	#if find_child("ServerPlayer").num_lives > 0 and find_child("ClientPlayer").num_lives > 0:
		#print("[SYSTEM][COMBAT] Starting new round...")
		MatchSignalBus._emit_setup_round()
		#await MatchSignalBus.banner_done
		_round_start()
	else:
		#print("[SYSTEM][COMBAT] Stopping combat...")
		_combat_stop()


##################################################
# HELPER FUNCTIONS
##################################################
func _update_match_settings(new_settings:Dictionary) -> void:
	match_settings = new_settings
	MenuSignalBus.emit_apply_match_settings(match_settings)


func _player_ready(player_id: String) -> void:
	print("[SYSTEM] player ready: " + player_id)
	match player_id:
		"ServerPlayer":
			host_ready = true
		"ClientPlayer":
			client_ready = true
	
	if host_ready and client_ready:
		MenuSignalBus.emit_start_round()


