extends Node


const SAVE_DIRECTORY = "res://assets/resources/save_data/"
const SETTINGS_FILE_NAME = "config.dat"
#var save_settings_dict = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings_data()
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "set_settings_dict", "save_settings")
	MenuSignalBus.set_settings_dict.connect(save_settings)


# Save the current settings to a .dat file
func save_settings() -> void:
	var config_file = FileAccess.open(SAVE_DIRECTORY + SETTINGS_FILE_NAME, FileAccess.WRITE)
	
	## Call the node's save function.
	var save_data = SettingsData.call("create_storage_dictionary")
	
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(save_data)
	
	# Store the save dictionary as a new line in the save file.
	config_file.store_line(json_string)


# Load saved data from .dat file
func load_settings_data() -> void:
	var loaded_data
	if not FileAccess.file_exists(SAVE_DIRECTORY + SETTINGS_FILE_NAME):
		return

	var config_file = FileAccess.open(SAVE_DIRECTORY + SETTINGS_FILE_NAME, FileAccess.READ)
	while config_file.get_position() < config_file.get_length():
		var json_string = config_file.get_line()
		
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		loaded_data = json.get_data()

	SettingsData.call("_load_settings_data", loaded_data)
