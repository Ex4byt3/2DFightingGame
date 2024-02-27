extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"

var input_path_mapping = {}
var input_path_mapping_reverse = {}

enum HeaderFlags {
	HAS_INPUT_VECTOR = 1 << 0, # Bit 0
	DROP_BOMB        = 1 << 1, # Bit 1
	ATTACK_LIGHT     = 1 << 2, # Bit 2
	ATTACK_MEDIUM    = 1 << 3, # Bit 3
	ATTACK_HEAVY     = 1 << 4, # Bit 4
	IMPACT           = 1 << 5, # Bit 5
	DASH             = 1 << 6, # Bit 6
	SHIELD           = 1 << 7, # Bit 7
	SPRINT_MACRO     = 1 << 8, # Bit 8
}

func _init():
	MenuSignalBus._connect_Signals(GameSignalBus, self, "network_button_pressed", "_on_network_button_pressed")
#	GameSignalBus.connect("network_button_pressed", self, "_on_network_button_pressed")

func serialize_input(all_input: Dictionary) -> PoolByteArray:
	var buffer := StreamPeerBuffer.new()
	buffer.resize(16) # size to be bigger than actual size
	
	buffer.put_u32(all_input['$'])
	buffer.put_u16(all_input.size() - 1) # -1 because of the $ key
	for path in all_input:
		if path == '$':
			continue
		buffer.put_u16(input_path_mapping[path])
		
		var header := 0
		
		var input = all_input[path]
		if input.has('input_vector_x') and input.has('input_vector_y'):
			header |= HeaderFlags.HAS_INPUT_VECTOR
		if input.get('drop_bomb', false):
			header |= HeaderFlags.DROP_BOMB
		if input.get('attack_light', false):
			header |= HeaderFlags.ATTACK_LIGHT
		if input.get('attack_medium', false):
			header |= HeaderFlags.ATTACK_MEDIUM
		if input.get('attack_heavy', false):
			header |= HeaderFlags.ATTACK_HEAVY
		if input.get('impact', false):
			header |= HeaderFlags.IMPACT
		if input.get('dash', false):
			header |= HeaderFlags.DASH
		if input.get('shield', false):
			header |= HeaderFlags.SHIELD
		if input.get('sprint_macro', false):
			header |= HeaderFlags.SPRINT_MACRO
		
		buffer.put_u16(header)
		
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
	
	var input_count = buffer.get_u16()
	if input_count == 0:
		return all_input
	
	var path = input_path_mapping_reverse[buffer.get_u16()]
	var input := {}
	
	var header = buffer.get_u16()
	if header & HeaderFlags.HAS_INPUT_VECTOR:
		input["input_vector_x"] = buffer.get_64()
		input["input_vector_y"] = buffer.get_64()
	if header & HeaderFlags.DROP_BOMB:
		input["drop_bomb"] = true
	if header & HeaderFlags.ATTACK_LIGHT:
		input["attack_light"] = true
	if header & HeaderFlags.ATTACK_MEDIUM:
		input["attack_medium"] = true
	if header & HeaderFlags.ATTACK_HEAVY:
		input["attack_heavy"] = true
	if header & HeaderFlags.IMPACT:
		input["impact"] = true
	if header & HeaderFlags.DASH:
		input["dash"] = true
	if header & HeaderFlags.SHIELD:
		input["shield"] = true
	if header & HeaderFlags.SPRINT_MACRO:
		input["sprint_macro"] = true
	
	all_input[path] = input
	return all_input

func _on_network_button_pressed(network_type: int) -> void:
	input_path_mapping.clear()
	input_path_mapping_reverse.clear()
	
	if network_type == 1:
		input_path_mapping['/root/RpcGame/ServerPlayer'] = 1
		input_path_mapping['/root/RpcGame/ClientPlayer'] = 2
	elif network_type == 2:
		input_path_mapping['/root/SteamGame/ServerPlayer'] = 1
		input_path_mapping['/root/SteamGame/ClientPlayer'] = 2
	else:
		input_path_mapping.clear()
		
	for key in input_path_mapping:
		input_path_mapping_reverse[input_path_mapping[key]] = key
