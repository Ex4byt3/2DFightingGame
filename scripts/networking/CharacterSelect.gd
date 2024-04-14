extends Node

# Create all necessary scene references here:

enum SYNC_TYPE {
	HANDSHAKE,
	COUNTDOWN,
	START,
	DISCONNECT,
}

var emptyData: PackedByteArray = [1]

func _ready():
	if not NetworkGlobal.STEAM_IS_HOST:
		Steam.setIdentitySteamID64("STEAM_OPP_ID", NetworkGlobal.STEAM_OPP_ID)
		
		var handshake_packet = create_networking_message(SYNC_TYPE.HANDSHAKE, emptyData)
		Steam.sendMessageToUser("STEAM_OPP_ID", handshake_packet, 0, 2)
		
func _process(delta):
	var listOfMessages = Steam.receiveMessagesOnChannel(2, 999) #channel 1 #read up to 999 messages in buffer
	for message in listOfMessages:
		process_networking_message(message)

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
	
	var sender_id = msg["identity"].to_int()
	var packet = msg["payload"]
	
	var header = packet[0]
	var data = packet.slice(1, len(packet))
	
	match header:
		SYNC_TYPE.HANDSHAKE:
			print("Recieved handshake, but this isn't supposed to happen! Aborting!")
			get_tree().quit()
		SYNC_TYPE.COUNTDOWN:
			print("SYNC,COUNTDOWN")
			start_countdown()
		SYNC_TYPE.START:
			print("SYNC,START")
			start_match()
		_: # Default
			print("Could not match packet types from message, quitting...")
			get_tree().quit()
			
func start_countdown() -> void:
	# TODO: Start the countdown on the timer object here
	
	# TODO: Send a signal to the timer object to start a countdown,
	# pass in the time as a parameter
	await get_tree().create_timer(30.0).timeout
	
	var start_packet = create_networking_message(SYNC_TYPE.START, emptyData)
	Steam.sendMessageToUser("STEAM_OPP_ID", start_packet, 0, 2)
	
	start_match()
	
func start_match() -> void:
	# TODO: Set the match scene in the scene tree
	pass
			
# TLDR: HANDSHAKE!
func _on_network_messages_session_request(sender_id: String):
	
	# Int value of the steam id
	var sender_id_int = sender_id.to_int()
	
	# If we're not a host OR our cached steam ID does not match,
	# and someone is trying to communicate with us, we ignore them.
	if not NetworkGlobal.STEAM_IS_HOST or sender_id_int != NetworkGlobal.STEAM_OPP_ID:
		return
	
	Steam.setIdentitySteamID64("STEAM_OPP_ID", sender_id_int)
	Steam.acceptSessionWithUser(sender_id)
	
	
	var packet = create_networking_message(SYNC_TYPE.COUNTDOWN, emptyData)
	Steam.sendMessageToUser("STEAM_OPP_ID", packet, 0, 2)
	
	start_countdown()
