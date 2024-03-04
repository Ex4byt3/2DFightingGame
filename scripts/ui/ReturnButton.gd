extends MarginContainer


onready var button_title = $HBoxContainer/ButtonTitle
onready var button_area = $ButtonArea

var title: String


# Called when the node enters the scene tree for the first time.
func _ready():
	button_title.set_text(title)
