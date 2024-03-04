extends Node


const SAVE_DIRECTORY = "res://assets/resources/save_data"
const SETTINGS_FILE_NAME = "config.dat"
#var save_settings_dict = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings_data()
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "set_settings_dict", "save_settings")


# Save the current settings to a .dat file
func save_settings(data: Dictionary) -> void:
	var data_string = JSON.stringify(data)
	var settings_data_save_file = FileAccess.open(SAVE_DIRECTORY + '/' + SETTINGS_FILE_NAME, FileAccess.WRITE)
	settings_data_save_file.store_string(data_string)


# Load saved data from .dat file
func load_settings_data() -> void:
	if not FileAccess.file_exists(SAVE_DIRECTORY + '/' + SETTINGS_FILE_NAME):
		return

	var settings_data_save_file = FileAccess.open(SAVE_DIRECTORY + '/' + SETTINGS_FILE_NAME, FileAccess.READ)
	var loaded_settings = settings_data_save_file.get_as_text()
	
	while settings_data_save_file.get_position() < settings_data_save_file.get_length():
		var json_string = settings_data_save_file.get_line()
		var test_json_conv = JSON.new()
		test_json_conv.parse(json_string)
		var _parsed_result = test_json_conv.get_data()
		
		loaded_settings = _parsed_result
	
	MenuSignalBus.emit_load_settings_data(loaded_settings)
	loaded_settings.clear()
