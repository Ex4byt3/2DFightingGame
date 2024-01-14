extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"

enum InputMessageKey {
	NEXT_INPUT_TICK_REQUESTED,
	INPUT,
	NEXT_HASH_TICK_REQUESTED,
	STATE_HASHES,
}

func serialize_input(input: Dictionary) -> PoolByteArray:
    print(input)
    var bytes = var2bytes(input)
    print(bytes.size())
    return var2bytes(input)

func unserialize_input(serialized: PoolByteArray) -> Dictionary:
	return bytes2var(serialized)