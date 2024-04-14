extends Node

const SteamNetworkAdaptor = preload("res://scripts/networking/SteamNetworkAdaptor.gd")

@onready var message_label = $Messages/MessageLabel
@onready var sync_lost_label = $Messages/SyncLostLabel
@onready var server_player = $ServerPlayer
@onready var client_player = $ClientPlayer

@onready var executable_path = OS.get_executable_path()
const LOG_FILE_DIRECTORY = "/ProjectDeltaLogs"

var logging_enabled := false
var emptyData: PackedByteArray = [1]

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
	SyncManager.network_adaptor = SteamNetworkAdaptor.new()
	_handle_connecting_signals()
	
	setup_match()
	
func _process(delta):
	var listOfMessages = Steam.receiveMessagesOnChannel(1, 999) #channel 1 #read up to 999 messages in buffer
	for message in listOfMessages:
		process_networking_message(message)

func _handle_connecting_signals() -> void:
	SyncManager.sync_started.connect(_on_SyncManager_sync_started)
	SyncManager.sync_stopped.connect(_on_SyncManager_sync_stopped)
	SyncManager.sync_lost.connect(_on_SyncManager_sync_lost)
	SyncManager.sync_regained.connect(_on_SyncManager_sync_regained)
	SyncManager.sync_error.connect(_on_SyncManager_sync_error)
	
	Steam.network_messages_session_request.connect(_on_network_messages_session_request)
	
	MatchSignalBus.quit_to_menu.connect(_on_quit_to_menu)
	MatchSignalBus.match_over.connect(_on_match_over)

func setup_match() -> void:
	Steam.setIdentitySteamID64("STEAM_OPP_ID", NetworkGlobal.STEAM_OPP_ID)
	
	print("Network Globals: ", NetworkGlobal.NETWORK_TYPE, NetworkGlobal.STEAM_IS_HOST, NetworkGlobal.STEAM_OPP_ID)
	var steamConnectionInfo = Steam.getSessionConnectionInfo("STEAM_OPP_ID", true, false)
	#print("Steam connection state: " + str(steamConnectionInfo.state))
	for key in steamConnectionInfo.keys():
		print(key + ": " + str(steamConnectionInfo.get(key)))
	
	
	if NetworkGlobal.NETWORK_TYPE != 2:
		print("Networking type is not set to STEAM, aborting...")
		get_tree().quit()
	
	if NetworkGlobal.STEAM_IS_HOST:
		#message_label.text = "Listening..."
		print("Listening...")
	else:
		#message_label.text = "Searching..."
		print("Searching...")
		var packet = create_networking_message(SYNC_TYPE.HANDSHAKE, emptyData)
		Steam.sendMessageToUser("STEAM_OPP_ID", packet, 0, 1)


# Responsible for creating packets to be sent over the steam network.
# PackedByteArrays are in the format of [Header: 1 byte, Data: n bytes]
func create_networking_message(header: int, data) -> PackedByteArray:
	
	var packet: PackedByteArray = []
	packet.append(header)
	
	# Checking to see if the data is already a PackedByteArray,
	# if not then we convert it to a PackedByteArray
	if typeof(data) != TYPE_PACKED_BYTE_ARRAY:
		data = var_to_bytes(data)
	
	packet.append_array(data)
	return packet

func process_networking_message(msg: Dictionary) -> void:
	# TODO: Figure out how we can incorporate message identitys into the adaptor (if needed)
	# sender_id might already be an int?
	var sender_id = msg["identity"].to_int()
	var packet = msg["payload"]
	
	var header = packet[0]
	var data = packet.slice(1, len(packet))
	
	match header:
		SYNC_TYPE.HANDSHAKE:
			print("SYNC,HANDSHAKE")
			connect_to_server()
		SYNC_TYPE.CONNECT:
			print("SYNC,CONNECT")
			peer_connected()
		SYNC_TYPE.START:
			print("SYNC,START")
			peer_connected()
		SYNC_TYPE.STOP:
			print("SYNC,STOP")
			SyncManager.stop()
		_: # Default
			print("Could not match packet types from message")

func connect_to_server() -> void:
	if NetworkGlobal.STEAM_IS_HOST:
		return
	var packet = create_networking_message(SYNC_TYPE.CONNECT, emptyData)
	Steam.sendMessageToUser("STEAM_OPP_ID", packet, 0, 1)

# Runs on both clients when the users establish a connection
func peer_connected():
	
	message_label.text = "Connected!"
	print("Connected!")
	
	if NetworkGlobal.STEAM_IS_HOST:
		NetworkGlobal.STEAM_PEER_ID = 1
		NetworkGlobal.STEAM_OPP_PEER_ID = 2
	else:
		NetworkGlobal.STEAM_PEER_ID = 2
		NetworkGlobal.STEAM_OPP_PEER_ID = 1
		
	SyncManager.add_peer(NetworkGlobal.STEAM_OPP_PEER_ID)
	
	server_player.set_multiplayer_authority(1)
	client_player.set_multiplayer_authority(2)
	
	if NetworkGlobal.STEAM_IS_HOST:
		#message_label.text = "Starting..."
		print("Starting...")
		var setup_packet = create_networking_message(SYNC_TYPE.START, emptyData)
		Steam.sendMessageToUser("STEAM_OPP_ID", setup_packet, 0, 1)
		
		# Give a little time to get ping data.
		await get_tree().create_timer(2.0).timeout
		SyncManager.start()
		
func peer_disconnected(peer_id: int):
	#message_label.text = "Disconnected"
	print("Disconnected")
	SyncManager.remove_peer(peer_id)

func _on_server_disconnected() -> void:
	peer_disconnected(NetworkGlobal.STEAM_OPP_ID)
	
func _on_SyncManager_sync_started() -> void:
	#message_label.text = "Started!"
	print("Started!")
	
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
	print("Sync stop recieved")
	if logging_enabled:
		SyncManager.stop_logging()
	reset_sync_data()

func _on_SyncManager_sync_lost() -> void:
	sync_lost_label.visible = true

func _on_SyncManager_sync_regained() -> void:
	sync_lost_label.visible = false

func _on_SyncManager_sync_error(msg: String) -> void:
	#message_label.text = "Fatal sync error: " + msg
	print("Fatal sync error: " + msg)
	sync_lost_label.visible = false
	
	match NetworkGlobal.NETWORK_TYPE:
		NETWORK_TYPE.ENET:
			var peer = multiplayer.multiplayer_peer
			if peer:
				peer.close()
		NETWORK_TYPE.STEAM:
			Steam.closeSessionWithUser("STEAM_OPP_ID")
		_:
			print("Sync error, but not in a networked game")
			
	SyncManager.clear_peers()

func _on_ResetButton_pressed() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	SyncManager.reset_network_adaptor()
	
	Steam.closeSessionWithUser("STEAM_OPP_ID")
	print("Resetting to main menu...")
	get_tree().reload_current_scene()

# When the user is quitting to lobby, send a STOP packet to the other person,
# wait 1 second, and reset any relevant data.
func _on_quit_to_menu() -> void:
	if NetworkGlobal.STEAM_IS_HOST:
		SyncManager.stop()
	else:
		var stop_packet = create_networking_message(SYNC_TYPE.STOP, emptyData)
		Steam.sendMessageToUser("STEAM_OPP_ID", stop_packet, 0, 1)

func _on_match_over() -> void:
	pass
	#reset_sync_data()
	
# Resets any relevant data for a users connection with another user.
# SyncManager, and NetworkGlobal.
func reset_sync_data() -> void:
	var steamConnectionInfo = Steam.getSessionConnectionInfo("STEAM_OPP_ID", true, false)
	for key in steamConnectionInfo.keys():
		print(key + ": " + str(steamConnectionInfo.get(key)))
	
	SyncManager.clear_peers()
	SyncManager.reset_network_adaptor()
	
	Steam.closeSessionWithUser("STEAM_OPP_ID")
	Steam.setIdentitySteamID64("STEAM_OPP_ID", -1)
	
	NetworkGlobal.STEAM_IS_HOST = false
	NetworkGlobal.STEAM_OPP_ID = 1
	NetworkGlobal.STEAM_PEER_ID = 1
	NetworkGlobal.STEAM_OPP_PEER_ID = 1
	
	MenuSignalBus.emit_leave_match()

# When one peer attempts to communicate with another peer directly, they need to 
# either send an arbitrary message back as a handshake, or accept their inital message
# as a session request. In this example, we accept the other users session request.

# TODO: Cache the requesting users steam ID, Prompt the user to see if they
# want to play, and if they say yes, then establish the connection
# TLDR: HANDSHAKE!
func _on_network_messages_session_request(sender_id: String):
	
	# If we're not a host, and someone is trying to communicate with us, we ignore them.
	if not NetworkGlobal.STEAM_IS_HOST:
		return
	
	var sender_id_int = sender_id.to_int()
	
	if sender_id_int != NetworkGlobal.STEAM_OPP_ID:
		print("A user (Steam Opp ID: " + str(NetworkGlobal.STEAM_OPP_ID) + ", Sender ID: " + str(sender_id_int) + ") attempted to connect that wasn't our current opponent!")
		return
	
	print("Accepting a session with a new opponent: " + sender_id)
	
	Steam.acceptSessionWithUser(sender_id)
	
	# We don't know what this user wants yet, but we're going to tell them
	# we accepted their request.
	var packet = create_networking_message(SYNC_TYPE.HANDSHAKE, emptyData)
	Steam.sendMessageToUser("STEAM_OPP_ID", packet, 0, 1)
	
	print("Steam ID of messager: " + sender_id)
