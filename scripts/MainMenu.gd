extends Control

# Preload the game scene as a packed scene
var game_scene = preload("res://scenes/Game.tscn") as PackedScene

onready var online_tab = $PrimaryMenu/OnlineTab
onready var local_tab = $PrimaryMenu/LocalTab
onready var training_tab = $PrimaryMenu/TrainingTab
onready var records_tab = $PrimaryMenu/RecordsTab
onready var quit_tab = $PrimaryMenu/QuitTab
onready var settings_button = $PrimaryMenu/HeaderBar/SettingsButton
onready var rpc_connection_panel = $PrimaryMenu/RPCConnectionPanel
onready var steam_connection_panel = $PrimaryMenu/SteamConnectionPanel
onready var rpc_server_start = $PrimaryMenu/RPCConnectionPanel/SelectionContainer/ServerButton
onready var rpc_client_start = $PrimaryMenu/RPCConnectionPanel/SelectionContainer/ClientButton
onready var steam_server_start = $PrimaryMenu/SteamConnectionPanel/SelectionContainer/ServerButton
onready var steam_client_start = $PrimaryMenu/SteamConnectionPanel/SelectionContainer/ClientButton

onready var primary_menu = $PrimaryMenu
onready var settings_menu = $SettingsMenu

func _ready():
	handle_connecting_signals()

# create connections 
func handle_connecting_signals() -> void:
	settings_button.connect("button_up", self, "open_settings")
	
	# Signals to open the game
	rpc_server_start.connect("button_up", self, "start_rpc_server")
	rpc_client_start.connect("button_up", self, "start_rpc_client")
	steam_server_start.connect("button_up", self, "start_steam_server")
	steam_client_start.connect("button_up", self, "start_steam_client")
	
	for icon in $PrimaryMenu/MenuIcons.get_children():
		icon.connect("button_up", self, "on_icon_clicked")

func open_settings() -> void:
	pass

func start_rpc_server() -> void:
	get_tree().change_scene_to(game_scene)

func on_icon_clicked() -> void:
	rpc_connection_panel.visible = false
	steam_connection_panel.visible = false

func _on_OnlineButton_toggled(button_pressed):
	if button_pressed == true:
		online_tab.visible = true
	else:
		online_tab.visible = false

func _on_LocalButton_toggled(button_pressed):
	if button_pressed == true:
		local_tab.visible = true
		
		# Example of adding a game scene to the menu scene, might need to hide the menu when shown
		# var new_game_scene = game_scene.instance()
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
	settings_menu.visible = true
	primary_menu.visible = false
	
