extends Control

onready var online_tab = $OnlineTab
onready var local_tab = $LocalTab
onready var training_tab = $TrainingTab
onready var records_tab = $RecordsTab
onready var quit_tab = $QuitTab

onready var quit_desktop = $QuitTab/DesktopButton

func _ready():
	#$MenuIcons/OnlineButton.grab_focus()
	pass

func _on_OnlineButton_toggled(button_pressed):
	if button_pressed == true:
		online_tab.visible = true
	else:
		online_tab.visible = false

func _on_LocalButton_toggled(button_pressed):
	if button_pressed == true:
		local_tab.visible = true
	else:
		local_tab.visible = false

func _on_TrainingButton_toggled(button_pressed):
	if button_pressed == true:
		training_tab.visible = true
	else:
		training_tab.visible = false

func _on_RecordsButton_toggled(button_pressed):
	if button_pressed == true:
		records_tab.visible = true
	else:
		records_tab.visible = false

func _on_QuitButton_toggled(button_pressed):
	if button_pressed == true:
		quit_tab.visible = true
	else:
		quit_tab.visible = false

func _on_DesktopButton_pressed():
	get_tree().quit()
