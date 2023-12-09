extends "res://addons/godot-rollback-netcode/NetworkAdaptor.gd"

# 0 = Unreliable Packet
# 8 = Reliable Packet

enum PACKET_TYPE {
	REMOTE_PING,
	REMOTE_PING_BACK,
	REMOTE_START,
	REMOTE_STOP,
	REMOTE_INPUT_TICK,
}
var emptyData: PoolByteArray = []

func _ready():
	Steam.connect("network_messages_session_request", self, "_on_network_messages_session_request")
	pass
	
func _process(delta):
	var listOfMessages = Steam.receiveMessagesOnChannel(0, 999) #channel 0 #read up to 999 messages in buffer
	for message in listOfMessages:
		process_packet(message)


# Responsible for creating packets to be sent over the steam network.
# PoolByteArrays are in the format of [Header: 1 byte, Data: n bytes]
func create_packet(header: int, data) -> PoolByteArray:
	
	var packet_to_send: PoolByteArray = []
	packet_to_send.append(header)
	
	# Checking to see if the data is already a PoolByteArray,
	# if not then we convert it to a PoolByteArray
	if typeof(data) != TYPE_RAW_ARRAY:
		data = var2bytes(data)
	
	packet_to_send.append_array(data)
	return packet_to_send
	
func process_packet(msg: Dictionary) -> void:
	
	# TODO: Figure out how we can incorporate message identitys into the adaptor (if needed)
	var sender_id = msg["identity"].to_int()
	var packet = msg["payload"]
	
	var header = packet[0]
	var data = packet.subarray(1, len(packet))
	
	match header:
		PACKET_TYPE.REMOTE_PING:
			_remote_ping(sender_id, bytes2var(data))
		PACKET_TYPE.REMOTE_PING_BACK:
			_remote_ping_back(sender_id, bytes2var(data))
		PACKET_TYPE.REMOTE_START:
			_remote_start()
		PACKET_TYPE.REMOTE_STOP:
			_remote_stop()
		PACKET_TYPE.REMOTE_INPUT_TICK:
			_rit(sender_id, data)
		_:
			print("Could not match packet types from message")


func send_ping(peer_id: int, msg: Dictionary) -> void:
	var packet = create_packet(PACKET_TYPE.REMOTE_PING, msg)
	Steam.sendMessageToUser(str(peer_id), packet, 0, 0)

func _remote_ping(peer_id: int, msg: Dictionary) -> void:
	emit_signal("received_ping", peer_id, msg)

func send_ping_back(peer_id: int, msg: Dictionary) -> void:
	var packet = create_packet(PACKET_TYPE.REMOTE_PING_BACK, msg)
	Steam.sendMessageToUser(str(peer_id), packet, 0, 0)

func _remote_ping_back(peer_id: int, msg: Dictionary) -> void:
	emit_signal("received_ping_back", peer_id, msg)

func send_remote_start(peer_id: int) -> void:
	var packet = create_packet(PACKET_TYPE.REMOTE_START, emptyData)
	Steam.sendMessageToUser(str(peer_id), packet, 8, 0)

func _remote_start() -> void:
	emit_signal("received_remote_start")

func send_remote_stop(peer_id: int) -> void:
	var packet = create_packet(PACKET_TYPE.REMOTE_START, emptyData)
	Steam.sendMessageToUser(str(peer_id), packet, 8, 0)

func _remote_stop() -> void:
	emit_signal("received_remote_stop")

func send_input_tick(peer_id: int, msg: PoolByteArray) -> void:
	var packet = create_packet(PACKET_TYPE.REMOTE_INPUT_TICK, msg)
	Steam.sendMessageToUser(str(peer_id), packet, 0, 0)
	
# _rit is short for _receive_input_tick.
func _rit(peer_id: int, msg: PoolByteArray) -> void:
	emit_signal("received_input_tick", peer_id, msg)

# Changed to Global variable
func is_network_host() -> bool:
	return SteamGlobal.IS_HOST

# Changed to Global variable
func get_network_unique_id() -> int:
	return SteamGlobal.STEAM_ID

func is_network_master_for_node(node: Node) -> bool:
	return node.get_meta("IS_NETWORK_MASTER")

# When one peer attempts to communicate with another peer directly, they need to 
# either send an arbitrary message back as a handshake, or accept their inital message
# as a session request. In this example, we accept the other users
func _on_network_messages_session_request(sender_id: String):
	
	# TODO: Add code here to secure session requests, probably an on-screen prompt for the client
	# TODO: Use client-side state to determine when lobbies can be formed
	var sender_id_int = sender_id.to_int()
	Steam.setIdentitySteamID64(sender_id, sender_id_int)
	Steam.acceptSessionWithUser(sender_id)
	print("Steam ID of messager: " + sender_id)
