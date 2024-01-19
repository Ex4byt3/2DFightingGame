extends Node

const DummyNetworkAdaptor = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")
const SteamNetworkAdaptor = preload("res://networking/SteamNetworkAdaptor.gd")

onready var message_label = $Messages/MessageLabel
onready var sync_lost_label = $Messages/SyncLostLabel
onready var server_player = $ServerPlayer
onready var client_player = $ClientPlayer
onready var johnny = $Johnny

const LOG_FILE_DIRECTORY = 'E:/godot-logs'

var logging_enabled := true
var emptyData: PoolByteArray = [1]

enum NETWORK_TYPE {
	LOCAL,
	ENET,
	STEAM,
}

enum SYNC_TYPE {
	HANDSHAKE,
	CONNECT,
	START,
	STOP,
}

func _ready() -> void:
	Steam.connect("network_messages_session_request", self, "_on_network_messages_session_request")
	Steam.setIdentitySteamID64("OPP_STEAM_ID", NetworkGlobal.OPP_STEAM_ID)
	
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")
	SyncManager.connect("sync_lost", self, "_on_SyncManager_sync_lost")
	SyncManager.connect("sync_regained", self, "_on_SyncManager_sync_regained")
	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")
	
func _process(delta):
	var listOfMessages = Steam.receiveMessagesOnChannel(1, 999) #channel 1 #read up to 999 messages in buffer
	for message in listOfMessages:
		process_networking_message(message)
		
func setup_match() -> void:
	
	if NetworkGlobal.NETWORK_TYPE != 2:
		print("Networking type is not set to STEAM, aborting...")
		get_tree().quit()
	
	if NetworkGlobal.IS_STEAM_HOST:
		johnny.randomize()
		message_label.text = "Listening..."
	else:
		var packet = create_networking_message(SYNC_TYPE.HANDSHAKE, emptyData)
		Steam.sendMessageToUser("OPP_STEAM_ID", packet, 0, 1)


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
			set_match_rng(bytes2var(data))
			network_peer_connected()
		SYNC_TYPE.STOP:
			print("SYNC,STOP")
			pass
		_: # Default
			print("Could not match packet types from message")

func connect_to_server() -> void:
	if NetworkGlobal.IS_HOST:
		return
	var packet = create_networking_message(SYNC_TYPE.CONNECT, emptyData)
	Steam.sendMessageToUser("OPP_STEAM_ID", packet, 0, 1)

# Runs on both clients when the users establish a connection
func network_peer_connected():
	
	message_label.text = "Connected!"
	SyncManager.add_peer(NetworkGlobal.OPP_STEAM_ID)
	
	server_player.set_meta("IS_NETWORK_MASTER", NetworkGlobal.IS_STEAM_HOST)
	client_player.set_meta("IS_NETWORK_MASTER", not NetworkGlobal.IS_STEAM_HOST)
	
	if NetworkGlobal.IS_HOST:
		message_label.text = "Starting..."
		#rpc("setup_match", {mother_seed = johnny.get_seed()})
		var setup_packet = create_networking_message(SYNC_TYPE.START, {mother_seed = johnny.get_seed()})
		Steam.sendMessageToUser("OPP_STEAM_ID", setup_packet, 0, 1)
		
		# Give a little time to get ping data.
		set_match_rng({mother_seed = johnny.get_seed()})
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start()
		
func network_peer_disconnected(peer_id: int):
	message_label.text = "Disconnected"
	SyncManager.remove_peer(peer_id)

func set_match_rng(info: Dictionary) -> void:
	johnny.set_seed(info['mother_seed'])
	client_player.rng.set_seed(johnny.randi())
	server_player.rng.set_seed(johnny.randi())

func _on_server_disconnected() -> void:
	network_peer_disconnected(NetworkGlobal.OPP_STEAM_ID)
	
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

	
func _on_ResetButton_pressed() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	SyncManager.reset_network_adaptor()
	
	Steam.closeSessionWithUser("OPP_STEAM_ID")
	print("Resetting to main menu...")
	get_tree().reload_current_scene()


# When one peer attempts to communicate with another peer directly, they need to 
# either send an arbitrary message back as a handshake, or accept their inital message
# as a session request. In this example, we accept the other users session request.

# TODO: Cache the requesting users steam ID, Prompt the user to see if they
# want to play, and if they say yes, then establish the connection
# TLDR: HANDSHAKE!
func _on_network_messages_session_request(sender_id: String):
	
	# If we're not a host, and someone is trying to communicate with us, we ignore them.
	if not NetworkGlobal.IS_STEAM_HOST:
		return
	
	var sender_id_int = sender_id.to_int()
	
	# Identity_Reference is equal to the steam id as a string, assigned to the
	# int value of the steam id
	NetworkGlobal.OPP_STEAM_ID = sender_id_int
	Steam.setIdentitySteamID64("OPP_STEAM_ID", sender_id_int)
	Steam.acceptSessionWithUser(sender_id)
	
	# We don't know what this user wants yet, but we're going to tell them
	# we accepted their request.
	var packet = create_networking_message(SYNC_TYPE.HANDSHAKE, emptyData)
	Steam.sendMessageToUser("OPP_STEAM_ID", packet, 0, 1)
	
	print("Steam ID of messager: " + sender_id)
