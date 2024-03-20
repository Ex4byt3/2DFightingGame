extends Node2D


# Onready variable to preload the MapHolder scene
@onready var map_holder = preload("res://scenes/maps/MapHolder.tscn")

# Variables for matches
var is_p1_ready: bool = false
var is_p2_ready: bool = false

var p1_character
var p2_character

# Dictionary containing for match settings
var match_settings: Dictionary = {}
var character_settings: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "create_match", "_create_match")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "leave_match", "_leave_match")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_match_settings", "_update_match_settings")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "life_lost", "_life_lost")


func _create_match() -> void:
	var new_match = map_holder.instantiate()
	add_child(new_match)
	MenuSignalBus.emit_send_match_settings()


func _leave_match() -> void:
	SyncManager.stop()
	for child in get_children():
		child.queue_free()


func _update_match_settings(new_settings:Dictionary) -> void:
	match_settings = new_settings
	MenuSignalBus.emit_apply_match_settings(match_settings)


func _life_lost(player_id: String) -> void:
	print("\n[SYSTEM] " + player_id + " KO'd")
	print("[SYSTEM] Setting up new round...")
	MenuSignalBus.emit_setup_round()


