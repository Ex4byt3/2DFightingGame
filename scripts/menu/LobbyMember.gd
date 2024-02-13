extends HBoxContainer

onready var name_label = $NameLabel
onready var ready_label = $ReadyLabel

var steam_id: int
var steam_name: String
var is_ready: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_member_info()


func _set_member_info() -> void:
	name_label.set_text(steam_name)
	ready_label.set_text("Not Ready")
