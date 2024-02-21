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
	var data_string = JSON.print(data)
	var settings_data_save_file = File.new()
	var dir = Directory.new()
	
	if not dir.dir_exists(SAVE_DIRECTORY):
		dir.make_dir(SAVE_DIRECTORY)
	
	#print(data_string)
	settings_data_save_file.open(SAVE_DIRECTORY + '/' + SETTINGS_FILE_NAME, File.WRITE)
	settings_data_save_file.store_string(data_string)
	settings_data_save_file.close()


# Load saved data from .dat file
func load_settings_data() -> void:
	var settings_data_save_file = File.new()
	if not settings_data_save_file.file_exists(SAVE_DIRECTORY + '/' + SETTINGS_FILE_NAME):
		return
		
	settings_data_save_file.open(SAVE_DIRECTORY + '/' + SETTINGS_FILE_NAME, File.READ)
	var loaded_settings = {}
	
	while settings_data_save_file.get_position() < settings_data_save_file.get_len():
		var json_string = settings_data_save_file.get_line()
		var _parsed_result = JSON.parse(json_string)
		
		loaded_settings = _parsed_result.result
	
	MenuSignalBus.emit_load_settings_data(loaded_settings)
	loaded_settings.clear()
