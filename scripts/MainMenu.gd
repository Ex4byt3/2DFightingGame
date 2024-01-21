extends Control


# Preload the game scenes as packed scenes
var steam_scene = preload("res://scenes/SteamGame.tscn")
var rpc_scene = preload("res://scenes/RpcGame.tscn")
var local_scene = preload("res://scenes/LocalGame.tscn")


# Onready var for primary buttons
onready var online_tab = $PrimaryMenu/OnlineTab
onready var local_tab = $PrimaryMenu/LocalTab
onready var training_tab = $PrimaryMenu/TrainingTab
onready var records_tab = $PrimaryMenu/RecordsTab
onready var quit_tab = $PrimaryMenu/QuitTab

onready var settings_button = $PrimaryMenu/HeaderBar/SettingsButton
onready var versus_button = $PrimaryMenu/LocalTab/VersusButton

# Onready var for RPC
onready var rpc_connection_panel = $PrimaryMenu/RPCConnectionPanel
onready var rpc_server_start = $PrimaryMenu/RPCConnectionPanel/SelectionContainer/ServerButton
onready var rpc_client_start = $PrimaryMenu/RPCConnectionPanel/SelectionContainer/ClientButton
onready var rpc_host_field = $PrimaryMenu/RPCConnectionPanel/EntryContainer/HostField
onready var rpc_port_field = $PrimaryMenu/RPCConnectionPanel/EntryContainer/PortField

# Onready var for Steam
onready var steam_connection_panel = $PrimaryMenu/SteamConnectionPanel
onready var steam_server_start = $PrimaryMenu/SteamConnectionPanel/SelectionContainer/ServerButton
onready var steam_client_start = $PrimaryMenu/SteamConnectionPanel/SelectionContainer/ClientButton
onready var steamid_field = $PrimaryMenu/SteamConnectionPanel/EntryContainer/IdField

# Onready var for menu screens
onready var primary_menu = $PrimaryMenu
onready var settings_menu = $SettingsMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()


# Connect to button signals
func handle_connecting_signals() -> void:
	
	# Loops through the menu icons and connects all their button_up signals to the on_icon_clicked function
	for icon in $PrimaryMenu/MenuIcons.get_children():
		icon.connect("button_up", self, "on_icon_clicked")
	
	# Signals for online play
	rpc_server_start.connect("button_up", self, "on_rpc_server_pressed")
	rpc_client_start.connect("button_up", self, "on_rpc_client_pressed")
	steam_server_start.connect("button_up", self, "on_steam_server_pressed")
	steam_client_start.connect("button_up", self, "on_steam_client_pressed")
	
	# Signal for local play
	versus_button.connect("button_up", self, "on_versus_button_pressed")
	
	# Connect signals used for the settings menu
	settings_button.connect("button_up", self, "on_settings_pressed")
	settings_menu.connect("exit_settings_menu", self, "on_exit_settings_menu")


# When a menu icon is clicked, the connection panels are hidden
func on_icon_clicked() -> void:
	rpc_connection_panel.visible = false
	steam_connection_panel.visible = false

# 
func on_rpc_server_pressed() -> void:
	NetworkGlobal.NETWORK_TYPE = 1
	NetworkGlobal.RPC_IS_HOST = true
	NetworkGlobal.RPC_IP = rpc_host_field.get_text()
	NetworkGlobal.RPC_PORT = int(rpc_port_field.get_text())
	get_tree().change_scene_to(rpc_scene)
	#GameSignalBus.emit_rpc_server_start(rpc_host_field.get_text(), int(rpc_port_field.get_text()))
	#get_tree().change_scene_to(main_scene)


#
func on_rpc_client_pressed() -> void:
	NetworkGlobal.NETWORK_TYPE = 1
	NetworkGlobal.RPC_IS_HOST = false
	NetworkGlobal.RPC_IP = rpc_host_field.get_text()
	NetworkGlobal.RPC_PORT = int(rpc_port_field.get_text())
	get_tree().change_scene_to(rpc_scene)
	#GameSignalBus.emit_rpc_client_start(rpc_host_field.get_text(), int(rpc_port_field.get_text()))
	#get_tree().change_scene_to(main_scene)


#
func on_steam_server_pressed() -> void:
	NetworkGlobal.NETWORK_TYPE = 2
	NetworkGlobal.STEAM_IS_HOST = true
	get_tree().change_scene_to(steam_scene)


#
func on_steam_client_pressed() -> void:
	NetworkGlobal.NETWORK_TYPE = 2
	NetworkGlobal.STEAM_IS_HOST = false
	NetworkGlobal.STEAM_OPP_ID = int(steamid_field.text)
	get_tree().change_scene_to(steam_scene)


#
func on_versus_button_pressed() -> void:
	NetworkGlobal.NETWORK_TYPE = 0
	get_tree().change_scene_to(local_scene)


# Makes the settings menu visible and hides primary menu
func on_settings_pressed() -> void:
	settings_menu.visible = true
	primary_menu.visible = false


# Makes the settings menu invisible and makes the primary menu visible
func on_exit_settings_menu() -> void:
	settings_menu.visible = false
	primary_menu.visible = true


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
