extends Control

onready var online_tab = $OnlineTab
onready var local_tab = $LocalTab
onready var training_tab = $TrainingTab
onready var records_tab = $RecordsTab
onready var quit_tab = $QuitTab

onready var rpc_connection_panel = $RPCConnectionPanel
onready var steam_connection_panel = $SteamConnectionPanel

func _ready():
	pass

func _on_OnlineButton_toggled(button_pressed):
	if button_pressed == true:
		online_tab.visible = true
		rpc_connection_panel.visible = false
		steam_connection_panel.visible = false
	else:
		online_tab.visible = false

func _on_LocalButton_toggled(button_pressed):
	if button_pressed == true:
		local_tab.visible = true
		rpc_connection_panel.visible = false
		steam_connection_panel.visible = false
	else:
		local_tab.visible = false

func _on_TrainingButton_toggled(button_pressed):
	if button_pressed == true:
		training_tab.visible = true
		rpc_connection_panel.visible = false
		steam_connection_panel.visible = false
	else:
		training_tab.visible = false

func _on_RecordsButton_toggled(button_pressed):
	if button_pressed == true:
		records_tab.visible = true
		rpc_connection_panel.visible = false
		steam_connection_panel.visible = false
	else:
		records_tab.visible = false

func _on_QuitButton_toggled(button_pressed):
	if button_pressed == true:
		quit_tab.visible = true
		rpc_connection_panel.visible = false
		steam_connection_panel.visible = false
	else:
		quit_tab.visible = false

func _on_DesktopButton_pressed():
	get_tree().quit()

func _on_RPCButton_toggled(button_pressed):
	if button_pressed == true:
		rpc_connection_panel.visible = true
	else:
		rpc_connection_panel.visible = false

func _on_SteamButton_toggled(button_pressed):
	if button_pressed == true:
		steam_connection_panel.visible = true
	else:
		steam_connection_panel.visible = false

func _on_SettingsButton_pressed():
	OS.set_borderless_window(true)
	OS.set_window_fullscreen(true)
