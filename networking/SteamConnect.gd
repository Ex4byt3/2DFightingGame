extends WindowDialog

const DummyNetworkAdaptor = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")
const SteamNetworkAdaptor = preload("res://networking/SteamNetworkAdaptor.gd")

onready var main_menu = get_node("/root/Main/CanvasLayer/MainMenu")
onready var message_label = get_node("/root/Main/CanvasLayer/MessageLabel")
onready var sync_lost_label = get_node("/root/Main/CanvasLayer/SyncLostLabel")
onready var server_player = get_node("/root/Main/ServerPlayer")
onready var client_player = get_node("/root/Main/ClientPlayer")
onready var johnny = get_node("/root/Main/Johnny")
onready var steam_connection_panel = self
onready var id_field = $GridContainer/SteamIDField

const LOG_FILE_DIRECTORY = 'E:/godot-logs'

var logging_enabled := true
var emptyData: PoolByteArray = [1]

enum SYNC_TYPE {
	HANDSHAKE,
	CONNECT,
	START,
	STOP,
}


func _ready() -> void:
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
			setup_match(bytes2var(data))
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
	Steam.sendMessageToUser("OPPONENT_ID", packet, 0, 1)

# Runs on both clients when the users establish a connection
func network_peer_connected():
	
	message_label.text = "Connected!"
	SyncManager.add_peer(SteamGlobal.OPPONENT_ID)
	
	server_player.set_meta("IS_NETWORK_MASTER", SteamGlobal.IS_HOST)
	client_player.set_meta("IS_NETWORK_MASTER", not SteamGlobal.IS_HOST)
	
	if SteamGlobal.IS_HOST:
		message_label.text = "Starting..."
		#rpc("setup_match", {mother_seed = johnny.get_seed()})
		var setup_packet = create_networking_message(SYNC_TYPE.START, {mother_seed = johnny.get_seed()})
		Steam.sendMessageToUser("OPPONENT_ID", setup_packet, 0, 1)
		
		# Give a little time to get ping data.
		setup_match({mother_seed = johnny.get_seed()})
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start()
		
func network_peer_disconnected(peer_id: int):
	message_label.text = "Disconnected"
	SyncManager.remove_peer(peer_id)

func setup_match(info: Dictionary) -> void:
	johnny.set_seed(info['mother_seed'])
	client_player.rng.set_seed(johnny.randi())
	server_player.rng.set_seed(johnny.randi())

func _on_server_disconnected() -> void:
	network_peer_disconnected(SteamGlobal.OPPONENT_ID)
	
# Create a server when pressed, waiting for a client to connect
func _on_Steam_ServerButton_pressed() -> void:
	johnny.randomize()

	SteamGlobal.IS_HOST = true
	main_menu.visible = false
	steam_connection_panel.visible = false
	message_label.text = "Listening..."

# Create a client when pressed, attempting to connect to a server
func _on_Steam_ClientButton_pressed() -> void:
	var opp_id = id_field.text.to_int()
	SteamGlobal.OPPONENT_ID = opp_id
	Steam.setIdentitySteamID64("OPPONENT_ID", opp_id)
	
	var packet = create_networking_message(SYNC_TYPE.HANDSHAKE, emptyData)
	Steam.sendMessageToUser("OPPONENT_ID", packet, 0, 1)
	
	main_menu.visible = false
	steam_connection_panel.visible = false
	message_label.text = "Connecting..."
	
func _on_ResetButton_pressed() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	SyncManager.reset_network_adaptor()
	
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
	SteamGlobal.OPPONENT_ID = sender_id_int
	Steam.setIdentitySteamID64("OPPONENT_ID", sender_id_int)
	Steam.acceptSessionWithUser(sender_id)
	
	# We don't know what this user wants yet, but we're going to tell them
	# we accepted their request.
	var packet = create_networking_message(SYNC_TYPE.HANDSHAKE, emptyData)
	Steam.sendMessageToUser("OPPONENT_ID", packet, 0, 1)
	
	print("Steam ID of messager: " + sender_id)
