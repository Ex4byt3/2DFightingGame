extends Control


var initial_menu: String = "MainMenu"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_key_input(event):
	if event.is_pressed():
		get_parent().menu_tree.append(initial_menu)
		MenuSignalBus.emit_setup_menu()
