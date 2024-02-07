extends Control


onready var settings_button = $Bars/Header/VBoxContainer/SettingsButton
onready var current_menu = $Bars/PageTitle/VBoxContainer/HBoxContainer/CurrentMenu
onready var return_button = $Bars/PageTitle/VBoxContainer/HBoxContainer/ReturnButton


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()


func handle_connecting_signals() -> void:
	SettingsSignalBus.connect("show_main_menu", self, "on_menu_changed", ["MAIN"])
	SettingsSignalBus.connect("show_settings_menu", self, "on_menu_changed", ["SETTINGS"])
	SettingsSignalBus.connect("show_online_menu", self, "on_menu_changed", ["ONLINE"])


func on_menu_changed(menu: String) -> void:
	current_menu.set_text(menu)


func _on_SettingsButton_button_up():
	SettingsSignalBus.emit_show_settings_menu()


func _on_ReturnButton_button_up():
	SettingsSignalBus.emit_show_main_menu()


func _on_QuitButton_button_up():
	get_tree().quit()
