extends Node

onready var player_keybind_resource = preload("res://resources/settings/playerkeybinds_default.tres")

var window_mode_index = 0
var resolution_index = 0
var loaded_settings = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()
	create_storage_dictionary()


# Connect relevant signals from the SettingsSignalBus
func handle_connecting_signals() -> void:
	SettingsSingalBus.connect("load_settings_data", self, "load_settings_data")
	SettingsSingalBus.connect("window_mode_selected", self, "on_window_mode_selected")
	SettingsSingalBus.connect("resolution_selected", self, "on_resolution_selected")


# Loads all relevant setting data upon game launch
func load_settings_data(data: Dictionary) -> void:
	loaded_settings = data
	
	on_window_mode_selected(loaded_settings.window_mode_index)
	on_keybindings_loaded(loaded_settings.keybindings_dictionary)


# After keybindings are loaded, assign them to the appropriate keys
func on_keybindings_loaded(data: Dictionary) -> void:
	# Create empty key events for each of the hotkeys
	# Player 1
	var loaded_jump_key = InputEventKey.new()
	var loaded_crouch_key = InputEventKey.new()
	var loaded_move_left_key = InputEventKey.new()
	var loaded_move_right_key = InputEventKey.new()
	# Player 2
	var loaded_jump_key_p2 = InputEventKey.new()
	var loaded_crouch_key_p2 = InputEventKey.new()
	var loaded_move_left_key_p2 = InputEventKey.new()
	var loaded_move_right_key_p2 = InputEventKey.new()
	
	# Set the empty key events to the loaded scancodes
	# Player 1
	loaded_jump_key.set_physical_scancode(int(data.player1_up))
	loaded_crouch_key.set_physical_scancode(int(data.player1_down))
	loaded_move_left_key.set_physical_scancode(int(data.player1_left))
	loaded_move_right_key.set_physical_scancode(int(data.player1_right))
	# Player 2
	loaded_jump_key_p2.set_physical_scancode(int(data.player2_up))
	loaded_crouch_key_p2.set_physical_scancode(int(data.player2_down))
	loaded_move_left_key_p2.set_physical_scancode(int(data.player2_left))
	loaded_move_right_key_p2.set_physical_scancode(int(data.player2_right))
	
	# Set the keybindresource values to the loaded ones
	player_keybind_resource.jump_key = loaded_jump_key
	player_keybind_resource.crouch_key = loaded_crouch_key
	player_keybind_resource.move_left_key = loaded_move_left_key
	player_keybind_resource.move_right_key = loaded_move_right_key
	player_keybind_resource.jump_key = loaded_jump_key
	player_keybind_resource.crouch_key = loaded_crouch_key
	player_keybind_resource.move_left_key = loaded_move_left_key
	player_keybind_resource.move_right_key = loaded_move_right_key


# Updates window mode setting to be saved when modified in the settings menu
func on_window_mode_selected(index: int) -> void:
	window_mode_index = index


# Updates resolution setting to be saved when modified in the settings menu
func on_resolution_selected(index: int) -> void:
	resolution_index = index


# Create a dictionary of all of the settings information to be saved
func create_storage_dictionary() -> Dictionary:
	var settings_container_dict = {
		"window_mode_index": window_mode_index,
		"resolution_index": resolution_index,
		"keybindings_dictionary" : create_keybindings_dictionary(),
	}
	
	return settings_container_dict


# Create a dictionary of all the keybindings to be saved
func create_keybindings_dictionary() -> Dictionary:
	var keybind_container_dict = {
		# Player 1
		player_keybind_resource.JUMP: player_keybind_resource.jump_key,
		player_keybind_resource.CROUCH: player_keybind_resource.crouch_key,
		player_keybind_resource.MOVE_LEFT: player_keybind_resource.move_left_key,
		player_keybind_resource.MOVE_RIGHT: player_keybind_resource.move_right_key,
		# Player 2
		player_keybind_resource.JUMP_P2: player_keybind_resource.jump_key_p2,
		player_keybind_resource.CROUCH_P2: player_keybind_resource.crouch_key_p2,
		player_keybind_resource.MOVE_LEFT_P2: player_keybind_resource.move_left_key_p2,
		player_keybind_resource.MOVE_RIGHT_P2: player_keybind_resource.move_right_key_p2,
	}
	
	return keybind_container_dict
