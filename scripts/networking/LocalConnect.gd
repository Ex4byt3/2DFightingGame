extends Node

const DummyNetworkAdaptor = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")

@onready var message_label = $Messages/MessageLabel
@onready var sync_lost_label = $Messages/SyncLostLabel
@onready var server_player = $ServerPlayer
@onready var client_player = $ClientPlayer
#@onready var johnny = $Johnny


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_match()
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MatchSignalBus.quit_to_menu.connect(_on_quit_to_menu)
	MatchSignalBus.match_over.connect(_on_match_over)


func _on_quit_to_menu() -> void:
	reset_sync_data()


func _on_match_over() -> void:
	reset_sync_data()


# Resets any relevant data for a users connection with another user.
# SyncManager, and NetworkGlobal.
func reset_sync_data() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	SyncManager.reset_network_adaptor()
	
	MenuSignalBus.emit_leave_match()


func setup_match():
	
	if NetworkGlobal.NETWORK_TYPE != 0:
		print("Network type not set to local, exiting...")
		get_tree().exit()
	
	client_player.input_prefix = "player2_"
	SyncManager.network_adaptor = DummyNetworkAdaptor.new()
	SyncManager.start()
