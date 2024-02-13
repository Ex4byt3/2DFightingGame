extends Control


onready var name_label = $InfoPane/Infobox/NameLabel
onready var type_label = $InfoPane/Infobox/LobbyStatus/TypeLabel
onready var state_label = $InfoPane/Infobox/LobbyStatus/StateLabel
onready var connection_label = $InfoPane/Infobox/LobbyStatus/ConnectionLabel
onready var host_name_label = $InfoPane/ParticipantsInfo/HostNameLabel
onready var num_members_label = $InfoPane/ParticipantsInfo/Panel/HBoxContainer/NumMembersLabel
onready var join_button = $Background/Highlight/JoinButton

var lobby_name =  "Default"
var lobby_type = "Public"
var lobby_state = "Open"
var network_type = "Steam"
var lobby_host_name: String = "Default"
var num_lobby_members: int = 0
var max_lobby_members: int = 0


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
	num_members_label.set_text(str(num_lobby_members))


func handle_connecting_signals() -> void:
	pass
