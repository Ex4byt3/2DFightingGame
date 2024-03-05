extends Control

@onready var map_holder = preload("res://scenes/maps/MapHolder.tscn")
@onready var lobby_tile = preload("res://scenes/ui/online/LobbyTile.tscn")

# Onready variables for lobby searches
@onready var refresh_button = $MainPane/OnlineMenuBar/RefreshButton
@onready var lobby_search_bar = $MainPane/OnlineMenuBar/SearchPane/LineEdit
@onready var lobby_type_filter = $MainPane/OnlineMenuBar/SearchPane/Filters/LobbyType
@onready var lobby_state_filter = $MainPane/OnlineMenuBar/SearchPane/Filters/LobbyState

# Onready variables for the lobby creation popup
@onready var open_lobby_popup = $MainPane/OnlineMenuBar/OpenLobbyPopup
@onready var lobby_creation_popup = $MainPane/LobbyCreationPopup
@onready var lobby_name = $MainPane/LobbyCreationPopup/Control/BasicSettings/NameEntry/LineEdit
@onready var lobby_password = $MainPane/LobbyCreationPopup/Control/BasicSettings/PassEntry/LineEdit
@onready var create_lobby_button = $MainPane/LobbyCreationPopup/Control/ColorRect/CreateLobbyButton
@onready var lobby_container = $MainPane/LobbyScrollContainer/LobbyContainer

# Onready variables for ENet popup
@onready var open_enet_popup = $MainPane/OnlineMenuBar/OpenENetPopup
@onready var rpc_popup = $MainPane/RPCPopup
@onready var rpc_server_button = $MainPane/RPCPopup/SelectionContainer/RPCServerButton
@onready var rpc_client_button = $MainPane/RPCPopup/SelectionContainer/RPCClientButton
@onready var rpc_host_field = $MainPane/RPCPopup/InfoPane/EntryContainer/RPCHostField
@onready var rpc_port_field = $MainPane/RPCPopup/InfoPane/EntryContainer/RPCPortField


var LOBBY_ID: int = 0
var LOBBY_NAME: String = "Default"
var LOBBY_MAX_MEMBERS: int = 10
var LOBBY_MEMBERS: Array = []
var CHALLENGES: Array = []
var ONGOING_MATCHES: Array = []

enum LOBBY_AVAILABILITY {PUBLIC, PRIVATE, FRIENDS, INVISIBLE}
enum LOBBY_TYPE {ALL_LOBBIES, PUBLIC, PRIVATE}
enum LOBBY_STATE {OPEN, FULL}


# Called when the node enters the scene tree for the first time.
func _ready():
	_add_lobby_types()
	_add_lobby_states()
	_handle_connecting_signals()
	_refresh_lobbies()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(Steam, self, "lobby_created", "_on_Lobby_Created")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_joined", "_on_Lobby_Joined")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_match_list", "_on_Lobby_Match_List")
	
	MenuSignalBus._connect_Signals(refresh_button, self, "button_up", "_refresh_lobbies")
	MenuSignalBus._connect_Signals(open_lobby_popup, self, "button_up", "_show_lobby_popup")
	MenuSignalBus._connect_Signals(open_enet_popup, self, "button_up", "_show_dc_popup")
	MenuSignalBus._connect_Signals(create_lobby_button, self, "button_up", "_create_steam_lobby")
	
	MenuSignalBus._connect_Signals(lobby_type_filter, self, "item_selected", "_filter_lobbies")
	MenuSignalBus._connect_Signals(lobby_state_filter, self, "item_selected", "_filter_lobbies")
	MenuSignalBus._connect_Signals(lobby_search_bar, self, "text_changed", "_filter_lobbies")
	
	MenuSignalBus._connect_Signals(rpc_server_button, self, "button_up", "_on_rpc_server_button_pressed")
	MenuSignalBus._connect_Signals(rpc_client_button, self, "button_up", "_on_rpc_client_button_pressed")


func _input(event) -> void:
	if event.is_action_released("ui_cancel"):
		lobby_creation_popup.visible = false
		rpc_popup.visible = false


##################################################
# LOBBY SEARCH FUNCTIONALITY
##################################################
func _add_lobby_types() -> void:
	for lobby_type in LOBBY_TYPE:
		lobby_type_filter.add_item(lobby_type)


func _add_lobby_states() -> void:
	for lobby_state in LOBBY_STATE:
		lobby_state_filter.add_item(lobby_state)


func _filter_lobbies(_filter) -> void:
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
# LOBBY FUNCTIONS
##################################################
func _on_Create_Steam_Lobby() -> void:
	if LOBBY_ID == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, LOBBY_MAX_MEMBERS)


func _on_Lobby_Created(connect: int, lobby_id: int) -> void:
	if connect == 1:
		print("[STEAM] Created lobby with ID: " + str(lobby_id))
		
		var set_joinable: bool = Steam.setLobbyJoinable(LOBBY_ID, true)
		print("[STEAM] lobby set to joinable:" + str(set_joinable))
		
		# If the lobby's name is not blank
		if lobby_name:
			LOBBY_NAME = lobby_name.text
		else:
			LOBBY_NAME = str(Steam.getLobbyOwner(lobby_id)) + "'s Lobby "
		
		var lobby_data: bool = false
		lobby_data = Steam.setLobbyData(lobby_id, "name", LOBBY_NAME)
		print("[STEAM] Setting lobby name data successful: "+str(lobby_data))
		lobby_data = Steam.setLobbyData(lobby_id, "mode", "Steam")
		print("[STEAM] Setting lobby mode data successful: "+str(lobby_data))
		
		get_parent().lobby_id = LOBBY_ID
	
	else:
		print("[STEAM] Failed to create lobby")


func _on_Lobby_Joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		LOBBY_ID = lobby_id
		print("[STEAM] Joined lobby with ID: " + str(LOBBY_ID))
		print("[STEAM] Joined " + str(Steam.getFriendPersonaName(Steam.getLobbyOwner(lobby_id))) + "'s lobby\n")
		MenuSignalBus.emit_change_screen(self, get_parent().menu_preloads.get("LobbyMenu"), false)
	
	else:
		## TODO: FIX IT
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


func _on_Lobby_Match_List(lobbies: Array) -> void:
	for lobby in lobbies:
		var new_lobby_tile = lobby_tile.instantiate()
		
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var lobby_mode = Steam.getLobbyData(lobby, "mode")
		var num_players: int = Steam.getNumLobbyMembers(lobby)
			
		if lobby_mode:
			new_lobby_tile.network_type = lobby_mode
		
		new_lobby_tile.num_lobby_members = num_players
		new_lobby_tile.lobby_host_name = Steam.getFriendPersonaName(lobby)
		
		lobby_container.add_child(new_lobby_tile)
		
		var join_lobby_signal: int = new_lobby_tile.join_button.connect("button_up", Callable(self, "_join_steam_lobby").bind(lobby))
		if join_lobby_signal > OK:
			print("[STEAM] Connecting tile to lobby: "+str(lobby)+" failed: "+str(join_lobby_signal))


##################################################
# LOBBY BUTTON FUNCTIONS
##################################################
func _show_lobby_popup() -> void:
	rpc_popup.visible = false
	lobby_creation_popup.visible = true


func _create_steam_lobby() -> void:
	lobby_creation_popup.visible = false
	if lobby_name.text:
		LOBBY_NAME = lobby_name.text
	else:
		LOBBY_NAME = Steam.getPersonaName() + "'s Lobby"
	
	_on_Create_Steam_Lobby()
	print("[STEAM] Attempting to create new lobby...\n")
	
	# Clear popup entry lines
	lobby_name.set_text("")
	lobby_password.set_text("")


func _join_steam_lobby(lobby_id: int) -> void:
	print("[STEAM] Attempting to join lobby " + str(lobby_id) + "...\n")
	LOBBY_MEMBERS.clear()
	Steam.joinLobby(lobby_id)


##################################################
# DIRECT CONNECT FUNCTIONS
##################################################
func _show_dc_popup() -> void:
	lobby_creation_popup.visible = false
	rpc_popup.visible = true


func _on_rpc_server_button_pressed() -> void:
	rpc_popup.visible = false
	NetworkGlobal.NETWORK_TYPE = 1
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.RPC_IS_HOST = true
	NetworkGlobal.RPC_IP = rpc_host_field.text
	NetworkGlobal.RPC_PORT = int(rpc_port_field.text)
	MenuSignalBus.emit_start_match()


func _on_rpc_client_button_pressed() -> void:
	rpc_popup.visible = false
	NetworkGlobal.NETWORK_TYPE = 1
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.RPC_IS_HOST = false
	NetworkGlobal.RPC_IP = rpc_host_field.get_text()
	NetworkGlobal.RPC_PORT = int(rpc_port_field.get_text())
	MenuSignalBus.emit_start_match()


##################################################
# HELPER FUNCTIONS
##################################################
func _set_buttons_disabled(is_disabled: bool) -> void:
	open_enet_popup.set_disabled(is_disabled)
	open_lobby_popup.set_disabled(is_disabled)


func _refresh_lobbies() -> void:
	for lobby_tile in lobby_container.get_children():
		lobby_tile.free()
	
	Steam.addRequestLobbyListDistanceFilter(3)
	Steam.requestLobbyList()
