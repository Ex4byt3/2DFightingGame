extends Control

var user_choice_dialogue = preload("res://scenes/ui/UserChoiceDialogue.tscn")

# Onready variables for the various menus and header
onready var main_menu = $MainMenu
onready var online_menu = $OnlineMenu
onready var menu_header = $MenuHeader
onready var settings_overlay = $SettingsOverlay

var menu_tree: Array = ["Title"]
var quit_dialogue


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()
	menu_header.grab_focus()
	_set_header_bottom_neighbour(menu_header, main_menu.online_button)


# Connect to button signals
func handle_connecting_signals() -> void:
	# Connect signals used to change the currently shown menu
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "change_menu", "_on_change_menu")


# When a signal to change the currently displayed menu is recieved
# this function checks the menu to be shown and displays it
func _on_change_menu(menu: String) -> void:
	match menu:
		"MAIN": # Main menu
			menu_header.grab_focus()
			_set_header_bottom_neighbour(menu_header, main_menu.online_button)
			
			main_menu.visible = true
			online_menu.visible = false
			# If hiding the settings overlay, save settings
			if settings_overlay.visible:
				settings_overlay.visible = false
				MenuSignalBus.emit_set_settings_dict(SettingsData.create_storage_dictionary())
		
		"ONLINE": # Online menu
			menu_header.grab_focus()
			_set_header_bottom_neighbour(menu_header, online_menu.open_lobby_popup)
			
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


##################################################
# INPUT FUNCTIONS
##################################################
func _input(event) -> void:
	if event.is_action_released("ui_cancel"):
		if settings_overlay.visible == true:
			menu_header.settings_button.pressed = false
			settings_overlay.visible = false
		else:
			quit_dialogue = user_choice_dialogue.instance()
			quit_dialogue.title_text = "Quitting Game"
			quit_dialogue.context_text = "Are you sure you want to quit the game?"
			add_child(quit_dialogue)


##################################################
# DIALOGUE FUNCTIONS
##################################################
func _on_dialogue_accepted() -> void:
	get_tree().quit()


func _on_dialogue_rejected() -> void:
	quit_dialogue.queue_free()

##################################################
# CONTROLS FUNCTIONS
##################################################
func _set_header_bottom_neighbour(current_node, bottom_neighbour) -> void:
	current_node.set_focus_neighbour(margin_bottom, get_path_to(bottom_neighbour))
