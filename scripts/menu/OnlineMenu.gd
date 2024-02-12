extends Control

var rpc_scene = preload("res://scenes/RpcGame.tscn")
var steam_scene = preload("res://scenes/SteamGame.tscn")

onready var lobby_tile = preload("res://scenes/menu/LobbyTile.tscn")
onready var lobby_member = preload("res://scenes/menu/LobbyMember.tscn")

# Onready variables for lobby searches
onready var lobby_search_bar = $MainPane/OnlineMenuBar/SearchPane/LineEdit
onready var lobby_type_filter = $MainPane/OnlineMenuBar/SearchPane/Filters/LobbyType
onready var lobby_state_filter = $MainPane/OnlineMenuBar/SearchPane/Filters/LobbyState

# Onready variables for the lobby creation popup
onready var open_lobby_popup = $MainPane/OnlineMenuBar/OpenLobbyPopup
onready var lobby_creation_popup = $MainPane/LobbyCreationPopup
onready var lobby_name = $MainPane/LobbyCreationPopup/Control/BasicSettings/NameEntry/LineEdit
onready var lobby_password = $MainPane/LobbyCreationPopup/Control/BasicSettings/PassEntry/LineEdit
onready var create_lobby_button = $MainPane/LobbyCreationPopup/Control/ColorRect/CreateLobbyButton
onready var lobby_container = $MainPane/LobbyScrollContainer/LobbyContainer

onready var lobby_pane = $MainPane/LobbyPane

# Onready variables for ENet popup
onready var open_enet_popup = $MainPane/OnlineMenuBar/OpenENetPopup
onready var rpc_popup = $MainPane/RPCPopup
onready var rpc_server_button = $MainPane/RPCPopup/SelectionContainer/RPCServerButton
onready var rpc_client_button = $MainPane/RPCPopup/SelectionContainer/RPCClientButton
onready var rpc_host_field = $MainPane/RPCPopup/InfoPane/EntryContainer/RPCHostField
onready var rpc_port_field = $MainPane/RPCPopup/InfoPane/EntryContainer/RPCPortField


var LOBBY_ID: int = 0
var LOBBY_NAME: String = "Default"
var LOBBY_MAX_MEMBERS: int = 2
var LOBBY_MEMBERS: Array = []
enum LOBBY_AVAILABILITY {PUBLIC, PRIVATE, FRIENDS, INVISIBLE}

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
	print("readying")
	_add_Lobby_Type_Items()
	_add_Lobby_State_Items()
	_handle_Connecting_Signals()
	_handle_Connectings_Steam_Signals()


# Connect a Steam signal and show the success code
func _connect_Steam_Signals(this_signal: String, this_function: String) -> void:
	var SIGNAL_CONNECT: int = Steam.connect(this_signal, self, this_function)
	if SIGNAL_CONNECT > OK:
		print("[STEAM] Connecting "+str(this_signal)+" to "+str(this_function)+" failed: "+str(SIGNAL_CONNECT))


# Connect the required steam signals used in the online menu
func _handle_Connectings_Steam_Signals() -> void:
	_connect_Steam_Signals("lobby_created", "_on_Lobby_Created")
	_connect_Steam_Signals("lobby_joined", "_on_Lobby_Joined")
	_connect_Steam_Signals("lobby_chat_update", "_on_Lobby_Chat_Update")
	_connect_Steam_Signals("lobby_message", "_on_Lobby_Message")


func _handle_Connecting_Signals() -> void:
	open_lobby_popup.connect("button_up", self, "on_Open_Lobby_Popup_pressed")
	open_enet_popup.connect("button_up", self, "on_Open_ENet_Popup_pressed")
	create_lobby_button.connect("button_up", self, "_on_Create_Lobby_pressed")
	lobby_type_filter.connect("item_selected", self, "filter_lobbies")
	lobby_state_filter.connect("item_selected", self, "filter_lobbies")
	lobby_search_bar.connect("text_changed", self, "filter_lobbies")
	rpc_server_button.connect("button_up", self, "on_rpc_server_button_pressed")
	rpc_client_button.connect("button_up", self, "on_rpc_client_button_pressed")
	lobby_pane.exit_lobby_button.connect("button_up", self, "_on_Exit_Lobby_pressed")


func _input(event) -> void:
	if InputMap.event_is_action(event, "menu_back", true):
		lobby_creation_popup.visible = false
		rpc_popup.visible = false


##################################################
# Lobby search functionality
##################################################
func _add_Lobby_Type_Items() -> void:
	for lobby_type in LOBBY_TYPE_ARRAY:
		lobby_type_filter.add_item(lobby_type)


func _add_Lobby_State_Items() -> void:
	for lobby_state in LOBBY_STATE_ARRAY:
		lobby_state_filter.add_item(lobby_state)


func _filter_Lobbies(filter) -> void:
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


##################################################
# Lobby functions
##################################################
func _create_Steam_Lobby() -> void:
	if LOBBY_ID == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, LOBBY_MAX_MEMBERS)


func _on_Lobby_Created(connect: int, lobby_id: int) -> void:
	if connect == 1:
		lobby_pane.chatbox.clear()
		lobby_pane.chatbox.append_bbcode("[Steam] Created lobby with ID: " + str(LOBBY_ID) + "\n")
		
		var set_joinable: bool = Steam.setLobbyJoinable(LOBBY_ID, true)
		print("[Steam] lobby set to joinable")
		
		var lobby_data: bool = false
		lobby_data = Steam.setLobbyData(lobby_id, "name", LOBBY_NAME)
		lobby_pane.lobby_name_label.set_text(LOBBY_NAME)
		print("[STEAM] Setting lobby name data successful: "+str(lobby_data))
		lobby_data = Steam.setLobbyData(lobby_id, "mode", "Steam Mode")
		print("[STEAM] Setting lobby mode data successful: "+str(lobby_data))


func _join_Steam_Lobby(lobby_id: int) -> void:
	lobby_pane.chatbox.append_bbcode("[Steam]:Attempting to join lobby " + str(lobby_id) + "...\n")
	LOBBY_MEMBERS.clear()
	Steam.joinLobby(lobby_id)


func _leave_Steam_Lobby() -> void:
	if LOBBY_ID != 0:
		lobby_pane.chatbox.append_bbcode("[Steam] Leaving lobby...\n")
		Steam.leaveLobby(LOBBY_ID)
		LOBBY_ID = 0
		
		for member in LOBBY_MEMBERS:
			print("[Steam] Left lobby session\n")
		
		LOBBY_MEMBERS.clear()
		
		for member in lobby_pane.members.get_children():
			member.hide()
			member.queue_free()
		
		_set_buttons_disabled(true)


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

##################################################
# Lobby button functions
##################################################
func on_Open_Lobby_Popup_pressed():
	rpc_popup.visible = false
	lobby_creation_popup.visible = true


func _on_Create_Lobby_pressed() -> void:
	lobby_creation_popup.visible = false
	LOBBY_NAME = lobby_name.text
	
	_create_Steam_Lobby()
	lobby_pane.visible = true
	lobby_pane.chatbox.append_bbcode("[Steam] Attempting to create new lobby...\n")
	_set_buttons_disabled(true)

	var lobby_type = "Public"
	if lobby_password.text:
		lobby_type = "Private"
	
	var lobby_settings: Dictionary = {
		"lobby_name": LOBBY_NAME,
		"lobby_password": lobby_password.text,
		"lobby_type": lobby_type,
		"lobby_state": "Open",
		"network_type": "Steam",
		"lobby_host_name": Steam.getPersonaName(),
		"lobby_host_steamid": Steam.getSteamID()
	}
	
	create_new_lobbytile(lobby_settings)


func _on_Exit_Lobby_pressed() -> void:
	
	_leave_Steam_Lobby()
	lobby_pane.visible = false
	lobby_pane.chatbox.clear()


func create_new_lobbytile(lobby_settings: Dictionary) -> void:
	var new_lobby = lobby_tile.instance()
	new_lobby.lobby_settings = lobby_settings
	lobby_container.add_child(new_lobby)
	
	# Clear popup entry lines
	lobby_name.set_text("")
	lobby_password.set_text("")


func _on_Lobby_Joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		LOBBY_ID = lobby_id
		lobby_pane.chatbox.append_bbcode("[Steam] Joined lobby\n")
		_get_lobby_members()
		_set_buttons_disabled(true)
	else:
		var CONNECTION_ERROR: String
		match response:
			2:	CONNECTION_ERROR = "This lobby no longer exists."
			3:	CONNECTION_ERROR = "You don't have permission to join this lobby."
			4:	CONNECTION_ERROR = "The lobby is now full."
			5:	CONNECTION_ERROR = "Uh... something unexpected happened!"
			6:	CONNECTION_ERROR = "You are banned from this lobby."
			7:	CONNECTION_ERROR = "You cannot join due to having a limited account."
			8:	CONNECTION_ERROR = "This lobby is locked or disabled."
			9:	CONNECTION_ERROR = "This lobby is community locked."
			10:	CONNECTION_ERROR = "A user in the lobby has blocked you from joining."
			11:	CONNECTION_ERROR = "A user you have blocked is in the lobby."



##################################################
# ENet functions
##################################################
func on_Open_ENet_Popup_pressed():
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


##################################################
# Helper functions
##################################################
func _set_buttons_disabled(is_disabled: bool) -> void:
	open_enet_popup.set_disabled(is_disabled)
	open_lobby_popup.set_disabled(is_disabled)


func _add_to_playerlist(steam_id: int, 	steam_name: String) -> void:
	lobby_pane.chatbox.append_bbcode("[Steam] " + steam_name + " has joined the lobby\n")
	LOBBY_MEMBERS.append({"steam_id":steam_id, "steam_name":steam_name})
	var new_member = lobby_member.instance()
	new_member.steam_id = steam_id
	new_member.steam_name = steam_name
	lobby_pane.members.add_child(new_member)


func _get_lobby_members() -> void:
	LOBBY_MEMBERS.clear()
	for member in lobby_pane.members.get_children():
		member.hide()
		member.queue_free()
	
	var members: int = Steam.getNumLobbyMembers(LOBBY_ID)
	
	for member in range(0, members):
		var steam_id: int = Steam.getLobbyMemberByIndex(LOBBY_ID, member)
		var steam_name: String = Steam.getFriendPersonaName(steam_id)
		_add_to_playerlist(steam_id, steam_name)
	
