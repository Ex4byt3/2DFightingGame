extends Control


@onready var lobby_tile = preload("res://scenes/gui/menu/online/LobbyTile.tscn")

@onready var lobby_creation_button = $PanelContainer/MarginContainer/VBoxContainer/MenuControls/LobbyCreationButton
@onready var direct_connect_button = $PanelContainer/MarginContainer/VBoxContainer/MenuControls/DirectConnectButton
@onready var refresh_button = $PanelContainer/MarginContainer/VBoxContainer/MenuControls/RefreshButton

@onready var searchbar = $PanelContainer/MarginContainer/VBoxContainer/MenuControls/LobbySearchControls/Searchbar
@onready var type_filter = $PanelContainer/MarginContainer/VBoxContainer/MenuControls/LobbySearchControls/DropdownFilters/TypeFilter
@onready var state_filter = $PanelContainer/MarginContainer/VBoxContainer/MenuControls/LobbySearchControls/DropdownFilters/StateFilter

@onready var lobbytile_container = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/LobbyTileContainer

@onready var lobby_creation_dialogue = $LobbyCreationDialogue
@onready var close_lobby_dialogue_button = $LobbyCreationDialogue/VBoxContainer/CloseLobbyDialogueButton
@onready var name_entry_line = $LobbyCreationDialogue/VBoxContainer/MarginContainer/VBoxContainer/NameEntryLine
@onready var password_entry_line = $LobbyCreationDialogue/VBoxContainer/MarginContainer/VBoxContainer/PasswordEntryLine
@onready var create_lobby_button = $LobbyCreationDialogue/VBoxContainer/CreateLobbyButton

@onready var direct_connect_dialogue = $DirectConnectDialogue
@onready var close_dc_dialogue_button = $DirectConnectDialogue/VBoxContainer/CloseDCDialogueButton
@onready var ip_entry_line = $DirectConnectDialogue/VBoxContainer/MarginContainer/VBoxContainer/IPEntryLine
@onready var port_entry_line = $DirectConnectDialogue/VBoxContainer/MarginContainer/VBoxContainer/PortEntryLine
@onready var direct_connect_server_button = $DirectConnectDialogue/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/DCServerButton
@onready var direct_connect_client_button = $DirectConnectDialogue/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/DCClientButton

var LOBBY_ID: int = 0
var LOBBY_NAME: String
var LOBBY_MAX_MEMBERS: int = 10
var LOBBY_MEMBERS: Array = []
var CHALLENGES: Array = []
var ONGOING_MATCHES: Array = []

enum LOBBY_AVAILABILITY {PUBLIC, PRIVATE, FRIENDS, INVISIBLE}
const LOBBY_TYPE: Array = ["All Lobbies", "Public", "Private"]
const LOBBY_STATE: Array = ["Open", "Full"]

# Variables for lobby match settings
var MATCH_SETTINGS: Dictionary = SettingsData.match_settings


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
	
	MenuSignalBus._connect_Signals(lobby_creation_button, self, "button_up", "_show_lobby_creation_dialogue")
	MenuSignalBus._connect_Signals(direct_connect_button, self, "button_up", "_show_direct_connect_dialogue")
	MenuSignalBus._connect_Signals(refresh_button, self, "button_up", "_refresh_lobbies")
	
	MenuSignalBus._connect_Signals(searchbar, self, "text_changed", "_filter_lobbies")
	MenuSignalBus._connect_Signals(type_filter, self, "item_selected", "_filter_lobbies")
	MenuSignalBus._connect_Signals(state_filter, self, "item_selected", "_filter_lobbies")
	
	MenuSignalBus._connect_Signals(close_lobby_dialogue_button, self, "button_up", "_close_lobby_dialogue")
	MenuSignalBus._connect_Signals(create_lobby_button, self, "button_up", "_create_steam_lobby")

	MenuSignalBus._connect_Signals(close_dc_dialogue_button, self, "button_up", "_close_dc_dialogue")
	MenuSignalBus._connect_Signals(direct_connect_server_button, self, "button_up", "_start_rpc_server")
	MenuSignalBus._connect_Signals(direct_connect_client_button, self, "button_up", "_start_rpc_client")


func _input(event) -> void:
	if event.is_action_released("ui_cancel"):
		lobby_creation_dialogue.visible = false
		direct_connect_dialogue.visible = false


##################################################
# LOBBY SEARCH FUNCTIONALITY
##################################################
func _add_lobby_types() -> void:
	for lobby_type in LOBBY_TYPE:
		type_filter.add_item(lobby_type)


func _add_lobby_states() -> void:
	for lobby_state in LOBBY_STATE:
		state_filter.add_item(lobby_state)


func _filter_lobbies(_filter) -> void:
	var this_type_filter = type_filter.get_item_text(type_filter.selected)
	var this_state_filter = state_filter.get_item_text(state_filter.selected)
	var search_text = searchbar.text
	
	var filter_dict = {
		"Type": type_filter.text,
		"State": state_filter.text,
		"Text": search_text,
	}
	
	for lobby in lobbytile_container.get_children():
		if check_lobby_visiblity(lobby, filter_dict):
			lobby.visible = true
		else:
			lobby.visible = false


func check_lobby_visiblity(lobby, filter_dict: Dictionary):
	var required_checks = 0
	var passed_checks = 0
	
	for key in filter_dict.keys():
		print("Current Key: " + key)
		var curr_filter = filter_dict.get(key)
		print("Current Filter: " + curr_filter)
		
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
					if curr_filter and lobby.lobby_name.findn(curr_filter) >= 0:
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
		LOBBY_ID = lobby_id
		print("[STEAM] Created lobby with ID: " + str(lobby_id))
		
		var set_joinable: bool = Steam.setLobbyJoinable(LOBBY_ID, true)
		print("[STEAM] lobby set to joinable:" + str(set_joinable))
		
		# If the lobby's name is not blank
		if name_entry_line.text:
			LOBBY_NAME = name_entry_line.text
		else:
			LOBBY_NAME = str(Steam.getFriendPersonaName(Steam.getLobbyOwner(lobby_id))) + "'s Lobby "
		
		var lobby_data: bool = false
		lobby_data = Steam.setLobbyData(lobby_id, "name", LOBBY_NAME)
		print("[STEAM] Setting lobby name data successful: "+str(lobby_data))
		lobby_data = Steam.setLobbyData(lobby_id, "mode", "Steam")
		print("[STEAM] Setting lobby mode data successful: "+str(lobby_data))
		lobby_data = Steam.setLobbyData(lobby_id, "lobby_type", "Temp")
		print("[STEAM] Setting lobby type data successful: "+str(lobby_data))
		lobby_data = Steam.setLobbyData(lobby_id, "lobby_state", "Open")
		print("[STEAM] Setting lobby state data successful: "+str(lobby_data))
		lobby_data = Steam.setLobbyData(lobby_id, "lobby_password", "")
		print("[STEAM] Setting lobby password data successful: "+str(lobby_data))
		
		_set_lobby_match_settings(lobby_id, MATCH_SETTINGS)
		#_set_lobby_character_settings(lobby_id, CHARACTER_SETTINGS)
	
	else:
		print("[STEAM] Failed to create lobby")


func _on_Lobby_Joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		LOBBY_ID = lobby_id
		get_parent().lobby_id = LOBBY_ID
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
		var owner_persona_name = Steam.getFriendPersonaName(Steam.getLobbyOwner(lobby))
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var lobby_mode = Steam.getLobbyData(lobby, "mode")
		var lobby_type = Steam.getLobbyData(lobby, "lobby_type")
		var lobby_state = Steam.getLobbyData(lobby, "lobby_state")
		var num_players: int = Steam.getNumLobbyMembers(lobby)
		
		var new_lobby_tile = lobby_tile.instantiate()
		
		if lobby_name:
			new_lobby_tile.lobby_name = lobby_name
		else:
			new_lobby_tile.lobby_name = owner_persona_name + "'s Lobby"
		
		if lobby_mode:
			new_lobby_tile.network_type = lobby_mode
		
		if lobby_type:
			new_lobby_tile.lobby_type = lobby_type
		
		if lobby_state:
			new_lobby_tile.lobby_state = lobby_state
		
		new_lobby_tile.num_lobby_members = num_players
		
		lobbytile_container.add_child(new_lobby_tile)
		
		var join_lobby_signal: int = new_lobby_tile.join_button.connect("button_up", Callable(self, "_join_steam_lobby").bind(lobby))
		if join_lobby_signal > OK:
			print("[STEAM] Connecting tile to lobby: "+str(lobby)+" failed: "+str(join_lobby_signal))


##################################################
# LOBBY BUTTON FUNCTIONS
##################################################
func _show_lobby_creation_dialogue() -> void:
	direct_connect_dialogue.visible = false
	lobby_creation_dialogue.visible = true


func _create_steam_lobby() -> void:
	lobby_creation_dialogue.visible = false
	
	_on_Create_Steam_Lobby()
	print("[STEAM] Attempting to create new lobby...\n")
	
	# Clear popup entry lines
	name_entry_line.set_text("")
	password_entry_line.set_text("")


func _join_steam_lobby(lobby_id: int) -> void:
	print("[STEAM] Attempting to join lobby " + str(lobby_id) + "...\n")
	LOBBY_MEMBERS.clear()
	Steam.joinLobby(lobby_id)


func _close_lobby_dialogue() -> void:
	lobby_creation_dialogue.visible = false


func _close_dc_dialogue() -> void:
	direct_connect_dialogue.visible = false


##################################################
# DIRECT CONNECT FUNCTIONS
##################################################
func _show_direct_connect_dialogue() -> void:
	lobby_creation_dialogue.visible = false
	direct_connect_dialogue.visible = true


func _start_rpc_server() -> void:
	direct_connect_dialogue.visible = false
	NetworkGlobal.NETWORK_TYPE = 1
	#GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.RPC_IS_HOST = true
	NetworkGlobal.RPC_IP = ip_entry_line.text
	NetworkGlobal.RPC_PORT = int(port_entry_line.text)
	MenuSignalBus.emit_create_match()


func _start_rpc_client() -> void:
	direct_connect_dialogue.visible = false
	NetworkGlobal.NETWORK_TYPE = 1
	#GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	NetworkGlobal.RPC_IS_HOST = false
	NetworkGlobal.RPC_IP = ip_entry_line.get_text()
	NetworkGlobal.RPC_PORT = int(port_entry_line.get_text())
	MenuSignalBus.emit_create_match()


##################################################
# HELPER FUNCTIONS
##################################################
func _set_buttons_disabled(is_disabled: bool) -> void:
	direct_connect_button.set_disabled(is_disabled)
	lobby_creation_button.set_disabled(is_disabled)


func _refresh_lobbies() -> void:
	for lobby_tile in lobbytile_container.get_children():
		lobby_tile.free()
	
	Steam.addRequestLobbyListDistanceFilter(3)
	Steam.requestLobbyList()


func _set_lobby_match_settings(lobby_id: int, match_settings: Dictionary) -> void:
	var lobby_data: bool
	for key in match_settings.keys():
		lobby_data = Steam.setLobbyData(lobby_id, key, str(match_settings.get(key)))
		print("[STEAM] Setting lobby " + key + " data successful: "+str(lobby_data))


func _set_lobby_character_settings(lobby_id: int, character_settings: Dictionary) -> void:
	var lobby_data: bool
	for key in character_settings.keys():
		lobby_data = Steam.setLobbyData(lobby_id, key, str(character_settings.get(key)))
		print("[STEAM] Setting lobby " + key + " data successful: "+str(lobby_data))

