extends Control


var initial_menu: String = "MainMenu"
var count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _unhandled_key_input(event):
	if event.is_pressed() and not event.is_action("ui_cancel") and count == 0:
		get_parent().menu_tree.append(initial_menu)
		MenuSignalBus.emit_setup_menu()
		count += 1
