extends Node


@onready var player_keybind_resource = preload("res://assets/resources/game_settings/playerkeybinds_default.tres")

# Variables for display settings
var window_mode_index: int = 0
var resolution_index: int = 0

# Variables for local match settings
var match_timelimit: int  = 180 # In seconds

# Variables for local character settings
var character_lives: int = 2
var initial_burst: int = 100
var initial_meter: int = 0

# Dictionaries and variables for loading match and character settings
var is_using_lobby: bool = false
var local_match_settings: Dictionary = {}
var local_character_settings: Dictionary = {}
var lobby_match_settings: Dictionary = {}
var lobby_character_settings: Dictionary = {}

# Dictionaries for saving and loading settings
var storage_dictionary: Dictionary = {}
var loaded_settings: Dictionary = {}

# Define an array for the window options
const WINDOW_MODE_ARRAY: Array = [
	"     Bordered Window",
	"     Borderless Window",
	"     Fullscreen",
	"     Borderless Fullscreen",
]

# Dictionary for screen resolution options
const RESOLUTION_DICTIONARY: Dictionary = {
	"     640 x 360" : Vector2(640, 360),
	"     853 x 480" : Vector2(853, 480),
	"     1280 x 720" : Vector2(1280, 720),
	"     1920 x 1080" : Vector2(1920, 1080),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	create_storage_dictionary()


# Connect relevant signals from the MenuSignalBus
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "load_settings_data", "_load_settings_data")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "window_mode_selected", "_on_window_mode_selected")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "resolution_selected", "_on_resolution_selected")
	
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "send_required_match_data", "_send_required_match_data")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "set_match_settings_source", "_set_match_settings_source")


# Loads all relevant setting data upon game launch
func _load_settings_data(data: Dictionary) -> void:
	loaded_settings = data
	_on_window_mode_selected(loaded_settings.window_mode_index)
	_on_resolution_selected(loaded_settings.resolution_index)
	_on_keybindings_loaded(loaded_settings.keybindings_dictionary)
	#_on_match_settings_loaded(loaded_settings.match_settings_dictionary)
	#_on_character_settings_loaded(loaded_settings.character_settings_dictionary)


##################################################
# MATCH SETTINGS FUNCTIONS
##################################################
func _set_match_settings_source(using_owner_settings: bool) -> void:
	is_using_lobby = using_owner_settings


func _on_match_settings_loaded(data: Dictionary) -> void:
	match_timelimit = data.match_timelimit


func create_match_settings_dictionary() -> Dictionary:
	var match_settings_dict: Dictionary = {
		"match_timelimit": match_timelimit
	}
	return match_settings_dict


func _on_character_settings_loaded(data: Dictionary) -> void:
	character_lives = data.character_lives
	initial_burst = data.initial_burst
	initial_meter = data.initial_meter


func create_character_settings_dictionary() -> Dictionary:
	var character_settings_dict: Dictionary = {
		"character_lives": character_lives,
		"initial_burst": initial_burst,
		"initial_meter": initial_meter,
	}
	return character_settings_dict


func _send_required_match_data() -> void:
	print("[SYSTEM] Sending required match data...")
	var match_settings_to_send = create_match_settings_dictionary()
	var character_settings_to_send = create_character_settings_dictionary()
	
	if is_using_lobby:
		match_settings_to_send = lobby_match_settings
		character_settings_to_send = lobby_character_settings
		
	MenuSignalBus.call_deferred("emit_receive_required_match_data", match_settings_to_send, character_settings_to_send)
	


##################################################
# KEYBIND FUNCTIONS
##################################################
# After keybindings are loaded, assign them to the appropriate keys
func _on_keybindings_loaded(data: Dictionary) -> void:
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
	loaded_jump_key.set_physical_keycode(int(data.player1_up))
	loaded_crouch_key.set_physical_keycode(int(data.player1_down))
	loaded_move_left_key.set_physical_keycode(int(data.player1_left))
	loaded_move_right_key.set_physical_keycode(int(data.player1_right))
	# Player 2
	loaded_jump_key_p2.set_physical_keycode(int(data.player2_up))
	loaded_crouch_key_p2.set_physical_keycode(int(data.player2_down))
	loaded_move_left_key_p2.set_physical_keycode(int(data.player2_left))
	loaded_move_right_key_p2.set_physical_keycode(int(data.player2_right))
	
	# Set the keybindresource values to the loaded ones
	player_keybind_resource.jump_key = loaded_jump_key
	player_keybind_resource.crouch_key = loaded_crouch_key
	player_keybind_resource.move_left_key = loaded_move_left_key
	player_keybind_resource.move_right_key = loaded_move_right_key
	player_keybind_resource.jump_key = loaded_jump_key
	player_keybind_resource.crouch_key = loaded_crouch_key
	player_keybind_resource.move_left_key = loaded_move_left_key
	player_keybind_resource.move_right_key = loaded_move_right_key


# Create a dictionary of all the keybindings to be saved
func create_keybindings_dictionary() -> Dictionary:
	var keybind_container_dict: Dictionary = {
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

##################################################
# MENU SETTINGS FUNCTIONS
##################################################
# Updates window mode setting to be saved when modified in the settings menu
func _on_window_mode_selected(index: int) -> void:
	window_mode_index = index
	
	match window_mode_index:
		0: # bordered window
			get_window().borderless = (false)
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (false) else Window.MODE_WINDOWED
		1: # borderless window
			get_window().borderless = (true)
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (false) else Window.MODE_WINDOWED
		2: # fullscreen
			get_window().borderless = (false)
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
		3: # borderless fullscreen
			get_window().borderless = (true)
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED


# Updates resolution setting to be saved when modified in the settings menu
func _on_resolution_selected(index: int) -> void:
	resolution_index = index
	
	match resolution_index:
		0: # 640 x 360
			get_window().set_size(RESOLUTION_DICTIONARY.values()[0])
		1: # 853 x 480
			get_window().set_size(RESOLUTION_DICTIONARY.values()[1])
		2: # 1280 x 720
			get_window().set_size(RESOLUTION_DICTIONARY.values()[2])
		3: # 1920 x 1080
			get_window().set_size(RESOLUTION_DICTIONARY.values()[3])


##################################################
# PRIMARY STORAGE CREATION
##################################################
# Create a dictionary of all of the settings information to be saved
func create_storage_dictionary() -> Dictionary:
	var settings_container_dict = {
		"window_mode_index": window_mode_index,
		"resolution_index": resolution_index,
		"keybindings_dictionary" : create_keybindings_dictionary(),
		"match_settings_dictionary": create_match_settings_dictionary(),
		"character_settings_dictionary": create_character_settings_dictionary()
	}

	return settings_container_dict



