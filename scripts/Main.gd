extends Node2D

const DummyNetworkAdaptor = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")
const SteamNetworkAdaptor = preload("res://scripts/networking/SteamNetworkAdaptor.gd")

const LOG_FILE_DIRECTORY = 'res://logs'

onready var main_menu = $CanvasLayer/MainMenu
onready var rpc_connection_panel = $CanvasLayer/ConnectionPanel
onready var host_field = $CanvasLayer/ConnectionPanel/GridContainer/HostField
onready var port_field = $CanvasLayer/ConnectionPanel/GridContainer/PortField
onready var steam_connection_panel = $CanvasLayer/SteamConnectionPanel
onready var message_label = $CanvasLayer/MessageLabel
onready var sync_lost_label = $CanvasLayer/SyncLostLabel
onready var reset_button = $CanvasLayer/ResetButton
onready var johnny = $Johnny

var logging_enabled := true


func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")
	SyncManager.connect("sync_lost", self, "_on_SyncManager_sync_lost")
	SyncManager.connect("sync_regained", self, "_on_SyncManager_sync_regained")
	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")
	
	GameSignalBus.connect("rpc_server_start", self, "on_rpc_server_start")
	GameSignalBus.connect("rpc_client_start", self, "on_rpc_client_start")
	GameSignalBus.connect("steam_server_start", self, "on_steam_server_start")
	GameSignalBus.connect("steam_client_start", self, "on_steam_client_start")
	GameSignalBus.connect("local_play_start", self, "on_local_play_start")


func on_rpc_server_start(host: String, port: int) -> void:
	main_menu.visible = false
	rpc_connection_panel.visible = false
	
	johnny.randomize()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, 1)
	get_tree().network_peer = peer
	
	message_label.text = "Listening..."


func on_rpc_client_start(host: String, port: int) -> void:
	main_menu.visible = false
	rpc_connection_panel.visible = false
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host, port)
	get_tree().network_peer = peer
	
	message_label.text = "Connecting..."


func on_steam_server_start(steamid: int) -> void:
	pass


func on_steam_client_start(steamid: int) -> void:
	pass


func on_local_play_start() -> void:
	print("local")
	$ClientPlayer.input_prefix = "player2_"
	main_menu.visible = false
	SyncManager.network_adaptor = DummyNetworkAdaptor.new()
	SyncManager.start()


func _on_ServerButton_pressed() -> void:
	johnny.randomize()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(int(port_field.text), 1)
	get_tree().network_peer = peer
	main_menu.visible = false
	rpc_connection_panel.visible = false
	message_label.text = "Listening..."


func _on_ClientButton_pressed() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host_field.text, int(port_field.text))
	get_tree().network_peer = peer
	main_menu.visible = false
	rpc_connection_panel.visible = false
	message_label.text = "Connecting..."


func _on_network_peer_connected(peer_id: int):
	message_label.text = "Connected!"
	SyncManager.add_peer(peer_id)
	
	$ServerPlayer.set_network_master(1)
	if get_tree().is_network_server():
		$ClientPlayer.set_network_master(peer_id)
	else:
		$ClientPlayer.set_network_master(get_tree().get_network_unique_id())
	
	if get_tree().is_network_server():
		message_label.text = "Starting..."
		rpc("setup_match", {mother_seed = johnny.get_seed()})
		
		# Give a little time to get ping data.
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start()


remotesync func setup_match(info: Dictionary) -> void:
	johnny.set_seed(info['mother_seed'])
	$ClientPlayer.rng.set_seed(johnny.randi())
	$ServerPlayer.rng.set_seed(johnny.randi())


func _on_network_peer_disconnected(peer_id: int):
	message_label.text = "Disconnected"
	SyncManager.remove_peer(peer_id)


func _on_server_disconnected() -> void:
	_on_network_peer_disconnected(1)


func _on_ResetButton_pressed() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	var peer = get_tree().network_peer
	if peer:
		peer.close_connection()
	get_tree().reload_current_scene()


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
	
	var peer = get_tree().network_peer
	if peer:
		peer.close_connection()
		
	Steam.closeSessionWithUser("OPPONENT_ID")
	SyncManager.clear_peers()


func setup_match_for_replay(my_peer_id: int, peer_ids: Array, match_info: Dictionary) -> void:
	main_menu.visible = false
	rpc_connection_panel.visible = false
	reset_button.visible = false


func _on_LocalButton_pressed() -> void:
	$ClientPlayer.input_prefix = "player2_"
	main_menu.visible = false
	SyncManager.network_adaptor = DummyNetworkAdaptor.new()
	SyncManager.start()


func _on_RPCButton_pressed():
	rpc_connection_panel.popup_centered()
	SyncManager.reset_network_adaptor()


func _on_SteamButton_pressed():
	steam_connection_panel.popup_centered()
	SyncManager.reset_network_adaptor()
	SyncManager.network_adaptor = SteamNetworkAdaptor.new()
