extends Control


# Preload the game scenes as packed scenes
var steam_scene = preload("res://scenes/SteamGame.tscn")
var rpc_scene = preload("res://scenes/RpcGame.tscn")
var local_scene = preload("res://scenes/LocalGame.tscn")

# Onready var for menu screens
onready var menu_header = $MenuHeader
onready var main_menu = $Main
onready var settings_menu = $SettingsMenu
onready var online_menu = $OnlineMenu

# Onready var for primary buttons
onready var online_tab = $Main/MainPane/OnlineTab
onready var local_tab = $Main/MainPane/LocalTab
onready var training_tab = $Main/MainPane/TrainingTab
onready var records_tab = $Main/MainPane/RecordsTab
onready var quit_tab = $Main/MainPane/QuitTab

#onready var settings_button = $Main/MainPane/HeaderBar/SettingsButton
onready var versus_button = $Main/MainPane/LocalTab/VersusButton
onready var online_button = $Main/MainPane/MenuIcons/OnlineButton

# Onready var for RPC
onready var rpc_connection_panel = $Main/MainPane/RPCConnectionPanel
onready var rpc_server_start = $Main/MainPane/RPCConnectionPanel/SelectionContainer/ServerButton
onready var rpc_client_start = $Main/MainPane/RPCConnectionPanel/SelectionContainer/ClientButton
onready var rpc_host_field = $Main/MainPane/RPCConnectionPanel/EntryContainer/HostField
onready var rpc_port_field = $Main/MainPane/RPCConnectionPanel/EntryContainer/PortField

# Onready var for Steam
onready var steam_connection_panel = $Main/MainPane/SteamConnectionPanel
onready var steam_server_start = $Main/MainPane/SteamConnectionPanel/SelectionContainer/ServerButton
onready var steam_client_start = $Main/MainPane/SteamConnectionPanel/SelectionContainer/ClientButton
onready var steamid_field = $Main/MainPane/SteamConnectionPanel/EntryContainer/IdField

# Signals for the main menu
signal show_online_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()


# Connect to button signals
func handle_connecting_signals() -> void:
	
	# Loops through the menu icons and connects all their button_up signals to the on_icon_clicked function
	for icon in $Main/MainPane/MenuIcons.get_children():
		icon.connect("button_up", self, "on_icon_clicked")
	
	# Signals for online play
	rpc_server_start.connect("button_up", self, "on_rpc_server_pressed")
	rpc_client_start.connect("button_up", self, "on_rpc_client_pressed")
	steam_server_start.connect("button_up", self, "on_steam_server_pressed")
	steam_client_start.connect("button_up", self, "on_steam_client_pressed")
	
	# Signal for local play
	versus_button.connect("button_up", self, "on_versus_button_pressed")
	
	# Connect signals used to change the currently shown menu
	SettingsSingalBus.connect("show_main_menu", self, "change_shown_menu", [1])
	SettingsSingalBus.connect("show_settings_menu", self, "change_shown_menu", [2])
	SettingsSingalBus.connect("show_online_menu", self, "change_shown_menu", [3])
	
	# Connect signals used for the settings menu
	#settings_button.connect("button_up", self, "on_settings_pressed")
	#settings_menu.connect("exit_settings_menu", self, "on_exit_settings_menu")
	
	# Connect signals used for the online menu
	#online_button.connect("button_up", self, "on_online_pressed")
	#online_menu.connect("exit_online_menu", self, "on_exit_online_menu")


# When a menu icon is clicked, the connection panels are hidden
func on_icon_clicked() -> void:
	rpc_connection_panel.visible = false
	steam_connection_panel.visible = false


# 
func on_rpc_server_pressed() -> void:
	NetworkGlobal.NETWORK_TYPE = 1
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.RPC_IS_HOST = true
	NetworkGlobal.RPC_IP = rpc_host_field.get_text()
	NetworkGlobal.RPC_PORT = int(rpc_port_field.get_text())
	get_tree().change_scene_to(rpc_scene)
	#GameSignalBus.emit_rpc_server_start(rpc_host_field.get_text(), int(rpc_port_field.get_text()))
	#get_tree().change_scene_to(main_scene)


#
func on_rpc_client_pressed() -> void:
	NetworkGlobal.NETWORK_TYPE = 1
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.RPC_IS_HOST = false
	NetworkGlobal.RPC_IP = rpc_host_field.get_text()
	NetworkGlobal.RPC_PORT = int(rpc_port_field.get_text())
	get_tree().change_scene_to(rpc_scene)
	#GameSignalBus.emit_rpc_client_start(rpc_host_field.get_text(), int(rpc_port_field.get_text()))
	#get_tree().change_scene_to(main_scene)


#
func on_steam_server_pressed() -> void:
	NetworkGlobal.NETWORK_TYPE = 2
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.STEAM_IS_HOST = true
	get_tree().change_scene_to(steam_scene)


#
func on_steam_client_pressed() -> void:
	NetworkGlobal.NETWORK_TYPE = 2
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.STEAM_IS_HOST = false
	NetworkGlobal.STEAM_OPP_ID = int(steamid_field.text)
	get_tree().change_scene_to(steam_scene)


#
func on_versus_button_pressed() -> void:
	NetworkGlobal.NETWORK_TYPE = 0
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	get_tree().change_scene_to(local_scene)


func change_shown_menu(menu: int) -> void:
	match menu:
		1: # Main menu
			main_menu.visible = true
			settings_menu.visible = false
			online_menu.visible = false
			
		2: # Settings menu
			main_menu.visible = false
			settings_menu.visible = true
			online_menu.visible = false
			
		3: # Online menu
			main_menu.visible = false
			settings_menu.visible = false
			online_menu.visible = true


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
		SettingsSingalBus.emit_show_online_menu()
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
