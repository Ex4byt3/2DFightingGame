extends Control


# Onready variables for the various menus and header
onready var main_menu = $MainMenu
onready var settings_overlay = $SettingsOverlay
onready var online_menu = $OnlineMenu
onready var menu_header = $MenuHeader


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()


# Connect to button signals
func handle_connecting_signals() -> void:
	# Connect signals used to change the currently shown menu
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "change_menu", "_on_change_menu")


# When a signal to change the currently displayed menu is recieved
# this function checks the menu to be shown and displays it
func _on_change_menu(menu: String) -> void:
	match menu:
		"MAIN": # Main menu
			main_menu.visible = true
			online_menu.visible = false
			# If hiding the settings overlay, save settings
			if settings_overlay.visible:
				settings_overlay.visible = false
				MenuSignalBus.emit_set_settings_dict(SettingsData.create_storage_dictionary())
		
		"ONLINE": # Online menu
			main_menu.visible = false
			online_menu.visible = true
			# If hiding the settings overlay, save settings
			if settings_overlay.visible:
				settings_overlay.visible = false
				MenuSignalBus.emit_set_settings_dict(SettingsData.create_storage_dictionary())
		
		"SETTINGS": # Settings menu
			# If hiding the settings overlay, save settings
			if settings_overlay.visible:
				settings_overlay.visible = false
				MenuSignalBus.emit_set_settings_dict(SettingsData.create_storage_dictionary())
			# Else show the overlay
			else:
				settings_overlay.visible = true
