class_name GameOption
extends Control


var option_label: String = "Default"
var category: String = "None"

var valid_categories: Array = [
	"Display",
	"Sound",
	"Lobby",
	"Network",
	"Keybind",
	"Accessibility"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_data(label_in: String, cat_in: String):
	option_label = label_in
	if cat_in in valid_categories:
		category = cat_in
		return OK
	else:
		return FAILED


func get_category():
	return category
