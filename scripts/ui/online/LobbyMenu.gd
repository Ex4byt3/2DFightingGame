extends Control


@onready var lobby_member = preload("res://scenes/ui/online/LobbyMember.tscn")
@onready var challenge_tile = preload("res://scenes/ui/online/ChallengeTile.tscn")
@onready var match_tile = preload("res://scenes/ui/online/MatchTile.tscn")

@onready var lobby_name_label = $Lobby/TitleBox/LobbyNameLabel
@onready var state_label = $Lobby/LobbyStatus/StateLabel
@onready var type_label = $Lobby/LobbyStatus/TypeLabel
@onready var members = $Lobby/LeftPane/LobbyMembersPane/Panel/ScrollContainer/Members

@onready var chat_button = $Lobby/RightPane/TabMenu/ChatButton
@onready var challenges_button =$Lobby/RightPane/TabMenu/ChallengesButton
@onready var matches_button = $Lobby/RightPane/TabMenu/MatchesButton
@onready var history_button = $Lobby/RightPane/TabMenu/HistoryButton

@onready var chat_tab = $Lobby/RightPane/ChatTab
@onready var chatbox = $Lobby/RightPane/ChatTab/Chatbox
@onready var chat_line = $Lobby/RightPane/ChatTab/ChatEntry/ChatLine
@onready var send_message_button = $Lobby/RightPane/ChatTab/ChatEntry/SendMessageButton

@onready var challenges_tab = $Lobby/RightPane/ChallengesTab
@onready var challenges = $Lobby/RightPane/ChallengesTab/ScrollContainer/Challenges

@onready var matches_tab = $Lobby/RightPane/MatchesTab
@onready var ongoing_matches = $Lobby/RightPane/MatchesTab/ScrollContainer/OngoingMatches

@onready var history_tab = $Lobby/RightPane/HistoryTab

@onready var match_settings = $Lobby/LeftPane/Controls/MatchControls/MatchSettingsButton
@onready var password_button = $Lobby/LeftPane/Controls/LobbyControls/PasswordButton
@onready var exit_lobby_button = $Lobby/LeftPane/Controls/LobbyControls/ExitLobbyButton

var LOBBY_ID: int = 0
var LOBBY_NAME: String = "Default"
var LOBBY_MEMBERS: Array = []
var CHALLENGES: Array = []
var ONGOING_MATCHES: Array = []


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
	
	MenuSignalBus._connect_Signals(chat_button, self, "toggled", "_show_chat")
	MenuSignalBus._connect_Signals(challenges_button, self, "toggled", "_show_pending_challenges")
	MenuSignalBus._connect_Signals(matches_button, self, "toggled", "_show_ongoing_matches")
	MenuSignalBus._connect_Signals(history_button, self, "toggled", "_show_match_history")
	
	MenuSignalBus._connect_Signals(exit_lobby_button, self, "button_up", "_on_exit_lobby")
	MenuSignalBus._connect_Signals(send_message_button, self, "button_up", "_on_send_message")


func _init_lobby() -> void:
	_get_lobby_members()
	LOBBY_ID = get_parent().lobby_id
	LOBBY_NAME = Steam.getLobbyData(LOBBY_ID, "name")
	lobby_name_label.set_text(LOBBY_NAME)


##################################################
# INPUT FUNCTIONS
##################################################
func _input(event) -> void:
	if event.is_action_released("chat_enter"):
		if chat_line.has_focus():
			_on_send_message()


##################################################
# BUTTON FUNCTIONS
##################################################
func _show_chat(button_pressed) -> void:
	if button_pressed:
		chat_tab.visible = true
	else:
		chat_tab.visible = false


func _show_pending_challenges(button_pressed) -> void:
	if button_pressed:
		challenges_tab.visible = true
	else:
		challenges_tab.visible = false


func _show_ongoing_matches(button_pressed) -> void:
	if button_pressed:
		matches_tab.visible = true
	else:
		matches_tab.visible = false


func _show_match_history(button_pressed) -> void:
	if button_pressed:
		history_tab.visible = true
	else:
		history_tab.visible = false


# When the lobby's exit button is pressed
func _on_exit_lobby() -> void:
	_leave_Steam_Lobby()
	chatbox.clear()
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
		chatbox.append_text("[STEAM] Leaving lobby...\n")
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
	for ongoing_match in ongoing_matches.get_children():
		ongoing_match.hide()
		ongoing_match.queue_free()
	
	for ongoing_match in ONGOING_MATCHES:
		var new_match_tile = match_tile.instantiate()
		new_match_tile.challenger_id = ongoing_match.sender_id
		new_match_tile.recipient_id = ongoing_match.recipient_id
		ongoing_matches.add_child(new_match_tile)
		
		var command_spectate: String = "/spectate " + ongoing_match.p1_id + " " + ongoing_match.p2_id
		var spectate_signal: int = new_match_tile.spectate_button.connect("button_up", Callable(self, "_send_command").bind(command_spectate))
		if spectate_signal > OK:
				print("[STEAM] Connecting to accept button failed: "+str(spectate_signal))


func _host_start() -> void:
	NetworkGlobal.NETWORK_TYPE = 2
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	
	NetworkGlobal.STEAM_IS_HOST = true
	print("[STEAM] Started match as server")
	
	MenuSignalBus.emit_start_match()
	#MenuSignalBus._change_Scene(self, map_holder_scene)

func _client_start(sender_id: int) -> void:
	var host_steam_id: int = sender_id
	NetworkGlobal.NETWORK_TYPE = 2
	GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
	
	NetworkGlobal.STEAM_IS_HOST = false
	NetworkGlobal.STEAM_OPP_ID = int(host_steam_id)
	print("[STEAM] Started match as client")
	
	MenuSignalBus.emit_start_match()
	#MenuSignalBus._change_Scene(self, map_holder_scene)


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
		chatbox.append_text("[STEAM] "+str(new_member)+" has joined the lobby.\n")
	# Else if a player has left the lobby
	elif chat_state == 2:
		chatbox.append_text("[STEAM] "+str(new_member)+" has left the lobby.\n")
	# Else if a player has been kicked
	elif chat_state == 8:
		chatbox.append_text("[STEAM] "+str(new_member)+" has been kicked from the lobby.\n")
	# Else if a player has been banned
	elif chat_state == 16:
		chatbox.append_text("[STEAM] "+str(new_member)+" has been banned from the lobby.\n")
	# Else there was some unknown change
	else:
		chatbox.append_text("[STEAM] "+str(new_member)+" did... something.\n")
	# Update the lobby now that a change has occurred
	_get_lobby_members()


func _on_Lobby_Message(_result: int, user: int, message: String, type: int) -> void:
	var message_source = Steam.getFriendPersonaName(user)
	
	# If this is a message or lobby host command
	if type == 1:
		# If the message was a lobby host command
		if user == Steam.getLobbyOwner(LOBBY_ID) and message.begins_with("/"):
			var parsed_string: PackedStringArray = message.split(" ", true)
			print("Lobby owner entered a command: " + parsed_string[0])
			_recieve_command(message)
		
		# Elif the message was a lobby member command
		elif message.begins_with("/"):
			var parsed_string: PackedStringArray = message.split(" ", true)
			print("Lobby member entered a command: " + parsed_string[0])
			_recieve_command(message)
		
		# Else this is a normal chat message
		else:
			# Append the message to chat
			chatbox.append_text("<" + str(message_source) + "> " + str(message) + "\n")
		
	# This message is not a normal message or a lobby host command
	else:
		match type:
			2: chatbox.append_text(str(message_source)+" is typing...\n")
			3: chatbox.append_text(str(message_source)+" sent an invite that won't work in this chat!\n")
			4: chatbox.append_text(str(message_source)+" sent a text emote that is deprecated.\n")
			6: chatbox.append_text(str(message_source)+" has left the chat.\n")
			7: chatbox.append_text(str(message_source)+" has entered the chat.\n")
			8: chatbox.append_text(str(message_source)+" was kicked!\n")
			9: chatbox.append_text(str(message_source)+" was banned!\n")
			10: chatbox.append_text(str(message_source)+" disconnected.\n")
			11: chatbox.append_text(str(message_source)+" sent an old, offline message.\n")
			12: chatbox.append_text(str(message_source)+" sent a link that was removed by the chat filter.\n")


# Send a chat message
func _on_send_message() -> void:
	var message = chat_line.get_text()
	
	# Check if there is a message
	if message.length() > 0:
		
		# Pass the message to Steam
		var is_sent: bool = Steam.sendLobbyChatMsg(LOBBY_ID, message)
		if not is_sent:
			chatbox.append_text("[ERROR] Chat message failed to send.\n")
		chat_line.clear()


##################################################
# HELPER FUNCTIONS
##################################################
func _add_to_playerlist(steam_id: int, steam_name: String) -> void:
	print("Adding new player: " + steam_name)
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


func _send_command(command: String) -> void:
	var is_sent: bool = Steam.sendLobbyChatMsg(LOBBY_ID, command)
	if not is_sent:
			chatbox.append_text("[ERROR] Chat message failed to send.\n")

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
			chatbox.append_text("[STEAM] Requested challenge already exists")
		
	elif command.begins_with("/accept_challenge"):
		var participants: PackedStringArray = command.split(" ", true)
		var sender_id: int  = int(participants[1])
		var recipient_id: int = int(participants[2])
		if Steam.getSteamID() == sender_id:
			_host_start()
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
			_on_exit_lobby()
	
	elif command.begins_with("/roll"):
		var dice: PackedStringArray = command.split(" ", true)
		var die_sides = int(dice[1])
		var result = randi() % die_sides + 1
		chatbox.append_text("[SYSTEM] " + Steam.getPersonaName() + " rolled a d" + str(die_sides) + "\n")
		chatbox.append_text("[SYSTEM] " + Steam.getPersonaName() + " rolled " + str(result) + "\n")
