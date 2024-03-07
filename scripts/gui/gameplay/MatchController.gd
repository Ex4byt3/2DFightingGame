extends Node2D


# Onready variable to preload the MapHolder scene
@onready var map_holder = preload("res://scenes/maps/MapHolder.tscn")

# Variables for matches
var is_p1_ready: bool = false
var is_p2_ready: bool = false

# Dictionary containing for match settings
var match_settings: Dictionary = {}
var character_settings: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "create_match", "_create_match")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "leave_match", "_leave_match")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "receive_required_match_data", "_receive_required_match_data")


func _create_match() -> void:
	var new_match = map_holder.instantiate()
	add_child(new_match)
	MenuSignalBus.emit_send_required_match_data()


func _leave_match() -> void:
	SyncManager.stop()
	for child in get_children():
		child.queue_free()


func _receive_required_match_data(new_match_settings: Dictionary, new_character_settings: Dictionary) -> void:
	print("[SYSTEM] Required match data received!")
	match_settings = new_match_settings
	character_settings = new_character_settings
	
	print("[SYSTEM] Sending match settings...")
	MenuSignalBus.emit_apply_match_settings(match_settings)
	print("[SYSTEM] Sending character settings...")
	MenuSignalBus.emit_apply_character_settings(character_settings)
