extends Control

onready var lobby_tile = preload("res://scenes/menu/LobbyTile.tscn")

# Onready variables for lobby searches
onready var lobby_search_bar = $MainPane/OnlineMenuBar/SearchPane/LineEdit
onready var lobby_type_filter = $MainPane/OnlineMenuBar/SearchPane/Filters/LobbyType
onready var lobby_state_filter = $MainPane/OnlineMenuBar/SearchPane/Filters/LobbyState

# Onready variables for the lobby creation popup
onready var lobby_creation_popup = $MainPane/LobbyCreationPopup
onready var enet_entry = $MainPane/LobbyCreationPopup/Control/ENETEntry
onready var lobby_container = $MainPane/LobbyScrollContainer/LobbyContainer
onready var steam_button = $MainPane/LobbyCreationPopup/Control/LobbyType/SteamButton

# Onready variables for created lobby settings
onready var lobby_name = $MainPane/LobbyCreationPopup/Control/BasicSettings/NameEntry/LineEdit
onready var lobby_password = $MainPane/LobbyCreationPopup/Control/BasicSettings/PassEntry/LineEdit
onready var lobby_ip = $MainPane/LobbyCreationPopup/Control/ENETEntry/IPEntry/LineEdit
onready var lobby_port = $MainPane/LobbyCreationPopup/Control/ENETEntry/PortEntry/LineEdit


const LOBBY_TYPE_ARRAY = [
	"All Lobbies",
	"Public",
	"Private",
]

const LOBBY_STATE_ARRAY = [
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
	lobby_type_filter.connect("item_selected", self, "filter_lobbies")
	lobby_state_filter.connect("item_selected", self, "filter_lobbies")
	lobby_search_bar.connect("text_changed", self, "filter_lobbies")


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

func _on_CreateLobbyButton_button_up():
	lobby_creation_popup.visible = true


func _on_RPCButton_toggled(button_pressed):
	if button_pressed:
		enet_entry.visible = true
	else:
		enet_entry.visible = false


func _on_StartLobbyButton_button_up():
#	var network_type = 2 # Steam
#	if not steam_button.pressed:
#		network_type = 1 # RPC
	
	var lobby_settings = {
#		"Connection": network_type,
		"Name": lobby_name.text,
		"Password": lobby_password.text,
#		"IP": lobby_ip.text,
#		"Port": lobby_port.text,
	}
	
	SettingsSignalBus.emit_set_lobby_settings(lobby_settings)
	GameSignalBus.emit_create_lobby(lobby_settings)
	
	lobby_creation_popup.visible = false
	
	var new_lobby = lobby_tile.instance()
	
	if lobby_name.text:
		new_lobby.lobby_name = lobby_name.text
	if lobby_password.text:
		new_lobby.lobby_type = "Private"
#	new_lobby.network_type = network_type
	
	lobby_container.add_child(new_lobby)
	
	lobby_name.set_text("")
	lobby_password.set_text("")
