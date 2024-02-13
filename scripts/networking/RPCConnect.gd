extends Node

const LOG_FILE_DIRECTORY = 'res://assets/resources/logs'

onready var message_label = $Messages/MessageLabel
onready var sync_lost_label = $Messages/SyncLostLabel
onready var reset_button = $Messages/ResetButton
onready var johnny = $Johnny

var logging_enabled := true

func _ready() -> void:
	SettingsSignalBus._connect_Signals(get_tree(), self, "network_peer_connected", "_on_network_peer_connected")
	SettingsSignalBus._connect_Signals(get_tree(), self, "network_peer_disconnected", "_on_network_peer_disconnected")
	SettingsSignalBus._connect_Signals(get_tree(), self, "server_disconnected", "_on_server_disconnected")
#	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
#	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
#	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	
	SettingsSignalBus._connect_Signals(SyncManager, self, "sync_started", "_on_SyncManager_sync_started")
	SettingsSignalBus._connect_Signals(SyncManager, self, "sync_stopped", "_on_SyncManager_sync_stopped")
	SettingsSignalBus._connect_Signals(SyncManager, self, "sync_lost", "_on_SyncManager_sync_lost")
	SettingsSignalBus._connect_Signals(SyncManager, self, "sync_regained", "_on_SyncManager_sync_regained")
	SettingsSignalBus._connect_Signals(SyncManager, self, "sync_error", "_on_SyncManager_sync_error")
#	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
#	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")
#	SyncManager.connect("sync_lost", self, "_on_SyncManager_sync_lost")
#	SyncManager.connect("sync_regained", self, "_on_SyncManager_sync_regained")
#	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")
	
	setup_match()
	
func setup_match() -> void:
	
	if NetworkGlobal.NETWORK_TYPE != 1:
		print("Networking type is not set to Enet, quitting...")
		get_tree().exit()
	
	if NetworkGlobal.RPC_IS_HOST:
		on_rpc_server_start(NetworkGlobal.RPC_IP, NetworkGlobal.RPC_PORT)
	else:
		on_rpc_client_start(NetworkGlobal.RPC_IP, NetworkGlobal.RPC_PORT)

func on_rpc_server_start(_host: String, port: int) -> void:
	johnny.randomize()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, 1)
	get_tree().network_peer = peer
	message_label.text = "Listening..."

func on_rpc_client_start(host: String, port: int) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host, port)
	get_tree().network_peer = peer
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
		rpc("set_match_rng", {mother_seed = johnny.get_seed()})
		
		# Give a little time to get ping data.
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start()

remotesync func set_match_rng(info: Dictionary) -> void:
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
	reset_button.visible = false
