extends Control


onready var back_button = $HeaderBar/BackButton
onready var graphics_tab = $GraphicsTab


signal exit_settings_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	back_button.connect("button_up", self, "return_to_main")


func return_to_main() -> void:
	emit_signal("exit_settings_menu")
	SettingsSingalBus.emit_set_settings_dict(SettingsData.create_storage_dictionary())


func _on_GraphicsButton_toggled(button_pressed):
	if button_pressed == true:
		graphics_tab.visible = true
	else:
		graphics_tab.visible = false
