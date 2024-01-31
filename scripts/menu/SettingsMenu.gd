extends Control


# Onready variables
onready var graphics_tab = $MainPane/GraphicsTab
onready var sound_tab = $MainPane/SoundTab
onready var network_tab = $MainPane/NetworkTab
onready var keybinds_tab = $MainPane/KeybindsTab
onready var accessibility_tab = $MainPane/AccessibilityTab


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()


func handle_connecting_signals() -> void:
	pass


func _on_GraphicsButton_toggled(button_pressed):
	if button_pressed == true:
		graphics_tab.visible = true
	else:
		graphics_tab.visible = false


func _on_SoundButton_toggled(button_pressed):
	if button_pressed == true:
		sound_tab.visible = true
	else:
		sound_tab.visible = false


func _on_NetworkButton_toggled(button_pressed):
	if button_pressed == true:
		network_tab.visible = true
	else:
		network_tab.visible = false


func _on_KeybindsButton_toggled(button_pressed):
	if button_pressed == true:
		keybinds_tab.visible = true
	else:
		keybinds_tab.visible = false


func _on_AccessibilityButton_toggled(button_pressed):
	if button_pressed == true:
		accessibility_tab.visible = true
	else:
		accessibility_tab.visible = false
