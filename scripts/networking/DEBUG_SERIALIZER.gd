extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"

func serialize_input(input: Dictionary) -> PoolByteArray:
	print('serialize_input input' + str(input))
	# var bytes = var2bytes(input)
	# print('serialize_input size' + str(bytes.size()))
	return var2bytes(input)

func unserialize_input(serialized: PoolByteArray) -> Dictionary:
	return bytes2var(serialized)
