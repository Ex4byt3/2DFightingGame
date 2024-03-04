extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"

func serialize_input(input: Dictionary) -> PackedByteArray:
	print('serialize_input input' + str(input))
	# var bytes = var2bytes(input)
	# print('serialize_input size' + str(bytes.size()))
	return var_to_bytes(input)

func unserialize_input(serialized: PackedByteArray) -> Dictionary:
	return bytes_to_var(serialized)
