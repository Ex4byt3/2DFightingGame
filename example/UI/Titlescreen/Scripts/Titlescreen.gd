extends Control

var current_state = States.PLAY
onready var getpointer = $Pointer

enum States{
	PLAY,
	OPTIONS,
	EXIT
}

func _process(delta):
	#When pressing select, Pointer checks which button it's on, and triggers its button
	if Input.is_action_just_pressed("ui_select_1") or Input.is_action_just_pressed("ui_select_2"):
		var dec = getpointer.get_overlapping_areas()
		for b in dec:
			if b.get_parent().name == "Play":
				b.get_parent().emit_signal("pressed")
			elif b.get_parent().name == "Option":
				b.get_parent().emit_signal("pressed")
			elif b.get_parent().name == "Exit":
				b.get_parent().emit_signal("pressed")
	#Pointer's position is determined by the current state
	match current_state:
		States.PLAY:
			play()
			if Input.is_action_just_pressed("up_1") or Input.is_action_just_pressed("up_2"):
				current_state = States.EXIT
			if Input.is_action_just_pressed("down_1") or Input.is_action_just_pressed("down_2"):
				current_state = States.OPTIONS
		States.OPTIONS:
			options()
			if Input.is_action_just_pressed("up_1") or Input.is_action_just_pressed("up_2"):
				current_state = States.PLAY
			if Input.is_action_just_pressed("down_1") or Input.is_action_just_pressed("down_2"):
				current_state = States.EXIT
		States.EXIT:
			exit()
			if Input.is_action_just_pressed("up_1") or Input.is_action_just_pressed("up_2"):
				current_state = States.OPTIONS
			if Input.is_action_just_pressed("down_1") or Input.is_action_just_pressed("down_2"):
				current_state = States.PLAY

func play():
	getpointer.global_position = Vector2(500,415)

func options():
	getpointer.global_position = Vector2(500,542)

func exit():
	getpointer.global_position = Vector2(500,657)
