extends Panel


onready var lobby_name_label = $TitleBox/LobbyNameLabel
onready var state_label = $LobbyStatus/StateLabel
onready var type_label = $LobbyStatus/TypeLabel
onready var chatbox = $Chat/Chatbox
onready var chat_line = $Chat/ChatEntry/ChatLine
onready var send_message_button = $Chat/ChatEntry/SendMessageButton
onready var spectate_button = $SettingsPane/ButtonPane/VBoxContainer/HBoxContainer/SpectateButton
onready var password_button = $SettingsPane/ButtonPane/VBoxContainer/HBoxContainer/PasswordButton
onready var exit_lobby_button = $SettingsPane/ButtonPane/VBoxContainer/HBoxContainer/ExitLobbyButton
onready var ready_button = $SettingsPane/ButtonPane/VBoxContainer/ReadyButton
onready var members = $LobbyMembersPane/Members
onready var start_match_button = $StartMatchButton

var lobby_name: String
var num_players: int
var p1_name: String
var p2_name: String
var p1_ready = false
var p2_ready = false
var p1_steamid: int
var p2_steamid: int
var current_player: int

var match_settings: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()


func handle_connecting_signals() -> void:
#	MenuSignalBus._connect_Signals(password_button, self, "button_up", "set_new_password")
#	MenuSignalBus._connect_Signals(exit_lobby_button, self, "button_up", "exit_lobby")
#	MenuSignalBus._connect_Signals(ready_button, self, "toggled", "on_ready_button_toggled")
	pass

