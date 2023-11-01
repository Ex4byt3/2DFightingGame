extends Button

export var path = 'res://stages/Test stage.tscn'

func _on_SinglePlayerButton_focus_entered():
	add_color_override("font_outline_color", Color(1, 0.32549020648003, 0))

func _on_SinglePlayerButton_focus_exited():
	add_color_override("font_outline_color", Color(0, 0, 0))

func _on_pressed():
		get_tree().change_scene('res://src/examples/lobby.tscn')


func _on_Area2D_area_entered(area):
	emit_signal("focus_entered")

func _on_Area2D_area_exited(area):
	emit_signal("focus_exited")


func _on_PLAY_pressed():
	pass # Replace with function body.


func _on_QuitButton_focus_entered():
	pass # Replace with function body.
