extends Control

onready var name_label = $InfoPane/Infobox/NameLabel
onready var state_label = $InfoPane/Infobox/LobbyStatus/StateLabel
onready var type_label = $InfoPane/Infobox/LobbyStatus/TypeLabel
onready var connection_label = $InfoPane/Infobox/LobbyStatus/ConnectionLabel
onready var host_name_label = $InfoPane/ParticipantsInfo/HostNameLabel
onready var num_players_label = $InfoPane/ParticipantsInfo/Panel/HBoxContainer/NumPlayersLabel

# Variables used in the creation of a new lobby
var lobby_name = "Default"
var lobby_state = "Open"
var lobby_type = "Public"
var network_type = 2
var host_name = str("Host: ", Steam.getPersonaName())
var num_players = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	name_label.set_text(lobby_name)
	state_label.set_text(lobby_state)
	type_label.set_text(lobby_type)
	host_name_label.set_text(host_name)
	num_players_label.set_text(str(num_players))
	
	if network_type == 2:
		connection_label.set_text("Steam")
	else:
		connection_label.set_text("ENET")
	
