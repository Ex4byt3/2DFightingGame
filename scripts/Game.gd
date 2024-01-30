extends Node2D

const LOG_FILE_DIRECTORY = 'res://logs'

var DummyNetworkAdaptor = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")
var SteamNetworkAdaptor = preload("res://scripts/networking/SteamNetworkAdaptor.gd")

var SteamConnect = preload("res://scripts/networking/SteamConnect.gd")
var RpcConnect = preload("res://scripts/networking/RPCConnect.gd")
var LocalConnect = preload("res://scripts/networking/LocalConnect.gd")

onready var message_label = $Messages/MessageLabel
onready var sync_lost_label = $Messages/SyncLostLabel
onready var reset_button = $Messages/ResetButton
onready var client_player = $ClientPlayer
onready var server_player = $ServerPlayer
onready var johnny = $Johnny

enum NETWORK_TYPE {
	LOCAL,
	ENET,
	STEAM,
}

var logging_enabled := true


func _ready() -> void:
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")
	SyncManager.connect("sync_lost", self, "_on_SyncManager_sync_lost")
	SyncManager.connect("sync_regained", self, "_on_SyncManager_sync_regained")
	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")
	
	setup_match()
	
func setup_match():
	match NetworkGlobal.NETWORK_TYPE:
		NETWORK_TYPE.LOCAL:
			client_player.input_prefix = "player2_"
			SyncManager.network_adaptor = DummyNetworkAdaptor.new()
			SyncManager.start()
		NETWORK_TYPE.ENET:
			RpcConnect.setup_match()
		NETWORK_TYPE.STEAM:
			SteamConnect.setup_match()
		_:
			print("Could not match networking type to scene")

func _on_SyncManager_sync_started() -> void:
	message_label.text = "Started!"
	
	if logging_enabled and not SyncReplay.active:
		var dir = Directory.new()
		if not dir.dir_exists(LOG_FILE_DIRECTORY):
			dir.make_dir(LOG_FILE_DIRECTORY)
		
		var datetime = OS.get_datetime(true)
		var log_file_name = "%04d%02d%02d-%02d%02d%02d-peer-%d.log" % [
			datetime['year'],
			datetime['month'],
			datetime['day'],
			datetime['hour'],
			datetime['minute'],
			datetime['second'],
			SyncManager.network_adaptor.get_network_unique_id(),
		]
		
		SyncManager.start_logging(LOG_FILE_DIRECTORY + '/' + log_file_name)

func _on_SyncManager_sync_stopped() -> void:
	if logging_enabled:
		SyncManager.stop_logging()

func _on_SyncManager_sync_lost() -> void:
	sync_lost_label.visible = true

func _on_SyncManager_sync_regained() -> void:
	sync_lost_label.visible = false

func _on_SyncManager_sync_error(msg: String) -> void:
	message_label.text = "Fatal sync error: " + msg
	sync_lost_label.visible = false
	
	match NetworkGlobal.NETWORK_TYPE:
		NETWORK_TYPE.ENET:
			var peer = get_tree().network_peer
			if peer:
				peer.close_connection()
		NETWORK_TYPE.STEAM:
			Steam.closeSessionWithUser("OPPONENT_ID")
		_:
			print("Sync error, but not in a networked game")
			
	SyncManager.clear_peers()
