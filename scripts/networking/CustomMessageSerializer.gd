extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"

const input_path_mapping = {
		'/root/Main/MatchController/MapHolder/Map/ServerPlayer': 1,
		'/root/Main/MatchController/MapHolder/Map/ClientPlayer': 2
	}
const input_path_mapping_reverse = {
	1: '/root/Main/MatchController/MapHolder/Map/ServerPlayer',
	2: '/root/Main/MatchController/MapHolder/Map/ClientPlayer'
}

func serialize_input(all_input: Dictionary) -> PackedByteArray:
	var buffer := StreamPeerBuffer.new()
	buffer.resize(16) # size to be bigger than actual size
	
	buffer.put_u32(all_input['$'])
	buffer.put_u16(all_input.size() - 1) # -1 because of the $ key
	for path in all_input:
		if path == '$':
			continue
		buffer.put_u16(input_path_mapping[path])

		var input = all_input[path]
		buffer.put_u16(input['input']) # or whatever key you're using in the dictionary for the bitmask
	
	buffer.resize(buffer.get_position()) # resize to actual size
	return buffer.data_array


func unserialize_input(serialized: PackedByteArray) -> Dictionary:
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
	var all_input := {}
	
	all_input['$'] = buffer.get_u32()
	
	var input_count = buffer.get_u16()
	if input_count == 0:
		return all_input
	
	var path = input_path_mapping_reverse[buffer.get_u16()]
	var input := {}
	
	input['input'] = buffer.get_u16()
	
	all_input[path] = input
	return all_input
