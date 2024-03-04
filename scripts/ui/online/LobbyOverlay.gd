extends Control


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

var lobby_name: String
var num_players: int
var p1_name: String
var p2_name: String
var p1_ready = false
var p2_ready = false
var p1_steamid: int
var p2_steamid: int
var current_player: int


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(chat_button, self, "toggled", "_show_chat")
	MenuSignalBus._connect_Signals(challenges_button, self, "toggled", "_show_pending_challenges")
	MenuSignalBus._connect_Signals(matches_button, self, "toggled", "_show_ongoing_matches")
	MenuSignalBus._connect_Signals(history_button, self, "toggled", "_show_match_history")


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

