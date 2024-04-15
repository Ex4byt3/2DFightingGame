extends Node

const LOG_FILE_DIRECTORY = "/ProjectDeltaLogs"

@onready var message_label = $Messages/MessageLabel
@onready var sync_lost_label = $Messages/SyncLostLabel
@onready var reset_button = $Messages/ResetButton
#@onready var johnny = $Johnny

var logging_enabled := false


func _ready() -> void:
	_handle_connecting_signals()
	setup_match()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(multiplayer, self, "peer_connected", "_on_network_peer_connected")
	MenuSignalBus._connect_Signals(multiplayer, self, "peer_disconnected", "_on_network_peer_disconnected")
	MenuSignalBus._connect_Signals(multiplayer, self, "server_disconnected", "_on_server_disconnected")
	
	MenuSignalBus._connect_Signals(SyncManager, self, "sync_started", "_on_SyncManager_sync_started")
	MenuSignalBus._connect_Signals(SyncManager, self, "sync_stopped", "_on_SyncManager_sync_stopped")
	MenuSignalBus._connect_Signals(SyncManager, self, "sync_lost", "_on_SyncManager_sync_lost")
	MenuSignalBus._connect_Signals(SyncManager, self, "sync_regained", "_on_SyncManager_sync_regained")
	MenuSignalBus._connect_Signals(SyncManager, self, "sync_error", "_on_SyncManager_sync_error")
	
	MatchSignalBus.quit_to_menu.connect(_on_quit_to_menu)
	MatchSignalBus.match_over.connect(_on_match_over)


func setup_match() -> void:
	
	if NetworkGlobal.NETWORK_TYPE != 1:
		print("Networking type is not set to Enet, quitting...")
		get_tree().exit()
	
	if NetworkGlobal.RPC_IS_HOST:
		on_rpc_server_start(NetworkGlobal.RPC_IP, NetworkGlobal.RPC_PORT)
	else:
		on_rpc_client_start(NetworkGlobal.RPC_IP, NetworkGlobal.RPC_PORT)

func on_rpc_server_start(_host: String, port: int) -> void:
	#johnny.randomize()
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 1)
	multiplayer.multiplayer_peer = peer
	message_label.text = "Listening..."

func on_rpc_client_start(host: String, port: int) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(host, port)
	multiplayer.multiplayer_peer = peer
	message_label.text = "Connecting..."

func _on_network_peer_connected(peer_id: int):
	message_label.text = "Connected!"
	SyncManager.add_peer(peer_id)
	
	$ServerPlayer.set_multiplayer_authority(1)
	if multiplayer.is_server():
		$ClientPlayer.set_multiplayer_authority(peer_id)
	else:
		$ClientPlayer.set_multiplayer_authority(multiplayer.get_unique_id())
	
	if multiplayer.is_server():
		message_label.text = "Starting..."
		#rpc("set_match_rng", {mother_seed = johnny.get_seed()})
		
		# Give a little time to get ping data.
		await get_tree().create_timer(2.0).timeout
		SyncManager.start()

#@rpc("any_peer", "call_local") func set_match_rng(info: Dictionary) -> void:
	#johnny.set_seed(info['mother_seed'])
	#$ClientPlayer.rng.set_seed(johnny.randi())
	#$ServerPlayer.rng.set_seed(johnny.randi())

func _on_network_peer_disconnected(peer_id: int):
	message_label.text = "Disconnected"
	SyncManager.remove_peer(peer_id)

func _on_server_disconnected() -> void:
	_on_network_peer_disconnected(1)

func _on_ResetButton_pressed() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()
	get_tree().reload_current_scene()

func _on_SyncManager_sync_started() -> void:
	message_label.text = "Started!"
	
	if logging_enabled and not SyncReplay.active:
		var dir = DirAccess.open(LOG_FILE_DIRECTORY)
		if not dir:
			DirAccess.make_dir_absolute(LOG_FILE_DIRECTORY)
		
		var datetime = Time.get_datetime_dict_from_system(true)
		var log_file_name = "%04d%02d%02d-%02d%02d%02d-peer-%d.log" % [
			datetime['year'],
			datetime['month'],
			datetime['day'],
			datetime['hour'],
			datetime['minute'],
			datetime['second'],
			SyncManager.network_adaptor.get_unique_id(),
		]
		
		SyncManager.start_logging(LOG_FILE_DIRECTORY + '/' + log_file_name)

func _on_SyncManager_sync_stopped() -> void:
	if logging_enabled:
		SyncManager.stop_logging()
	
	MenuSignalBus.emit_leave_match()

func _on_SyncManager_sync_lost() -> void:
	sync_lost_label.visible = true

func _on_SyncManager_sync_regained() -> void:
	sync_lost_label.visible = false

func _on_SyncManager_sync_error(msg: String) -> void:
	message_label.text = "Fatal sync error: " + msg
	sync_lost_label.visible = false
	
	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()
		
	Steam.closeSessionWithUser("OPPONENT_ID")
	SyncManager.clear_peers()

func setup_match_for_replay(my_peer_id: int, peer_ids: Array, match_info: Dictionary) -> void:
	reset_button.visible = false

func _on_quit_to_menu() -> void:
	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()
	
	SyncManager.stop()
	SyncManager.clear_peers()
	SyncManager.reset_network_adaptor()
	

func _on_match_over() -> void:
	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()
	
	SyncManager.stop()
	SyncManager.clear_peers()
	SyncManager.reset_network_adaptor()
	#MenuSignalBus.emit_leave_match()
