extends Control


var user_choice_dialogue = preload("res://scenes/gui/general/UserChoiceDialogue.tscn")

const menu_preloads: Dictionary = {
	"TitleScreen": preload("res://scenes/gui/menu/title/TitleScreen.tscn"),
	"HeaderMenu": preload("res://scenes/gui/menu/header/HeaderMenu.tscn"),
	"SettingsOverlay": preload("res://scenes/gui/menu/settings/SettingsOverlay.tscn"),
	"MainMenu": preload("res://scenes/gui//menu/main/MainMenu.tscn"),
	"OnlineMenu": preload("res://scenes/gui/menu/online/OnlineMenu.tscn"),
	"LobbyMenu": preload("res://scenes/gui/menu/lobby/LobbyMenu.tscn"),
	"CharacterSelect": preload("res://scenes/gui/menu/character_select/CharacterSelect.tscn")
}

var menu_tree: Array = ["TitleScreen"]
var dialogue: Node
var lobby_id: int
var in_match: bool = false
var in_dialogue: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


##################################################
# ONREADY FUNCTIONS
##################################################
# Connect to button signals
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "setup_menu", "_setup_menu")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "change_screen", "_change_screen")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "goto_previous_menu", "_goto_previous_menu")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "toggle_settings_visibility", "_toggle_settings_visibility")
	
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "create_match", "_create_match")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "leave_match", "_leave_match")


##################################################
# SCREEN FUNCTIONS
##################################################
func _setup_menu() -> void:
	var menu_location = menu_tree.back()
	
	var this_menu = menu_preloads.get(menu_tree.back()).instantiate()
	var this_menu_header = menu_preloads.HeaderMenu.instantiate()
	var this_settings_overlay = menu_preloads.SettingsOverlay.instantiate()
	
	this_settings_overlay.visible = false
	
	add_child(this_menu)
	add_child(this_menu_header)
	add_child(this_settings_overlay)
	move_child(this_menu, 0)
	
	print("[SYSTEM] Menu added to tree: MainMenu")
	
	for child in get_children():
		if child.name == "TitleScreen":
			$TitleScreen.queue_free()


func _change_screen(current_scene, target_scene: PackedScene, is_backout: bool) -> void:
	var this_scene = target_scene.instantiate()
	this_scene.visible = false
	
	add_child(this_scene)
	move_child(this_scene, 0)
	
	this_scene.visible = true
	current_scene.queue_free()
	
	if not is_backout:
		var new_tree_element = get_child(0).name
		menu_tree.append(new_tree_element)
		print("[SYSTEM] Menu added to tree: " + new_tree_element)


func _toggle_settings_visibility() -> void:
	var settings_node = get_child(2)
	if settings_node.visible:
		settings_node.visible = false
		print("saving")
		SaveManager.call("save_settings")
	else:
		settings_node.visible = true


##################################################
# MENU TREE FUNCTIONS
##################################################
func _goto_previous_menu(chosen_menu) -> void:
	_pop_removed_menus(chosen_menu)
	MenuSignalBus.emit_change_screen(get_child(0), menu_preloads.get(chosen_menu), true)


func _pop_removed_menus(pop_to: String) -> void:
	for menu in menu_tree:
		if not menu_tree.back() == pop_to:
			print("[SYSTEM] Menu removed from tree: " + str(menu_tree.pop_back()))


##################################################
# MATCH RELATED FUNCTIONS
##################################################
func _create_match() -> void:
	in_match = true
	for item in get_children():
		item.queue_free()


func _leave_match() -> void:
	in_match = false
	_setup_menu()


##################################################
# INPUT FUNCTIONS
##################################################
func _input(event) -> void:
	if event.is_action_released("ui_cancel") and not in_dialogue and not in_match:
		match menu_tree.back():
			"TitleScreen":
				dialogue = user_choice_dialogue.instantiate()
				dialogue.title_text = "Quitting Game"
				dialogue.context_text = "Are you sure you want to quit the game?"
				add_child(dialogue)
				in_dialogue = true
			"MainMenu":
				for child in get_children():
					if not child.name == "MainMenu":
						child.queue_free()
				_goto_previous_menu("TitleScreen")
			"OnlineMenu":
				_goto_previous_menu("MainMenu")
			"LobbyMenu":
				dialogue = user_choice_dialogue.instantiate()
				dialogue.title_text = "Leaving Lobby"
				dialogue.context_text = "Are you sure you want to leave this lobby?"
				add_child(dialogue)
				in_dialogue = true
			"SettingsOverlay":
				MenuSignalBus.emit_toggle_settings_visibility()
			"CharacterSelect":
				pass


##################################################
# DIALOGUE FUNCTIONS
##################################################
func _on_dialogue_accepted() -> void:
	match menu_tree.back():
		"TitleScreen":
			get_tree().quit()
		"MainMenu":
			pass
		"OnlineMenu":
			pass
		"LobbyMenu":
			MenuSignalBus.emit_exit_lobby()
			_goto_previous_menu("OnlineMenu")
		"SettingsOverlay":
			pass
		"CharacterSelect":
			pass
	dialogue.queue_free()
	in_dialogue = false


func _on_dialogue_rejected() -> void:
	dialogue.queue_free()
	in_dialogue = false


##################################################
# HELPER FUNCTIONS
##################################################

