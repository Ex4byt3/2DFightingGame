extends Control

onready var online_submenu = $OnlineSubmenu
onready var local_submenu = $LocalSubmenu
onready var training_submenu = $TrainingSubmenu
onready var records_submenu = $RecordsSubmenu
onready var quit_submenu = $QuitSubmenu

func _ready():
	#$MenuIcons/OnlineButton.grab_focus()
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

func _on_OnlineButton_toggled(button_pressed):
	online_submenu.visible = not online_submenu.visible

func _on_LocalButton_toggled(button_pressed):
	local_submenu.visible = not local_submenu.visible

func _on_TrainingButton_toggled(button_pressed):
	training_submenu.visible = not training_submenu.visible

func _on_RecordsButton_toggled(button_pressed):
	records_submenu.visible = not records_submenu.visible

func _on_QuitButton_toggled(button_pressed):
	quit_submenu.visible = not quit_submenu.visible

