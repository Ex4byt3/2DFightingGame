extends Node2D

const DummyNetworkAdaptor = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")
const SteamNetworkAdaptor = preload("res://addons/godot-rollback-netcode/SteamNetworkAdaptor.gd")

onready var main_menu = $CanvasLayer/MainMenu
onready var connection_panel = $CanvasLayer/ConnectionPanel
onready var id_field = $CanvasLayer/ConnectionPanel/GridContainer/SteamIDField
onready var message_label = $CanvasLayer/MessageLabel
onready var sync_lost_label = $CanvasLayer/SyncLostLabel
onready var reset_button = $CanvasLayer/ResetButton
onready var johnny = $Johnny

const LOG_FILE_DIRECTORY = 'C:/Users/jackd/Downloads/somelogs'

var logging_enabled := true

var emptyData: PoolByteArray = [1]

enum SYNC_TYPE {
	HANDSHAKE,
	CONNECT,
	START,
	STOP,
}

func _ready() -> void:
	
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")
	SyncManager.connect("sync_lost", self, "_on_SyncManager_sync_lost")
	SyncManager.connect("sync_regained", self, "_on_SyncManager_sync_regained")
	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")
	
	Steam.connect("network_messages_session_request", self, "_on_network_messages_session_request")
	Steam.setIdentitySteamID64("OPPONENT_ID", SteamGlobal.OPPONENT_ID)
	
func _process(delta):
	var listOfMessages = Steam.receiveMessagesOnChannel(1, 999) #channel 1 #read up to 999 messages in buffer
	for message in listOfMessages:
		process_networking_message(message)


# Responsible for creating packets to be sent over the steam network.
# PoolByteArrays are in the format of [Header: 1 byte, Data: n bytes]
func create_networking_message(header: int, data) -> PoolByteArray:
	
	var packet: PoolByteArray = []
	packet.append(header)
	
	# Checking to see if the data is already a PoolByteArray,
	# if not then we convert it to a PoolByteArray
	if typeof(data) != TYPE_RAW_ARRAY:
		data = var2bytes(data)
	
	packet.append_array(data)
	return packet

func process_networking_message(msg: Dictionary) -> void:
	# TODO: Figure out how we can incorporate message identitys into the adaptor (if needed)
	# sender_id might already be an int?
	print(typeof(msg["identity"]))
	print(msg["identity"])
	
	var sender_id = msg["identity"].to_int()
	var packet = msg["payload"]
	
	var header = packet[0]
	var data = packet.subarray(1, len(packet) - 1)
	
	match header:
		SYNC_TYPE.HANDSHAKE:
			print("SYNC,HANDSHAKE")
			connect_to_server()
		SYNC_TYPE.CONNECT:
			print("SYNC,CONNECT")
			network_peer_connected()
		SYNC_TYPE.START:
			print("SYNC,START")
			network_peer_connected()
		SYNC_TYPE.STOP:
			print("SYNC,STOP")
			pass
		_: # Default
			print("Could not match packet types from message")

func connect_to_server() -> void:
	if SteamGlobal.IS_HOST:
		return
	var packet = create_networking_message(SYNC_TYPE.CONNECT, emptyData)
	Steam.sendMessageToUser("OPPONENT_ID", packet, 0, 0)

# Runs on both clients when the users establish a connection
func network_peer_connected():
	
	message_label.text = "Connected!"
	SyncManager.add_peer(SteamGlobal.OPPONENT_ID)
	
	$ServerPlayer.set_meta("IS_NETWORK_MASTER", SteamGlobal.IS_HOST)
	$ClientPlayer.set_meta("IS_NETWORK_MASTER", not SteamGlobal.IS_HOST)
	
	if SteamGlobal.IS_HOST:
		message_label.text = "Starting..."
		#rpc("setup_match", {mother_seed = johnny.get_seed()})
		var setup_packet = create_networking_message(SYNC_TYPE.START, {mother_seed = johnny.get_seed()})
		Steam.sendMessageToUser("OPPONENT_ID", setup_packet, 0, 1)
		
		# Give a little time to get ping data.
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start()
		
func network_peer_disconnected(peer_id: int):
	message_label.text = "Disconnected"
	SyncManager.remove_peer(peer_id)

func setup_match(info: Dictionary) -> void:
	johnny.set_seed(info['mother_seed'])
	$ClientPlayer.rng.set_seed(johnny.randi())
	$ServerPlayer.rng.set_seed(johnny.randi())
	
func reset_match() -> void:
	pass

func _on_server_disconnected() -> void:
	network_peer_disconnected(SteamGlobal.OPPONENT_ID)

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
	
	#var peer = get_tree().network_peer
	#if peer:
		#peer.close_connection()
		
	Steam.closeSessionWithUser("OPPONENT_ID")
	SyncManager.clear_peers()

func setup_match_for_replay(my_peer_id: int, peer_ids: Array, match_info: Dictionary) -> void:
	main_menu.visible = false
	connection_panel.visible = false
	reset_button.visible = false


func _on_LocalButton_pressed() -> void:
	$ClientPlayer.input_prefix = "player2_"
	main_menu.visible = false
	SteamGlobal.IS_HOST = true
	SyncManager.network_adaptor = DummyNetworkAdaptor.new()
	SyncManager.start()

func _on_OnlineButton_pressed() -> void:
	connection_panel.popup_centered()
	SyncManager.reset_network_adaptor()
	SyncManager.network_adaptor = SteamNetworkAdaptor.new()
	
# Create a server when pressed, waiting for a client to connect
func _on_ServerButton_pressed() -> void:
	johnny.randomize()
	#var peer = NetworkedMultiplayerENet.new()
	#peer.create_server(int(port_field.text), 1)
	#get_tree().network_peer = peer
	SteamGlobal.IS_HOST = true
	main_menu.visible = false
	connection_panel.visible = false
	message_label.text = "Listening..."

# Create a client when pressed, attempting to connect to a server
func _on_ClientButton_pressed() -> void:
	#var peer = NetworkedMultiplayerENet.new()
	#peer.create_client(host_field.text, int(port_field.text))
	#get_tree().network_peer = peer
	var packet = create_networking_message(SYNC_TYPE.CONNECT, emptyData)
	Steam.sendMessageToUser("OPPONENT_ID", packet, 0, 0)
	
	main_menu.visible = false
	connection_panel.visible = false
	message_label.text = "Connecting..."
	
func _on_ResetButton_pressed() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	SyncManager.reset_network_adaptor()
	#var peer = get_tree().network_peer
	#if peer:
		#peer.close_connection()
	
	Steam.closeSessionWithUser("OPPONENT_ID")
	get_tree().reload_current_scene()


# When one peer attempts to communicate with another peer directly, they need to 
# either send an arbitrary message back as a handshake, or accept their inital message
# as a session request. In this example, we accept the other users session request.

# TODO: Cache the requesting users steam ID, Prompt the user to see if they
# want to play, and if they say yes, then establish the connection
# TLDR: HANDSHAKE!
func _on_network_messages_session_request(sender_id: String):
	
	if not SteamGlobal.IS_HOST:
		return
	
	var sender_id_int = sender_id.to_int()
	
	# Identity_Reference is equal to the steam id as a string, assigned to the
	# int value of the steam id
	Steam.setIdentitySteamID64("OPPONENT_ID", sender_id_int)
	Steam.acceptSessionWithUser(sender_id)
	
	# We don't know what this user wants yet, but we're going to tell them
	# we accepted their request.
	var packet = create_networking_message(SYNC_TYPE.HANDSHAKE, emptyData)
	Steam.sendMessageToUser("OPPONENT_ID", packet, 0, 0)
	
	print("Steam ID of messager: " + sender_id)
