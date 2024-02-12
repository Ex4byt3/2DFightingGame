extends Panel


onready var lobby_name_label = $TitleBox/LobbyNameLabel
onready var state_label = $LobbyStatus/StateLabel
onready var type_label = $LobbyStatus/TypeLabel
#onready var p1_name_label = $LobbyMembers/P1Box/P1NameLabel
#onready var p2_name_label = $LobbyMembers/P2Box/P2NameLabel
onready var chatbox = $Chat/Chatbox
onready var chat_entry_line = $Chat/ChatEntryLine
onready var password_button = $SettingsPane/ButtonPane/VBoxContainer/HBoxContainer/PasswordButton
onready var exit_lobby_button = $SettingsPane/ButtonPane/VBoxContainer/HBoxContainer/ExitLobbyButton
onready var ready_button = $SettingsPane/ButtonPane/VBoxContainer/ReadyButton
onready var members = $LobbyMembersPane/Members

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
	password_button.connect("button_up", self, "set_new_password")
	exit_lobby_button.connect("button_up", self, "exit_lobby")
	ready_button.connect("toggled", self, "on_ready_button_toggled")


func set_new_password() -> void:
	pass


func exit_lobby() -> void:
	pass


func on_ready_button_toggled(button_pressed) -> void:
	pass


func change_host() -> void:
	pass
