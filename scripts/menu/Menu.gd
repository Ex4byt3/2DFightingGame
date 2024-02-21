extends Control


# Onready variables for the various menus and header
onready var main_menu = $MainMenu
onready var settings_menu = $SettingsMenu
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
	#MenuSignalBus.emit_reset_buttons()
	
	if not menu == "SETTINGS" and settings_menu.visible == true:
		MenuSignalBus.emit_set_settings_dict(SettingsData.create_storage_dictionary())
	
	match menu:
		"MAIN": # Main menu
			main_menu.visible = true
			settings_menu.visible = false
			online_menu.visible = false
			
		"SETTINGS": # Settings menu
			main_menu.visible = false
			settings_menu.visible = true
			online_menu.visible = false
			
		"ONLINE": # Online menu
			main_menu.visible = false
			settings_menu.visible = false
			online_menu.visible = true
