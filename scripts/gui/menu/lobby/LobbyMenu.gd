extends Control


@onready var lobby_member = preload("res://scenes/gui/menu/lobby/LobbyMember.tscn")
@onready var challenge_tile = preload("res://scenes/gui/menu/lobby/ChallengeTile.tscn")
@onready var match_tile = preload("res://scenes/gui/menu/lobby/MatchTile.tscn")

@onready var lobby_name_label = $MainPane/HBoxContainer/LeftPane/VBoxContainer/TitleBox/LobbyNameLabel
@onready var mode_label = $MainPane/HBoxContainer/LeftPane/VBoxContainer/TitleBox/LobbyInfo/LobbyMode/Label
@onready var type_label = $MainPane/HBoxContainer/LeftPane/VBoxContainer/TitleBox/LobbyInfo/LobbyType/Label
@onready var state_label = $MainPane/HBoxContainer/LeftPane/VBoxContainer/TitleBox/LobbyInfo/LobbyState/Label
@onready var password_line_edit = $MainPane/HBoxContainer/LeftPane/VBoxContainer/TitleBox/ActionBox/PasswordEdit
@onready var exit_button = $MainPane/HBoxContainer/LeftPane/VBoxContainer/TitleBox/ActionBox/ExitButton
@onready var members = $MainPane/HBoxContainer/LeftPane/VBoxContainer/ScrollContainer/Members

@onready var lobby_tabs = $MainPane/HBoxContainer/RightPane/LobbyTabs
@onready var match_settings_tab = find_child("Match Settings", true)

@onready var chat_display = $MainPane/HBoxContainer/RightPane/LobbyTabs/Chat/VBoxContainer/ChatDisplay
@onready var chat_entry_line = $MainPane/HBoxContainer/RightPane/LobbyTabs/Chat/VBoxContainer/HBoxContainer/ChatEntryLine
@onready var send_button = $MainPane/HBoxContainer/RightPane/LobbyTabs/Chat/VBoxContainer/HBoxContainer/SendButton
@onready var challenges = $MainPane/HBoxContainer/RightPane/LobbyTabs/Challenges/ScrollContainer/Challenges
@onready var matches = $MainPane/HBoxContainer/RightPane/LobbyTabs/Matches/ScrollContainer/Matches
@onready var previous_matches = $MainPane/HBoxContainer/RightPane/LobbyTabs/History/ScrollContainer/PreviousMatches
@onready var match_settings = $MainPane/HBoxContainer/RightPane/LobbyTabs/"Match Settings"/ScrollContainer/MatchSettings


@onready var sd_option_button = find_child("SDOptionButton", true)
@onready var time_spinbox = find_child("TimeSpinBox", true)
@onready var lives_spinbox = find_child("LivesSpinBox", true)
@onready var initial_burst_spinbox = find_child("InitBurstSpinBox", true)
@onready var burst_mult_spinbox = find_child("BurstMultSpinbox", true)
@onready var initial_meter_spinbox = find_child("InitMeterSpinBox", true)
@onready var meter_mult_spinbox = find_child("MeterMultSpinBox", true)
@onready var damage_mult_spinbox = find_child("DamageMultSpinBox", true)
@onready var knock_stun_mult_spinbox = find_child("KnockStunMultSpinBox", true)

var LOBBY_ID: int = 0
var LOBBY_NAME: String = "Default"
var LOBBY_MEMBERS: Array = []
var CHALLENGES: Array = []
var ONGOING_MATCHES: Array = []
var using_owner_settings: bool  = true

# Variables for lobby match settings
var MATCH_SETTINGS: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	_init_lobby()


##################################################
# ONREADY FUNCTIONS
##################################################
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(Steam, self, "lobby_data_update", "_on_Lobby_Data_Update")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_chat_update", "_on_Lobby_Chat_Update")
	MenuSignalBus._connect_Signals(Steam, self, "lobby_message", "_on_Lobby_Message")
	MenuSignalBus._connect_Signals(Steam, self, "persona_state_change", "_on_Persona_Changed")
	
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "exit_lobby", "_exit_lobby")
	MenuSignalBus._connect_Signals(exit_button, self, "button_up", "_exit_lobby")
	MenuSignalBus._connect_Signals(send_button, self, "button_up", "_send_message")


func _init_lobby() -> void:
	_get_lobby_members()
	LOBBY_ID = get_parent().lobby_id
	lobby_name_label.set_text(Steam.getLobbyData(LOBBY_ID, "name"))
	mode_label.set_text(Steam.getLobbyData(LOBBY_ID, "mode"))
	type_label.set_text(Steam.getLobbyData(LOBBY_ID, "lobby_type"))
	state_label.set_text(Steam.getLobbyData(LOBBY_ID, "lobby_state"))
	MenuSignalBus.emit_set_match_settings_source(using_owner_settings)
	#_update_lobby_match_settings()
	#_set_lobby_match_settings()


##################################################
# INPUT FUNCTIONS
##################################################
func _input(event) -> void:
	if event.is_action_released("chat_enter"):
		if chat_entry_line.has_focus():
			_send_message()


# When the lobby's exit button is pressed
func _exit_lobby() -> void:
	_leave_Steam_Lobby()
	MenuSignalBus.emit_goto_previous_menu("OnlineMenu")


func _spectate_match(host_id: int) -> void:
	pass


##################################################
# LOBBY FUNCTIONS
##################################################
# Update when lobby metadata has changed
func _on_Lobby_Data_Update(lobby_id: int, member_id: int, key: int) -> void:
	print("[STEAM] Lobby Data Update Success [ Lobby ID: "+str(lobby_id)+", Member ID: "+str(member_id)+", Key: "+str(key)+" ]\n")

func _leave_Steam_Lobby() -> void:
	if LOBBY_ID != 0:
		chat_display.append_text("[STEAM] Leaving lobby...\n")
		Steam.leaveLobby(LOBBY_ID)
		LOBBY_ID = 0

		print("[STEAM] Left lobby session\n")
		
		LOBBY_MEMBERS.clear()
		
		for member in members.get_children():
			member.hide()
			member.queue_free()


func _create_challenge(sender_id: int, recipient_id: int) -> void:
	CHALLENGES.append({"sender_id":sender_id , "recipient_id":recipient_id})
	_update_challenges()


func _update_challenges() -> void:
	for challenge in challenges.get_children():
		challenge.hide()
		challenge.queue_free()
	
	for challenge in CHALLENGES:
		var new_challenge_tile = challenge_tile.instantiate()
		new_challenge_tile.challenger_id = challenge.sender_id
		new_challenge_tile.recipient_id = challenge.recipient_id
		
		if Steam.getSteamID() == challenge.sender_id:
			new_challenge_tile.is_challenger = true
		elif Steam.getSteamID() == challenge.recipient_id:
			new_challenge_tile.is_challenger = false
		else:
			new_challenge_tile.visible = false
			
		challenges.add_child(new_challenge_tile)
		
		var command_accept: String = "/accept_challenge " + str(challenge.sender_id) + " " + str(challenge.recipient_id)
		var command_reject: String = "/reject_challenge " + str(challenge.sender_id) + " " + str(challenge.recipient_id)
	
		var challenge_accepted_signal: int = new_challenge_tile.accept_button.connect("button_up", Callable(self, "_send_command").bind(command_accept))
		if challenge_accepted_signal > OK:
			print("[STEAM] Connecting to accept button failed: "+str(challenge_accepted_signal))
			
		var challenge_rejected_signal: int = new_challenge_tile.reject_button.connect("button_up", Callable(self, "_send_command").bind(command_reject))
		if challenge_rejected_signal > OK:
			print("[STEAM] Connecting to accept button failed: "+str(challenge_rejected_signal))


func _create_ongoing_match(p1_id: int, p2_id: int) -> void:
	ONGOING_MATCHES.append({"p1_id": p1_id, "p2_id": p2_id})
	_update_ongoing_matches()


func _update_ongoing_matches() -> void:
	for this_match in matches.get_children():
		this_match.hide()
		this_match.queue_free()
	
	for this_match in ONGOING_MATCHES:
		var new_match_tile = match_tile.instantiate()
		new_match_tile.challenger_id = this_match.sender_id
		new_match_tile.recipient_id = this_match.recipient_id
		matches.add_child(new_match_tile)
		
		var command_spectate: String = "/spectate " + this_match.p1_id + " " + this_match.p2_id
		var spectate_signal: int = new_match_tile.spectate_button.connect("button_up", _send_command.bind(command_spectate))
		if spectate_signal > OK:
				print("[STEAM] Connecting to accept button failed: "+str(spectate_signal))


func _host_start(recipient_id: int) -> void:
	var client_steam_id: int = recipient_id
	NetworkGlobal.NETWORK_TYPE = 2
	
	NetworkGlobal.STEAM_IS_HOST = true
	NetworkGlobal.STEAM_OPP_ID = int(client_steam_id)
	print("[STEAM] Started match as server")
	
	#_set_lobby_match_settings()
	
	MenuSignalBus.emit_create_match()


func _client_start(sender_id: int) -> void:
	var host_steam_id: int = sender_id
	NetworkGlobal.NETWORK_TYPE = 2
	
	NetworkGlobal.STEAM_IS_HOST = false
	NetworkGlobal.STEAM_OPP_ID = int(host_steam_id)
	print("[STEAM] Started match as client")
	
	#_set_lobby_match_settings()
	
	MenuSignalBus.emit_create_match()


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
		chat_display.append_text("[STEAM] "+str(new_member)+" has joined the lobby.\n")
	# Else if a player has left the lobby
	elif chat_state == 2:
		chat_display.append_text("[STEAM] "+str(new_member)+" has left the lobby.\n")
	# Else if a player has been kicked
	elif chat_state == 8:
		chat_display.append_text("[STEAM] "+str(new_member)+" has been kicked from the lobby.\n")
	# Else if a player has been banned
	elif chat_state == 16:
		chat_display.append_text("[STEAM] "+str(new_member)+" has been banned from the lobby.\n")
	# Else there was some unknown change
	else:
		chat_display.append_text("[STEAM] "+str(new_member)+" did... something.\n")
	# Update the lobby now that a change has occurred
	_get_lobby_members()


func _on_Lobby_Message(_result: int, user: int, message: String, type: int) -> void:
	var message_source = Steam.getFriendPersonaName(user)
	
	# If this is a message or lobby host command
	if type == 1:
		# If the message was a lobby host command
		if user == Steam.getLobbyOwner(LOBBY_ID) and message.begins_with("/"):
			var parsed_string: PackedStringArray = message.split(" ", true)
			print("[STEAM] Lobby owner entered a command: " + parsed_string[0])
			_recieve_command(message)
		
		# Elif the message was a lobby member command
		elif message.begins_with("/"):
			var parsed_string: PackedStringArray = message.split(" ", true)
			print("[Steam] Lobby member entered a command: " + parsed_string[0])
			_recieve_command(message)
		
		# Else this is a normal chat message
		else:
			# Append the message to chat
			chat_display.append_text("<" + str(message_source) + "> " + str(message) + "\n")
		
	# This message is not a normal message or a lobby host command
	else:
		match type:
			2: chat_display.append_text(str(message_source)+" is typing...\n")
			3: chat_display.append_text(str(message_source)+" sent an invite that won't work in this chat!\n")
			4: chat_display.append_text(str(message_source)+" sent a text emote that is deprecated.\n")
			6: chat_display.append_text(str(message_source)+" has left the chat.\n")
			7: chat_display.append_text(str(message_source)+" has entered the chat.\n")
			8: chat_display.append_text(str(message_source)+" was kicked!\n")
			9: chat_display.append_text(str(message_source)+" was banned!\n")
			10: chat_display.append_text(str(message_source)+" disconnected.\n")
			11: chat_display.append_text(str(message_source)+" sent an old, offline message.\n")
			12: chat_display.append_text(str(message_source)+" sent a link that was removed by the chat filter.\n")


# Send a chat message
func _send_message() -> void:
	var message = chat_entry_line.get_text()
	
	# Check if there is a message
	if message.length() > 0:
		
		# Pass the message to Steam
		var is_sent: bool = Steam.sendLobbyChatMsg(LOBBY_ID, message)
		if not is_sent:
			chat_display.append_text("[ERROR] Chat message failed to send.\n")
		chat_entry_line.clear()


##################################################
# HELPER FUNCTIONS
##################################################
func _add_to_playerlist(steam_id: int, steam_name: String) -> void:
	print("[STEAM] Adding new player: " + steam_name)
	LOBBY_MEMBERS.append({"steam_id":steam_id, "steam_name":steam_name})
	
	var user_steam_id = Steam.getSteamID()
	var new_member = lobby_member.instantiate()
	new_member.member_steam_id = steam_id
	new_member.member_steam_name = steam_name
	members.add_child(new_member)
	
	if user_steam_id == steam_id:
		new_member.challenge_button.visible = false
	
	var command_challenge: String = "/create_challenge " + str(user_steam_id) + " " + str(steam_id)
	
	var issue_challenge_signal: int = new_member.challenge_button.connect("button_up", Callable(self, "_send_command").bind(command_challenge))
	if issue_challenge_signal > OK:
		print("[STEAM] Connecting member's challenge button failed: " + str(issue_challenge_signal))


func _get_lobby_members() -> void:
	print("[STEAM] Updating member list")
	LOBBY_MEMBERS.clear()
	for member in members.get_children():
		member.hide()
		member.queue_free()
	
	var num_members: int = Steam.getNumLobbyMembers(LOBBY_ID)
	
	for member in range(0, num_members):
		var steam_id: int = Steam.getLobbyMemberByIndex(LOBBY_ID, member)
		var steam_name: String = Steam.getFriendPersonaName(steam_id)
		_add_to_playerlist(steam_id, steam_name)


func _on_Persona_Changed(steam_id: int, change_flag: int) -> void:
	print("[STEAM] Lobby member " + Steam.getFriendPersonaName(steam_id) + "'s information changed: " + str(change_flag))
	_get_lobby_members()


#func _update_lobby_match_settings() -> void:
	#var lobby_data: Dictionary = Steam.getAllLobbyData(LOBBY_ID)
	#lobby_data.erase("name")
	#lobby_data.erase("mode")
	#lobby_data.erase("lobby_type")
	#lobby_data.erase("lobby_state")
	#lobby_data.erase("lobby_password")
	#MATCH_SETTINGS = lobby_data


func _set_match_settings_tab_visibility() -> void:
	if not (Steam.getLobbyOwner(LOBBY_ID) == Steam.getSteamID() and using_owner_settings) or not using_owner_settings:
		match_settings_tab.visible = false

## TODO: This needs to be done on the networking side of things
#func _set_lobby_match_settings() -> void:
	#SettingsData.is_using_lobby = using_owner_settings
	#SettingsData.server_match_settings


func _send_command(command: String) -> void:
	var is_sent: bool = Steam.sendLobbyChatMsg(LOBBY_ID, command)
	if not is_sent:
			chat_display.append_text("[ERROR] Chat message failed to send.\n")

func _recieve_command(command: String) -> void:
	if command.begins_with("/create_challenge"):
		var participants: PackedStringArray = command.split(" ", true)
		
		# TODO: Add a way to allow the use of steam personas rather than ids
		var sender_id: int = int(participants[1])
		var recipient_id: int = int(participants[2])
		
		var is_valid: bool = true
		for challenge in CHALLENGES:
			if challenge.sender_id == sender_id and challenge.recipient_id == recipient_id:
				is_valid = false
		
		if is_valid:
			_create_challenge(sender_id, recipient_id)
		else:
			chat_display.append_text("[STEAM] Requested challenge already exists\n")
		
	elif command.begins_with("/accept_challenge"):
		var participants: PackedStringArray = command.split(" ", true)
		var sender_id: int  = int(participants[1])
		var recipient_id: int = int(participants[2])
		
		for challenge in CHALLENGES:
			if challenge.recipient_id == Steam.getSteamID() or challenge.sender_id == Steam.getSteamID():
				challenge.pop()
		
		if Steam.getSteamID() == sender_id:
			_host_start(recipient_id)
		elif Steam.getSteamID() == recipient_id:
			_client_start(sender_id)
		
		var new_ongoing_match: String = "/create_ongoing_match " + str(sender_id) + " " + str(recipient_id)
		_send_command(new_ongoing_match)
		
	elif command.begins_with("/reject_challenge"):
		pass
	
	elif command.begins_with("/create_ongoing_match"):
		var participants: PackedStringArray = command.split(" ", true)
		
		# TODO: Add a way to allow the use of steam personas rather than ids
		var p1_id: int = int(participants[1])
		var p2_id: int = int(participants[2])
		
		_create_ongoing_match(p1_id, p2_id)
	
	elif command.begins_with("/spectate"):
		var participants: PackedStringArray = command.split(" ", true)
		var p1_id: int = int(participants[1])
		
		_spectate_match(p1_id)
	
	elif command.begins_with("/kick"):
		var participants: PackedStringArray = command.split(" ", true)
		if Steam.getSteamID() == int(participants[1]):
			_exit_lobby()
	
	elif command.begins_with("/roll"):
		var dice: PackedStringArray = command.split(" ", true)
		var die_sides = int(dice[1])
		var result = randi() % die_sides + 1
		chat_display.append_text("[SYSTEM] " + Steam.getPersonaName() + " rolled a d" + str(die_sides) + "\n")
		chat_display.append_text("[SYSTEM] " + Steam.getPersonaName() + " rolled " + str(result) + "\n")
