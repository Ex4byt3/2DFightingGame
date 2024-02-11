extends Control

var rpc_scene = preload("res://scenes/RpcGame.tscn")
var steam_scene = preload("res://scenes/SteamGame.tscn")

onready var lobby_tile = preload("res://scenes/menu/LobbyTile.tscn")

# Onready variables for lobby searches
onready var lobby_search_bar = $MainPane/OnlineMenuBar/SearchPane/LineEdit
onready var lobby_type_filter = $MainPane/OnlineMenuBar/SearchPane/Filters/LobbyType
onready var lobby_state_filter = $MainPane/OnlineMenuBar/SearchPane/Filters/LobbyState

# Onready variables for the lobby creation popup
onready var lobby_button = $MainPane/OnlineMenuBar/LobbyButton
onready var lobby_creation_popup = $MainPane/LobbyCreationPopup
onready var lobby_name = $MainPane/LobbyCreationPopup/Control/BasicSettings/NameEntry/LineEdit
onready var lobby_password = $MainPane/LobbyCreationPopup/Control/BasicSettings/PassEntry/LineEdit
onready var create_lobby_button = $MainPane/LobbyCreationPopup/Control/ColorRect/CreateLobbyButton
onready var lobby_container = $MainPane/LobbyScrollContainer/LobbyContainer

onready var lobby_pane = $MainPane/LobbyPane

# Onready variables for ENet popup
onready var enet_button = $MainPane/OnlineMenuBar/ENetButton
onready var rpc_popup = $MainPane/RPCPopup
onready var rpc_server_button = $MainPane/RPCPopup/SelectionContainer/RPCServerButton
onready var rpc_client_button = $MainPane/RPCPopup/SelectionContainer/RPCClientButton
onready var rpc_host_field = $MainPane/RPCPopup/InfoPane/EntryContainer/RPCHostField
onready var rpc_port_field = $MainPane/RPCPopup/InfoPane/EntryContainer/RPCPortField


const LOBBY_TYPE_ARRAY: Array = [
	"All Lobbies",
	"Public",
	"Private",
]

const LOBBY_STATE_ARRAY: Array = [
	"Open",
	"Full",
]

# Called when the node enters the scene tree for the first time.
func _ready():
	add_lobby_type_items()
	add_lobby_state_items()
	handle_connecting_signals()


func add_lobby_type_items() -> void:
	for lobby_type in LOBBY_TYPE_ARRAY:
		lobby_type_filter.add_item(lobby_type)


func add_lobby_state_items() -> void:
	for lobby_state in LOBBY_STATE_ARRAY:
		lobby_state_filter.add_item(lobby_state)


func handle_connecting_signals() -> void:
	lobby_button.connect("button_up", self, "on_lobby_button_pressed")
	enet_button.connect("button_up", self, "on_enet_button_pressed")
	create_lobby_button.connect("button_up", self, "on_create_lobby_button_pressed")
	lobby_type_filter.connect("item_selected", self, "filter_lobbies")
	lobby_state_filter.connect("item_selected", self, "filter_lobbies")
	lobby_search_bar.connect("text_changed", self, "filter_lobbies")
	rpc_server_button.connect("button_up", self, "on_rpc_server_button_pressed")
	rpc_client_button.connect("button_up", self, "on_rpc_client_button_pressed")
	


func _input(event) -> void:
	if InputMap.event_is_action(event, "menu_back", true):
		lobby_creation_popup.visible = false
		rpc_popup.visible = false


func filter_lobbies(filter) -> void:
	var type_filter = lobby_type_filter.get_item_text(lobby_type_filter.selected)
	var state_filter = lobby_state_filter.get_item_text(lobby_state_filter.selected)
	var search_text = lobby_search_bar.text
	
	var filter_dict = {
		"Type": type_filter,
		"State": state_filter,
		"Text": search_text,
	}
	
	for lobby in lobby_container.get_children():
		if check_lobby_visiblity(lobby, filter_dict):
			lobby.visible = true
		else:
			lobby.visible = false


func check_lobby_visiblity(lobby, filter_dict: Dictionary):
	var required_checks = 0
	var passed_checks = 0
	
	for key in filter_dict.keys():
		var curr_filter = filter_dict.get(key)
		
		if curr_filter and not curr_filter == "All Lobbies":
			required_checks += 1
			
			match key:
				"Type":
					if curr_filter == lobby.lobby_type:
						passed_checks += 1
				"State":
					if curr_filter == lobby.lobby_state:
						passed_checks += 1
				"Text":
					if curr_filter in lobby.lobby_name:
						passed_checks += 1
	
	if required_checks == passed_checks:
		return true
	else:
		 return false

func on_lobby_button_pressed():
	rpc_popup.visible = false
	lobby_creation_popup.visible = true


func on_create_lobby_button_pressed():
	lobby_creation_popup.visible = false
	
	var lobby_type = "Public"
	if lobby_password.text:
		lobby_type = "Private"
	
	var lobby_settings: Dictionary = {
		"lobby_name": lobby_name.text,
		"lobby_password": lobby_password.text,
		"lobby_type": lobby_type,
		"lobby_state": "Open",
		"lobby_host_name": Steam.getPersonaName(),
		"lobby_host_steamid": Steam.getSteamID()
	}
	
	var new_lobby = lobby_tile.instance()
	new_lobby.lobby_name = lobby_settings.lobby_name
	new_lobby.lobby_password = lobby_settings.lobby_password
	new_lobby.lobby_type = lobby_settings.lobby_state
	new_lobby.lobbby_state = lobby_settings.lobby_state
	new_lobby.lobby_host_name = lobby_settings.lobby_host_name
	new_lobby.lobby_host_steamid = lobby_settings.lobby_host_steamid

	lobby_container.add_child(new_lobby)
	
	# Clear popup entry lines
	lobby_name.set_text("")
	lobby_password.set_text("")


func update_lobby_pane(lobby_settings: Dictionary) -> void:
	lobby_pane.visible = true


##
#func on_steam_server_pressed() -> void:
#	NetworkGlobal.NETWORK_TYPE = 2
#	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
#	NetworkGlobal.STEAM_IS_HOST = true
#	get_tree().change_scene_to(steam_scene)
#
#
##
#func on_steam_client_pressed() -> void:
#	NetworkGlobal.NETWORK_TYPE = 2
#	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
#	NetworkGlobal.STEAM_IS_HOST = false
#	NetworkGlobal.STEAM_OPP_ID = int(steamid_field.text)
#	get_tree().change_scene_to(steam_scene)


func on_enet_button_pressed():
	lobby_creation_popup.visible = false
	rpc_popup.visible = true


# 
func on_rpc_server_button_pressed() -> void:
	rpc_popup.visible = false
	NetworkGlobal.NETWORK_TYPE = 1
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.RPC_IS_HOST = true
	NetworkGlobal.RPC_IP = rpc_host_field.text
	NetworkGlobal.RPC_PORT = int(rpc_port_field.text)
	get_tree().change_scene_to(rpc_scene)


#
func on_rpc_client_button_pressed() -> void:
	rpc_popup.visible = false
	NetworkGlobal.NETWORK_TYPE = 1
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.RPC_IS_HOST = false
	NetworkGlobal.RPC_IP = rpc_host_field.get_text()
	NetworkGlobal.RPC_PORT = int(rpc_port_field.get_text())
	get_tree().change_scene_to(rpc_scene)
