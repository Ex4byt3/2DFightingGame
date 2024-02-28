extends Control


onready var settings_button = $Bars/Header/VBoxContainer/SettingsButton
onready var current_menu = $Bars/PageTitle/VBoxContainer/HBoxContainer/CurrentMenu
onready var return_button = $Bars/PageTitle/VBoxContainer/HBoxContainer/ReturnButton


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "change_menu", "_on_change_menu")


func _on_change_menu(menu: String) -> void:
	current_menu.set_text(menu)


func _on_SettingsButton_button_up():
	MenuSignalBus.emit_change_menu("SETTINGS")


func _on_ReturnButton_button_up():
	MenuSignalBus.emit_change_menu("MAIN")


func _on_QuitButton_button_up():
	get_tree().quit()
