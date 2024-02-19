extends Control

var rpc_scene = preload("res://scenes/maps/RpcGame.tscn")
var steam_scene = preload("res://scenes/maps/SteamGame.tscn")

onready var lobby_tile = preload("res://scenes/menu/LobbyTile.tscn")
onready var lobby_member = preload("res://scenes/menu/LobbyMember.tscn")

# Onready variables for lobby searches
onready var refresh_button = $MainPane/OnlineMenuBar/RefreshButton
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
	_add_Lobby_Type_Items()
	_add_Lobby_State_Items()
	_handle_Connecting_Signals()


func _handle_Connecting_Signals() -> void:
	MenuSignalBus._connect_Signals(Steam, self, "lobby_created", "_on_Lobby_Created")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_joined", "_on_Lobby_Joined")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_chat_update", "_on_Lobby_Chat_Update")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_message", "_on_Lobby_Message")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_match_list", "_on_Lobby_Match_List")
	
	MenuSignalBus._connect_Signals(refresh_button, self, "button_up", "_on_Refresh_Button_pressed")
	MenuSignalBus._connect_Signals(open_lobby_popup, self, "button_up", "_on_Open_Lobby_Popup_pressed")
	MenuSignalBus._connect_Signals(open_enet_popup, self, "button_up", "_on_Open_ENet_Popup_pressed")
	MenuSignalBus._connect_Signals(create_lobby_button, self, "button_up", "_on_Create_Lobby_pressed")
	
	MenuSignalBus._connect_Signals(lobby_type_filter, self, "item_selected", "_filter_Lobbies")
	MenuSignalBus._connect_Signals(lobby_state_filter, self, "item_selected", "_filter_Lobbies")
	MenuSignalBus._connect_Signals(lobby_search_bar, self, "text_changed", "_filter_Lobbies")
	
	MenuSignalBus._connect_Signals(rpc_server_button, self, "button_up", "_on_rpc_server_button_pressed")
	MenuSignalBus._connect_Signals(rpc_client_button, self, "button_up", "_on_rpc_client_button_pressed")
	
	MenuSignalBus._connect_Signals(lobby_pane.spectate_button, self, "button_up", "_on_Spectate_Match")
	MenuSignalBus._connect_Signals(lobby_pane.exit_lobby_button, self, "button_up", "_on_Exit_Lobby")
	MenuSignalBus._connect_Signals(lobby_pane.start_match_button, self, "button_up", "_on_Match_Start")
	MenuSignalBus._connect_Signals(lobby_pane.send_message_button, self, "button_up", "_on_Send_Message")


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


func _filter_Lobbies(_filter) -> void:
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
	lobby_pane.visible = true


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
		
		_set_buttons_disabled(false)


func _on_Lobby_Match_List(lobbies: Array) -> void:
	for lobby in lobbies:
		var new_lobby_tile = lobby_tile.instance()
		
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var lobby_mode = Steam.getLobbyData(lobby, "mode")
		var num_players: int = Steam.getNumLobbyMembers(lobby)
		
		if lobby_name:
			new_lobby_tile.lobby_name = lobby_name
		if lobby_mode:
			new_lobby_tile.network_type = lobby_mode
		
		new_lobby_tile.num_lobby_members = num_players
		new_lobby_tile.lobby_host_name = Steam.getFriendPersonaName(lobby)
		
		lobby_container.add_child(new_lobby_tile)
		
		var join_lobby_signal: int = new_lobby_tile.join_button.connect("button_up", self, "_join_Steam_Lobby", [lobby])
		if join_lobby_signal > OK:
			print("[STEAM] Connecting pressed to function _join_Steam_Lobby for "+str(lobby)+" successfully: "+str(join_lobby_signal))


func _on_Match_Start() -> void:
	var host_steam_id = Steam.getLobbyOwner(LOBBY_ID)
	NetworkGlobal.NETWORK_TYPE = 2
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	if Steam.getSteamID() == host_steam_id:
		NetworkGlobal.STEAM_IS_HOST = true
		print("[Steam] Started match as server")
	else:
		NetworkGlobal.STEAM_IS_HOST = false
		NetworkGlobal.STEAM_OPP_ID = int(host_steam_id)
		print("[Steam] Started match as client")
	MenuSignalBus._change_Scene(self, steam_scene)


##################################################
# Lobby button functions
##################################################
func _on_Open_Lobby_Popup_pressed() -> void:
	rpc_popup.visible = false
	lobby_creation_popup.visible = true


func _on_Create_Lobby_pressed() -> void:
	lobby_creation_popup.visible = false
	LOBBY_NAME = lobby_name.text
	
	_create_Steam_Lobby()
	lobby_pane.visible = true
	lobby_pane.chatbox.append_bbcode("[Steam] Attempting to create new lobby...\n")
	
	# Clear popup entry lines
	lobby_name.set_text("")
	lobby_password.set_text("")


func _on_Send_Message() -> void:
	lobby_pane.chatbox.append_bbcode(lobby_pane.chat_line.text)
	lobby_pane.chat_line.clear()


func _on_Exit_Lobby() -> void:
	_leave_Steam_Lobby()
	lobby_pane.visible = false
	lobby_pane.chatbox.clear()


func _on_Lobby_Joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		LOBBY_ID = lobby_id
		lobby_pane.chatbox.append_bbcode("[Steam] Joined lobby\n")
		_get_lobby_members()
		_set_buttons_disabled(true)
	else:
		var CONNECTION_ERROR: String
#		match response:
#			2:	CONNECTION_ERROR = "This lobby no longer exists."
#			3:	CONNECTION_ERROR = "You don't have permission to join this lobby."
#			4:	CONNECTION_ERROR = "The lobby is now full."
#			5:	CONNECTION_ERROR = "Uh... something unexpected happened!"
#			6:	CONNECTION_ERROR = "You are banned from this lobby."
#			7:	CONNECTION_ERROR = "You cannot join due to having a limited account."
#			8:	CONNECTION_ERROR = "This lobby is locked or disabled."
#			9:	CONNECTION_ERROR = "This lobby is community locked."
#			10:	CONNECTION_ERROR = "A user in the lobby has blocked you from joining."
#			11:	CONNECTION_ERROR = "A user you have blocked is in the lobby."


func _on_Spectate_Match() -> void:
	pass


##################################################
# ENet functions
##################################################
func _on_Open_ENet_Popup_pressed() -> void:
	lobby_creation_popup.visible = false
	rpc_popup.visible = true


# 
func _on_rpc_server_button_pressed() -> void:
	rpc_popup.visible = false
	NetworkGlobal.NETWORK_TYPE = 1
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.RPC_IS_HOST = true
	NetworkGlobal.RPC_IP = rpc_host_field.text
	NetworkGlobal.RPC_PORT = int(rpc_port_field.text)
	MenuSignalBus._change_Scene(self, rpc_scene)


#
func _on_rpc_client_button_pressed() -> void:
	rpc_popup.visible = false
	NetworkGlobal.NETWORK_TYPE = 1
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.RPC_IS_HOST = false
	NetworkGlobal.RPC_IP = rpc_host_field.get_text()
	NetworkGlobal.RPC_PORT = int(rpc_port_field.get_text())
	MenuSignalBus._change_Scene(self, rpc_scene)


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


func _on_Refresh_Button_pressed() -> void:
	for lobby_tile in lobby_container.get_children():
		lobby_tile.free()
	
	Steam.addRequestLobbyListDistanceFilter(3)
	Steam.requestLobbyList()
