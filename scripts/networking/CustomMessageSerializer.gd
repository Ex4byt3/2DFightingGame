extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"

var input_path_mapping := {
	'/root/RpcGame/ServerPlayer': 1,
	'/root/RpcGame/ClientPlayer': 2
}

enum HeaderFlags {
	HAS_INPUT_VECTOR = 1 << 0, # Bit 0
	DROP_BOMB        = 1 << 1, # Bit 1
	TELEPORT         = 1 << 2, # Bit 2
}

var input_path_mapping_reverse := {}

func _init() -> void:
#	if NetworkGlobal.NETWORK_TYPE == 2:
#		input_path_mapping = {
#			'/root/SteamGame/ServerPlayer': 1,
#			'/root/SteamGame/ClientPlayer': 2
#		}
#	elif NetworkGlobal.NETWORK_TYPE == 1:
#		input_path_mapping = {
#			'/root/RpcGame/ServerPlayer': 1,
#			'/root/RpcGame/ClientPlayer': 2
#		}
	
	for key in input_path_mapping:
		input_path_mapping_reverse[input_path_mapping[key]] = key

func serialize_input(all_input: Dictionary) -> PoolByteArray:
	var buffer := StreamPeerBuffer.new()
	buffer.resize(16) # size to be bigger than actual size
	
	buffer.put_u32(all_input['$'])
	buffer.put_u8(all_input.size() - 1) # -1 because of the $ key
	for path in all_input:
		if path == '$':
			continue
		buffer.put_u8(input_path_mapping[path])
		
		var header := 0
		
		var input = all_input[path]
		if input.has('input_vector_x') and input.has('input_vector_y'):
			header |= HeaderFlags.HAS_INPUT_VECTOR
		if input.get('drop_bomb', false):
			header |= HeaderFlags.DROP_BOMB
		if input.get('teleport', false):
			header |= HeaderFlags.TELEPORT
		
		buffer.put_u8(header)
		
		if input.has('input_vector_x') and input.has('input_vector_y'):
			buffer.put_64(input['input_vector_x'])
			buffer.put_64(input['input_vector_y'])
	
	buffer.resize(buffer.get_position()) # resize to actual size
	return buffer.data_array

func unserialize_input(serialized: PoolByteArray) -> Dictionary:
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
	var all_input := {}
	
	all_input['$'] = buffer.get_u32()
	
	var input_count = buffer.get_u8()
	if input_count == 0:
		return all_input
	
	var path = input_path_mapping_reverse[buffer.get_u8()]
	var input := {}
	
	var header = buffer.get_u8()
	if header & HeaderFlags.HAS_INPUT_VECTOR:
		input["input_vector_x"] = buffer.get_64()
		input["input_vector_y"] = buffer.get_64()
	if header & HeaderFlags.DROP_BOMB:
		input["drop_bomb"] = true
	if header & HeaderFlags.TELEPORT:
		input["teleport"] = true
#	if header & HeaderFlags.IS_ON_FLOOR:
#		input["is_on_floor"] = true
	
	all_input[path] = input
	return all_input
