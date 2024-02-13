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
	SettingsSignalBus.connect("show_main_menu", self, "change_shown_menu", [1])
	SettingsSignalBus.connect("show_settings_menu", self, "change_shown_menu", [2])
	SettingsSignalBus.connect("show_online_menu", self, "change_shown_menu", [3])


# When a signal to change the currently displayed menu is recieved
# this function checks the menu to be shown and displays it
func change_shown_menu(menu: int) -> void:
	#SettingsSignalBus.emit_reset_buttons()
	
	if not menu == 2 and settings_menu.visible == true:
		SettingsSignalBus.emit_set_settings_dict(SettingsData.create_storage_dictionary())
	
	match menu:
		1: # Main menu
			main_menu.visible = true
			settings_menu.visible = false
			online_menu.visible = false
			
		2: # Settings menu
			main_menu.visible = false
			settings_menu.visible = true
			online_menu.visible = false
			
		3: # Online menu
			main_menu.visible = false
			settings_menu.visible = false
			online_menu.visible = true
