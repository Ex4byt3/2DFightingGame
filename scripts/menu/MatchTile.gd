extends Control


onready var spectate_button = $HBoxContainer/SpectateButton
onready var p1_name_label = $PlayersNames/Player1Info/NameLabel
onready var p2_name_label = $PlayersNames/Player2Info/NameLabel

const DEFAULT_LIVES: int = 2

var player1_name: String = "P1 NAME ERR"
var player2_name: String = "P2 NAME ERR"
var max_lives = DEFAULT_LIVES
var p1_health: int = 100
var p2_health: int = 100



# Called when the node enters the scene tree for the first time.
func _ready():
	_set_tile_data()
	pass


func _set_tile_data() -> void:
	p1_name_label.set_text(player1_name)
	p2_name_label.set_text(player2_name)
