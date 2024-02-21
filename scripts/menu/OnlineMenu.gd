extends Control

var rpc_scene = preload("res://scenes/maps/RpcGame.tscn")
var steam_scene = preload("res://scenes/maps/SteamGame.tscn")

onready var lobby_tile = preload("res://scenes/menu/online/LobbyTile.tscn")
onready var lobby_member = preload("res://scenes/menu/online/LobbyMember.tscn")
onready var challenge_tile = preload("res://scenes/menu/online/ChallengeTile.tscn")
onready var match_tile = preload("res://scenes/menu/online/MatchTile.tscn")

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

onready var lobby_overlay = $MainPane/LobbyOverlay

# Onready variables for ENet popup
onready var open_enet_popup = $MainPane/OnlineMenuBar/OpenENetPopup
onready var rpc_popup = $MainPane/RPCPopup
onready var rpc_server_button = $MainPane/RPCPopup/SelectionContainer/RPCServerButton
onready var rpc_client_button = $MainPane/RPCPopup/SelectionContainer/RPCClientButton
onready var rpc_host_field = $MainPane/RPCPopup/InfoPane/EntryContainer/RPCHostField
onready var rpc_port_field = $MainPane/RPCPopup/InfoPane/EntryContainer/RPCPortField


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
	MenuSignalBus._connect_Signals(Steam, self, "lobby_data_update", "_on_Lobby_Data_Update")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_chat_update", "_on_Lobby_Chat_Update")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_message", "_on_Lobby_Message")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_match_list", "_on_Lobby_Match_List")
	MenuSignalBus._connect_Signals(Steam, self, "persona_state_change", "_on_Persona_Changed")
	
	MenuSignalBus._connect_Signals(refresh_button, self, "button_up", "_refresh_lobbies")
	MenuSignalBus._connect_Signals(open_lobby_popup, self, "button_up", "_show_lobby_popup")
	MenuSignalBus._connect_Signals(open_enet_popup, self, "button_up", "_show_dc_popup")
	MenuSignalBus._connect_Signals(create_lobby_button, self, "button_up", "_create_steam_lobby")
	
	MenuSignalBus._connect_Signals(lobby_type_filter, self, "item_selected", "_filter_lobbies")
	MenuSignalBus._connect_Signals(lobby_state_filter, self, "item_selected", "_filter_lobbies")
	MenuSignalBus._connect_Signals(lobby_search_bar, self, "text_changed", "_filter_lobbies")
	
	MenuSignalBus._connect_Signals(rpc_server_button, self, "button_up", "_on_rpc_server_button_pressed")
	MenuSignalBus._connect_Signals(rpc_client_button, self, "button_up", "_on_rpc_client_button_pressed")
	
#	MenuSignalBus._connect_Signals(lobby_overlay.spectate_button, self, "button_up", "_spectate_match")
	MenuSignalBus._connect_Signals(lobby_overlay.exit_lobby_button, self, "button_up", "_on_exit_lobby")
#	MenuSignalBus._connect_Signals(lobby_overlay.start_match_button, self, "button_up", "_on_Match_Start")
	MenuSignalBus._connect_Signals(lobby_overlay.send_message_button, self, "button_up", "_on_send_message")


func _input(event) -> void:
	if InputMap.event_is_action(event, "menu_back", true):
		lobby_creation_popup.visible = false
		rpc_popup.visible = false
	if InputMap.event_is_action(event, "chat_enter", true):
		if lobby_overlay.chat_line.has_focus():
			_on_send_message()


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
		print("[Steam] Created lobby with ID: " + str(lobby_id))
		lobby_overlay.chatbox.clear()
		
		var set_joinable: bool = Steam.setLobbyJoinable(LOBBY_ID, true)
		print("[Steam] lobby set to joinable:" + str(set_joinable))
		
		var lobby_data: bool = false
		lobby_data = Steam.setLobbyData(lobby_id, "name", LOBBY_NAME)
		print("[STEAM] Setting lobby name data successful: "+str(lobby_data))
		lobby_data = Steam.setLobbyData(lobby_id, "mode", "Steam")
		print("[STEAM] Setting lobby mode data successful: "+str(lobby_data))
		
		lobby_overlay.lobby_name_label.set_text(LOBBY_NAME)
	
	else:
		print("[STEAM] Failed to create lobby")


func _on_Lobby_Joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		LOBBY_ID = lobby_id
		print("[Steam] Joined lobby with ID: " + str(LOBBY_ID))
		lobby_overlay.chatbox.append_bbcode("[Steam] Joined " + str(Steam.getFriendPersonaName(Steam.getLobbyOwner(lobby_id))) + "'s lobby\n")
		
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


# Update when lobby metadata has changed
func _on_Lobby_Data_Update(lobby_id: int, member_id: int, key: int) -> void:
	print("[STEAM] Lobby Data Update Success [ Lobby ID: "+str(lobby_id)+", Member ID: "+str(member_id)+", Key: "+str(key)+" ]\n")


func _leave_Steam_Lobby() -> void:
	if LOBBY_ID != 0:
		lobby_overlay.chatbox.append_bbcode("[Steam] Leaving lobby...\n")
		Steam.leaveLobby(LOBBY_ID)
		LOBBY_ID = 0

		print("[Steam] Left lobby session\n")
		
		LOBBY_MEMBERS.clear()
		
		for member in lobby_overlay.members.get_children():
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
		
		var join_lobby_signal: int = new_lobby_tile.join_button.connect("button_up", self, "_join_steam_lobby", [lobby])
		if join_lobby_signal > OK:
			print("[STEAM] Connecting tile to lobby: "+str(lobby)+" failed: "+str(join_lobby_signal))


func _create_challenge(sender_id: int, recipient_id: int) -> void:
	CHALLENGES.append({"sender_id":sender_id , "recipient_id":recipient_id})
	_update_challenges()
	


func _update_challenges() -> void:
	for challenge in lobby_overlay.challenges.get_children():
		challenge.hide()
		challenge.queue_free()
	
	for challenge in CHALLENGES:
		var new_challenge_tile = challenge_tile.instance()
		new_challenge_tile.challenger_id = challenge.sender_id
		new_challenge_tile.recipient_id = challenge.recipient_id
		
		if Steam.getSteamID() == challenge.sender_id:
			new_challenge_tile.is_challenger = true
			
		lobby_overlay.challenges.add_child(new_challenge_tile)
		
		var command_accept: String = "/accept_challenge " + str(challenge.sender_id) + " " + str(challenge.recipient_id)
		var command_reject: String = "/reject_challenge " + str(challenge.sender_id) + " " + str(challenge.recipient_id)
	
		var challenge_accepted_signal: int = new_challenge_tile.accept_button.connect("button_up", self, "_send_command", [command_accept])
		if challenge_accepted_signal > OK:
			print("[STEAM] Connecting to accept button failed: "+str(challenge_accepted_signal))
			
		var challenge_rejected_signal: int = new_challenge_tile.reject_button.connect("button_up", self, "_send_command", [command_reject])
		if challenge_rejected_signal > OK:
			print("[STEAM] Connecting to accept button failed: "+str(challenge_rejected_signal))

func _host_start() -> void:
	NetworkGlobal.NETWORK_TYPE = 2
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	
	NetworkGlobal.STEAM_IS_HOST = true
	print("[Steam] Started match as server")
	
	MenuSignalBus._change_Scene(self, steam_scene)

func _client_start(sender_id: int) -> void:
	var host_steam_id: int = sender_id
	NetworkGlobal.NETWORK_TYPE = 2
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	
	NetworkGlobal.STEAM_IS_HOST = false
	NetworkGlobal.STEAM_OPP_ID = int(host_steam_id)
	print("[Steam] Started match as client")
	
	MenuSignalBus._change_Scene(self, steam_scene)


##################################################
# LOBBY BUTTON FUNCTIONS
##################################################
func _show_lobby_popup() -> void:
	rpc_popup.visible = false
	lobby_creation_popup.visible = true


func _create_steam_lobby() -> void:
	lobby_creation_popup.visible = false
	LOBBY_NAME = lobby_name.text
	
	_on_Create_Steam_Lobby()
	lobby_overlay.visible = true
	lobby_overlay.chatbox.append_bbcode("[Steam] Attempting to create new lobby...\n")
	
	# Clear popup entry lines
	lobby_name.set_text("")
	lobby_password.set_text("")


func _join_steam_lobby(lobby_id: int) -> void:
	lobby_overlay.chatbox.append_bbcode("[Steam] Attempting to join lobby " + str(lobby_id) + "...\n")
	LOBBY_MEMBERS.clear()
	Steam.joinLobby(lobby_id)
	lobby_overlay.visible = true


func _on_exit_lobby() -> void:
	_leave_Steam_Lobby()
	lobby_overlay.visible = false
	lobby_overlay.chatbox.clear()


func _spectate_match() -> void:
	#SyncManager.spectating = true
	#_on_Match_Start()
	pass


##################################################
# LOBBY CHAT FUNCTIONS
##################################################
# When a lobby chat is updated
func _on_Lobby_Chat_Update(lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void:
	# Note that chat state changes is: 1 - entered, 2 - left, 4 - user disconnected before leaving, 8 - user was kicked, 16 - user was banned
	print("[STEAM] Lobby ID: "+str(lobby_id)+", Changed ID: "+str(changed_id)+", Making Change: "+str(making_change_id)+", Chat State: "+str(chat_state))
	# Get the user who has made the lobby change
	var new_member = Steam.getFriendPersonaName(changed_id)
	# If a player has joined the lobby
	if chat_state == 1:
		lobby_overlay.chatbox.append_bbcode("[STEAM] "+str(new_member)+" has joined the lobby.\n")
	# Else if a player has left the lobby
	elif chat_state == 2:
		lobby_overlay.chatbox.append_bbcode("[STEAM] "+str(new_member)+" has left the lobby.\n")
	# Else if a player has been kicked
	elif chat_state == 8:
		lobby_overlay.chatbox.append_bbcode("[STEAM] "+str(new_member)+" has been kicked from the lobby.\n")
	# Else if a player has been banned
	elif chat_state == 16:
		lobby_overlay.chatbox.append_bbcode("[STEAM] "+str(new_member)+" has been banned from the lobby.\n")
	# Else there was some unknown change
	else:
		lobby_overlay.chatbox.append_bbcode("[STEAM] "+str(new_member)+" did... something.\n")
	# Update the lobby now that a change has occurred
	_get_lobby_members()


func _on_Lobby_Message(_result: int, user: int, message: String, type: int) -> void:
	var message_source = Steam.getFriendPersonaName(user)
	
	# If this is a message or lobby host command
	if type == 1:
		# If the message was a lobby host command
		if user == Steam.getLobbyOwner(LOBBY_ID) and message.begins_with("/"):
			var parsed_string: PoolStringArray = message.split(" ", true)
			print("Lobby owner entered a command: " + parsed_string[0])
			_recieve_command(message)
		
		# Elif the message was a lobby member command
		elif message.begins_with("/"):
			var parsed_string: PoolStringArray = message.split(" ", true)
			print("Lobby member entered a command: " + parsed_string[0])
			_recieve_command(message)
		
		# Else this is a normal chat message
		else:
			# Append the message to chat
			lobby_overlay.chatbox.append_bbcode("<" + str(message_source) + "> " + str(message) + "\n")
		
	# This message is not a normal message or a lobby host command
	else:
		match type:
			2: lobby_overlay.chatbox.append_bbcode(str(message_source)+" is typing...\n")
			3: lobby_overlay.chatbox.append_bbcode(str(message_source)+" sent an invite that won't work in this chat!\n")
			4: lobby_overlay.chatbox.append_bbcode(str(message_source)+" sent a text emote that is deprecated.\n")
			6: lobby_overlay.chatbox.append_bbcode(str(message_source)+" has left the chat.\n")
			7: lobby_overlay.chatbox.append_bbcode(str(message_source)+" has entered the chat.\n")
			8: lobby_overlay.chatbox.append_bbcode(str(message_source)+" was kicked!\n")
			9: lobby_overlay.chatbox.append_bbcode(str(message_source)+" was banned!\n")
			10: lobby_overlay.chatbox.append_bbcode(str(message_source)+" disconnected.\n")
			11: lobby_overlay.chatbox.append_bbcode(str(message_source)+" sent an old, offline message.\n")
			12: lobby_overlay.chatbox.append_bbcode(str(message_source)+" sent a link that was removed by the chat filter.\n")


# Send a chat message
func _on_send_message() -> void:
	var message = lobby_overlay.chat_line.get_text()
	
	# Check if there is a message
	if message.length() > 0:
		
		# Pass the message to Steam
		var is_sent: bool = Steam.sendLobbyChatMsg(LOBBY_ID, message)
		if not is_sent:
			lobby_overlay.chatbox.append_bbcode("[ERROR] Chat message failed to send.\n")
		lobby_overlay.chat_line.clear()


##################################################
# DIRECT CONNECT FUNCTIONS
##################################################
func _show_dc_popup() -> void:
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
# HELPER FUNCTIONS
##################################################
func _set_buttons_disabled(is_disabled: bool) -> void:
	open_enet_popup.set_disabled(is_disabled)
	open_lobby_popup.set_disabled(is_disabled)


func _add_to_playerlist(steam_id: int, steam_name: String) -> void:
	print("Adding new player: " + steam_name)
	LOBBY_MEMBERS.append({"steam_id":steam_id, "steam_name":steam_name})
	
	var user_steam_id = Steam.getSteamID()
	var new_member = lobby_member.instance()
	new_member.member_steam_id = steam_id
	new_member.member_steam_name = steam_name
	lobby_overlay.members.add_child(new_member)
	
	if user_steam_id == steam_id:
		new_member.challenge_button.visible = false
	
	var command_challenge: String = "/create_challenge " + str(user_steam_id) + " " + str(steam_id)
	
	var issue_challenge_signal: int = new_member.challenge_button.connect("button_up", self, "_send_command", [command_challenge])
	if issue_challenge_signal > OK:
		print("[STEAM] Connecting member's challenge button failed: " + str(issue_challenge_signal))


func _get_lobby_members() -> void:
	LOBBY_MEMBERS.clear()
	for member in lobby_overlay.members.get_children():
		member.hide()
		member.queue_free()
	
	var num_members: int = Steam.getNumLobbyMembers(LOBBY_ID)
	
	for member in range(0, num_members):
		var steam_id: int = Steam.getLobbyMemberByIndex(LOBBY_ID, member)
		var steam_name: String = Steam.getFriendPersonaName(steam_id)
		_add_to_playerlist(steam_id, steam_name)


func _refresh_lobbies() -> void:
	for lobby_tile in lobby_container.get_children():
		lobby_tile.free()
	
	Steam.addRequestLobbyListDistanceFilter(3)
	Steam.requestLobbyList()


func _on_Persona_Changed(steam_id: int, change_flag: int) -> void:
	print("[STEAM] Lobby member " + Steam.getFriendPersonaName(steam_id) + "'s information changed: " + str(change_flag))
	_get_lobby_members()


func _send_command(command: String) -> void:
	var is_sent: bool = Steam.sendLobbyChatMsg(LOBBY_ID, command)
	if not is_sent:
			lobby_overlay.chatbox.append_bbcode("[ERROR] Chat message failed to send.\n")

func _recieve_command(command: String) -> void:
	if command.begins_with("/create_challenge"):
		var participants: PoolStringArray = command.split(" ", true)
		
		# TODO: Add a way to allow the use of steam personas rather than ids
		var sender_id: int = int(participants[1])
		var recipient_id: int = int(participants[2])
		
		var is_valid: bool = true
		for challenge in CHALLENGES:
			if challenge.sender_id == sender_id and challenge.recipient_id == recipient_id:
				is_valid = false
		
		if is_valid:
			_create_challenge(sender_id, recipient_id)
		
	elif command.begins_with("/accept_challenge"):
		var participants: PoolStringArray = command.split(" ", true)
		var sender_id: int  = int(participants[1])
		var recipient_id: int = int(participants[2])
		if Steam.getSteamID() == sender_id:
			_host_start()
		elif Steam.getSteamID() == recipient_id:
			_client_start(sender_id)
		
	elif command.begins_with("/reject_challenge"):
		pass
		
	elif command.begins_with("/kick"):
		# Get the user ID for kicking
#		var COMMANDS: PoolStringArray = message.split(":", true)
		# If this is your ID, leave the lobby
#		if Global.STEAM_ID == int(COMMANDS[1]):
#			_leave_Lobby()
		pass
	
	elif command.begins_with("/roll"):
		var dice: PoolStringArray = command.split(" ", true)
		var die_sides = int(dice[1])
		var result = randi() % die_sides + 1
		lobby_overlay.chatbox.append_bbcode("[SYSTEM] " + Steam.getPersonaName() + " rolled a d" + str(die_sides) + "\n")
		lobby_overlay.chatbox.append_bbcode("[SYSTEM] " + Steam.getPersonaName() + " rolled " + str(result) + "\n")
