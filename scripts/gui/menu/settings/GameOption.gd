extends Control
class_name GameOption


var option_name: String = "Default"
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


func set_data(new_name: String, cat_in: String):
	option_name = new_name
	if cat_in in valid_categories:
		category = cat_in
		return OK
	else:
		return FAILED


func get_category():
	return category
