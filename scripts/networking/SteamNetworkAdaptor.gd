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

var debug_counter = 0

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
	
	#DEBUG
	#print('create_packet header: ' + str(header))
	#print('create_packet data: ' + str(data))
	
	# Checking to see if the data is already a PoolByteArray,
	# if not then we convert it to a PoolByteArray
	if typeof(data) != TYPE_RAW_ARRAY:
		data = var2bytes(data)
	
	packet_to_send.append_array(data)
	
	#DEBUG
	#print('create_packet packet_to_send: ' + str(packet_to_send))
	
	return packet_to_send

# COULD BE COMPRESSED FURTHER
func process_packet(msg: Dictionary) -> void:
	
	# TODO: Figure out how we can incorporate message identitys into the adaptor (if needed)
	# sender_id might already be an int?
	var sender_id = msg["identity"].to_int()
	var packet = msg["payload"]
	
	var header = packet[0]
	var data = packet.subarray(1, len(packet) - 1)
	
	match header:
		PACKET_TYPE.REMOTE_PING:
			#print("ROLLBACK, PING")
			_remote_ping(bytes2var(data))
		PACKET_TYPE.REMOTE_PING_BACK:
			#print("ROLLBACK, PINGBACK")
			_remote_ping_back(bytes2var(data))
		PACKET_TYPE.REMOTE_START:
			#print("ROLLBACK, REMOTESTART")
			_remote_start()
		PACKET_TYPE.REMOTE_STOP:
			#print("ROLLBACK, REMOTESTOP")
			_remote_stop()
		PACKET_TYPE.REMOTE_INPUT_TICK:
			#print("ROLLBACK, RECIEVEINPUTTICK")
			_rit(sender_id, data)
		_:
			print("Could not match packet types from message")


func send_ping(peer_id: int, msg: Dictionary) -> void:
	#print("SENDING PING!")
	var packet = create_packet(PACKET_TYPE.REMOTE_PING, msg)
	Steam.sendMessageToUser("STEAM_OPP_ID", packet, 0, 0)

func _remote_ping(msg: Dictionary) -> void:
	#print("_remote_ping msg: " + str(msg))
	emit_signal("received_ping", NetworkGlobal.STEAM_SHORT_OPP_ID, msg)

func send_ping_back(peer_id: int, msg: Dictionary) -> void:
	#print("SENDING PING BACK!")
	var packet = create_packet(PACKET_TYPE.REMOTE_PING_BACK, msg)
	Steam.sendMessageToUser("STEAM_OPP_ID", packet, 0, 0)

func _remote_ping_back(msg: Dictionary) -> void:
	emit_signal("received_ping_back", NetworkGlobal.STEAM_SHORT_OPP_ID, msg)

func send_remote_start(peer_id: int) -> void:
	#print("SENDING REMOTE START!")
	var packet = create_packet(PACKET_TYPE.REMOTE_START, emptyData)
	Steam.sendMessageToUser("STEAM_OPP_ID", packet, 8, 0)

func _remote_start() -> void:
	emit_signal("received_remote_start")

func send_remote_stop(peer_id: int) -> void:
	#print("SENDING REMOTE STOP!")
	var packet = create_packet(PACKET_TYPE.REMOTE_STOP, emptyData)
	Steam.sendMessageToUser("STEAM_OPP_ID", packet, 8, 0)

func _remote_stop() -> void:
	emit_signal("received_remote_stop")

func send_input_tick(peer_id: int, msg: PoolByteArray) -> void:
	#print("SENDING INPUT TICK!")
	var packet = create_packet(PACKET_TYPE.REMOTE_INPUT_TICK, msg)
	Steam.sendMessageToUser("STEAM_OPP_ID", packet, 0, 0)
	
# _rit is short for _receive_input_tick.
func _rit(peer_id: int, msg: PoolByteArray) -> void:
	emit_signal("received_input_tick", NetworkGlobal.STEAM_SHORT_OPP_ID, msg)
	
	# DEBUG
	# debug_counter += 1
	# if debug_counter == 120:
	# 	print('_rit' + str(msg))
	# 	print('_rit' + str(msg.size()))
	# 	#print(bytes2var(msg))
	# 	debug_counter = 0

# Changed to Global variable
func is_network_host() -> bool:
	return NetworkGlobal.STEAM_IS_HOST

# Changed to Global variable
func get_network_unique_id() -> int:
	return NetworkGlobal.STEAM_SHORT_ID

func is_network_master_for_node(node: Node) -> bool:
	return node.get_network_master() == NetworkGlobal.STEAM_SHORT_ID
