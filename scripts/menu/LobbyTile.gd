extends Control


onready var name_label = $InfoPane/Infobox/NameLabel
onready var type_label = $InfoPane/Infobox/LobbyStatus/TypeLabel
onready var state_label = $InfoPane/Infobox/LobbyStatus/StateLabel
onready var connection_label = $InfoPane/Infobox/LobbyStatus/ConnectionLabel
onready var host_name_label = $InfoPane/ParticipantsInfo/HostNameLabel
onready var join_button = $Background/Highlight/JoinButton

var lobby_name = "Default"
var lobby_password: String
var lobby_type = "Public"
var lobby_state = "Open"
var network_type = "Steam"
var lobby_host_name = "Default"
var lobby_host_steamid: int


# Called when the node enters the scene tree for the first time.
func _ready():
	apply_lobby_settings()
	handle_connecting_signals()


func apply_lobby_settings() -> void:
	name_label.set_text(lobby_name)
	type_label.set_text(lobby_type)
	state_label.set_text(lobby_state)
	connection_label.set_text(network_type)
	host_name_label.set_text(lobby_host_name)


func handle_connecting_signals() -> void:
	join_button.connect("button_up", self, "join_lobby")


func join_lobby() -> void:
	if not lobby_state == "Full":
		
		var lobby_settings: Dictionary = {
			"lobby_name": lobby_name,
			"lobby_password": lobby_password,
			"lobby_type": lobby_type,
			"lobby_host_name": lobby_host_name,
			"lobby_host_steamid": lobby_host_steamid
		}
		
		SettingsSignalBus.emit_update_lobby_pane(lobby_settings)
		
	else:
		pass
