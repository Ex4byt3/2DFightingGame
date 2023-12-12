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

var emptyData: PoolByteArray = [1]

func _ready():
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

# COULD BE COMPRESSED FURTHER
func process_packet(msg: Dictionary) -> void:
	
	# TODO: Figure out how we can incorporate message identitys into the adaptor (if needed)
	# sender_id might already be an int?
	var sender_id = msg["identity"].to_int()
	var packet = msg["payload"]
	
	print(sender_id)
	print(packet)
	
	var header = packet[0]
	var data = packet.subarray(1, len(packet) - 1)
	
	print(header)
	print(data)
	
	match header:
		PACKET_TYPE.REMOTE_PING:
			print("ROLLBACK, PING")
			_remote_ping(bytes2var(data))
		PACKET_TYPE.REMOTE_PING_BACK:
			print("ROLLBACK, PINGBACK")
			_remote_ping_back(bytes2var(data))
		PACKET_TYPE.REMOTE_START:
			print("ROLLBACK, REMOTESTART")
			_remote_start()
		PACKET_TYPE.REMOTE_STOP:
			print("ROLLBACK, REMOTESTOP")
			_remote_stop()
		PACKET_TYPE.REMOTE_INPUT_TICK:
			print("ROLLBACK, RECIEVEINPUTTICK")
			_rit(sender_id, data)
		_:
			print("Could not match packet types from message")


func send_ping(peer_id: int, msg: Dictionary) -> void:
	var packet = create_packet(PACKET_TYPE.REMOTE_PING, msg)
	Steam.sendMessageToUser("OPPONENT_ID", packet, 0, 0)

func _remote_ping(msg: Dictionary) -> void:
	emit_signal("received_ping", SteamGlobal.OPPONENT_ID, msg)

func send_ping_back(peer_id: int, msg: Dictionary) -> void:
	var packet = create_packet(PACKET_TYPE.REMOTE_PING_BACK, msg)
	Steam.sendMessageToUser("OPPONENT_ID", packet, 0, 0)

func _remote_ping_back(msg: Dictionary) -> void:
	emit_signal("received_ping_back", SteamGlobal.OPPONENT_ID, msg)

func send_remote_start(peer_id: int) -> void:
	var packet = create_packet(PACKET_TYPE.REMOTE_START, emptyData)
	Steam.sendMessageToUser("OPPONENT_ID", packet, 8, 0)

func _remote_start() -> void:
	emit_signal("received_remote_start")

func send_remote_stop(peer_id: int) -> void:
	var packet = create_packet(PACKET_TYPE.REMOTE_START, emptyData)
	Steam.sendMessageToUser("OPPONENT_ID", packet, 8, 0)

func _remote_stop() -> void:
	emit_signal("received_remote_stop")

func send_input_tick(peer_id: int, msg: PoolByteArray) -> void:
	var packet = create_packet(PACKET_TYPE.REMOTE_INPUT_TICK, msg)
	Steam.sendMessageToUser("OPPONENT_ID", packet, 0, 0)
	
# _rit is short for _receive_input_tick.
func _rit(peer_id: int, msg: PoolByteArray) -> void:
	emit_signal("received_input_tick", SteamGlobal.OPPONENT_ID, msg)

# Changed to Global variable
func is_network_host() -> bool:
	return SteamGlobal.IS_HOST

# Changed to Global variable, do we want the opponents steam ID?
func get_network_unique_id() -> int:
	return SteamGlobal.STEAM_ID

func is_network_master_for_node(node: Node) -> bool:
	return node.get_meta("IS_NETWORK_MASTER", false)

func _on_network_messages_session_request(sender_id: String):
	
	print("ROLLBACK,NETWORK SESSION REQUEST")
	
	var sender_id_int = sender_id.to_int()
	
	# Identity_Reference is equal to the steam id as a string, assigned to the
	# int value of the steam id
	Steam.setIdentitySteamID64("OPPONENT_ID", sender_id_int)
	Steam.acceptSessionWithUser(sender_id)
