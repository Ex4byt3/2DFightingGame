extends Control


onready var searchbar = $SettingsHeader/VBoxContainer/Searchbar
onready var category_checks = $MainPane/CategoryChecks
onready var settings_container = $MainPane/ScrollContainer/SettingsContainer

var categories: Dictionary = {
	"Display": true,
	"Sound": true,
	"Lobby": true,
	"Network": true,
	"Keybindings": true,
	"Accessibility": true
}


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(searchbar, self, "text_changed", "_filter_settings")


##################################################
# SETTINGS SEARCH FUNCTIONALITY
##################################################
func _filter_settings(_filter) -> void:
	var search_text = searchbar.text
	
	for setting in settings_container.get_children():
		if not "Title" in setting.name:
			if check_setting_visiblity(setting, search_text):
				setting.visible = true
			else:
				setting.visible = false


func check_setting_visiblity(setting, search_text: String):
	var required_checks = 2
	var passed_checks = 0
	
	print(setting.option_label)
	if setting.option_label.findn(search_text) > -1:
		passed_checks += 1
	
	for category in categories.keys():
		if categories.get(category) == true and category == setting.category:
			passed_checks += 1
	
	if required_checks == passed_checks:
		return true
	else:
		 return false
