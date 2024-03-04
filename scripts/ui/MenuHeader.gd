extends Control


var menu_tree_button = preload("res://scenes/ui/ReturnButton.tscn")

@onready var settings_button = $Bars/Header/VBoxContainer/SettingsButton
@onready var menu_tree_return = $Bars/PageTitle/VBoxContainer/HBoxContainer/MenuTreeReturn


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	call_deferred("_update_menu_tree_return")


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "change_screen", "_change_screen")


func _change_screen(_current_screen, _target_screen, _is_backout) -> void:
	_update_menu_tree_return()


func _update_menu_tree_return() -> void:
	for item in menu_tree_return.get_children():
		item.queue_free()
		
	var menu_tree = get_parent().menu_tree
	for menu in menu_tree:
		if not menu == "TitleScreen":
			var new_button = menu_tree_button.instantiate()
			new_button.title = menu
			menu_tree_return.add_child(new_button)
			
			var previous_menu_signal = new_button.button_area.connect("button_up", Callable(get_parent(), "_goto_previous_menu").bind(menu))
			if previous_menu_signal > OK:
				print("[SYSTEM] Connecting to menu tree button failed: "+str(previous_menu_signal))


func _on_SettingsButton_button_up():
	MenuSignalBus.emit_toggle_settings_visibility()


func _on_QuitButton_button_up():
	get_tree().quit()
