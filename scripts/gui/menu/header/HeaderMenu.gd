extends Control


var menu_tree_button = preload("res://scenes/gui/menu/header/MenuTreeButton.tscn")

@onready var match_settings_button = $Bars/TopBar/MarginContainer/HBoxContainer/ButtonContainer/MatchSettingsButton
@onready var settings_button = $Bars/TopBar/MarginContainer/HBoxContainer/ButtonContainer/SettingsButton
@onready var quit_button = $Bars/TopBar/MarginContainer/HBoxContainer/ButtonContainer/QuitButton
@onready var menu_tree_button_container = $Bars/BottomBar/MarginContainer/HBoxContainer/MenuTreeButtonContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	call_deferred("_update_menu_tree_return")


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "change_screen", "_change_screen")
	MenuSignalBus._connect_Signals(settings_button, self, "pressed", "_on_settings_button_pressed")
	MenuSignalBus._connect_Signals(quit_button, self, "button_up", "_on_quit_button_pressed")


func _change_screen(_current_screen, _target_screen, _is_backout) -> void:
	_update_menu_tree_return()


func _update_menu_tree_return() -> void:
	for button in menu_tree_button_container.get_children():
		button.queue_free()
		
	var menu_tree = get_parent().menu_tree
	
	var count = 0
	for menu in menu_tree:
		if not menu == "TitleScreen":
			var new_button = menu_tree_button.instantiate()
			menu_tree_button_container.add_child(new_button)
			
			new_button.menu_name.set_text(menu)
			if count == 0:
				new_button.icon.visible = false
			
			var previous_menu_signal = new_button.button.connect("button_up", MenuSignalBus.emit_goto_previous_menu.bind(menu))
			if previous_menu_signal > OK:
				print("[SYSTEM] Connecting to menu tree button failed: "+str(previous_menu_signal))
			count += 1

func _on_match_settings_button_pressed() -> void:
	MenuSignalBus.emit_toggle_match_settings_visibility()

func _on_settings_button_pressed() -> void:
	MenuSignalBus.emit_toggle_settings_visibility()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_SettingsButton_button_up():
	MenuSignalBus.emit_toggle_settings_visibility()


func _on_QuitButton_button_up():
	get_tree().quit()
