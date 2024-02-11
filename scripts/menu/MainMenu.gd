extends Control


# Preload the game scenes as packed scenes
var steam_scene = preload("res://scenes/SteamGame.tscn")
var local_scene = preload("res://scenes/LocalGame.tscn")
#var local_texture = preload("res://assets/menu/main/icons/active_local_icon.png")

# Onready var for primary buttons
onready var online_tab = $MainPane/OnlineTab
onready var local_tab = $MainPane/LocalTab
onready var training_tab = $MainPane/TrainingTab
onready var records_tab = $MainPane/RecordsTab
onready var quit_tab = $MainPane/QuitTab

# Onready var for Steam
onready var steam_connection_panel = $MainPane/SteamConnectionPanel
onready var steam_server_start = $MainPane/SteamConnectionPanel/SelectionContainer/ServerButton
onready var steam_client_start = $MainPane/SteamConnectionPanel/SelectionContainer/ClientButton
onready var steamid_field = $MainPane/SteamConnectionPanel/EntryContainer/IdField


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()


# Connect to button signals
func handle_connecting_signals() -> void:
	
#	# Loops through the menu icons and connects all their button_up signals to the on_icon_clicked function
#	for icon in $MainPane/MenuIcons.get_children():
#		icon.connect("button_up", self, "on_icon_clicked")
	
	# Connect signals for the menu's primary buttons
	$MainPane/MenuButtons/OnlineButton.base_button.connect("toggled", self, "on_online_button_toggled")
	$MainPane/MenuButtons/LocalButton.base_button.connect("toggled", self, "on_local_button_toggled")
	$MainPane/MenuButtons/TrainingButton.base_button.connect("toggled", self, "on_training_button_toggled")
	$MainPane/MenuButtons/RecordsButton.base_button.connect("toggled", self, "on_records_button_toggled")
	
	# Connect signals for submenu buttons
	$MainPane/OnlineTab/RPCButton.connect("toggled", self, "on_rpc_button_toggled")
	$MainPane/OnlineTab/SteamButton.connect("toggled", self, "on_steam_button_toggled")
	
	# Connect signals for online play
	steam_server_start.connect("button_up", self, "on_steam_server_pressed")
	steam_client_start.connect("button_up", self, "on_steam_client_pressed")


# When a menu icon is clicked, the connection panels are hidden
func on_icon_clicked() -> void:
	steam_connection_panel.visible = false


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
func on_online_button_toggled(button_pressed):
	if button_pressed == true:
		SettingsSignalBus.emit_show_online_menu()


#
func on_local_button_toggled(button_pressed):
	if button_pressed == true:
		NetworkGlobal.NETWORK_TYPE = 0
		GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
		get_tree().change_scene_to(local_scene)


#
func on_training_button_toggled(button_pressed):
	if button_pressed == true:
		training_tab.visible = true
	else:
		training_tab.visible = false


#
func on_records_button_toggled(button_pressed):
	if button_pressed == true:
		records_tab.visible = true
	else:
		records_tab.visible = false


#
func on_steam_button_toggled(button_pressed):
	if button_pressed == true:
		steam_connection_panel.visible = true
	else:
		steam_connection_panel.visible = false
