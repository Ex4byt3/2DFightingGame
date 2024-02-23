# This script current hold all the player logic,
# later Character.gd will need to handel only the bare framework of a character
# and then character logic will get moved to a seperate script for each character
# that will then extend this
extends SGKinematicBody2D
class_name Character

# State machine
onready var stateMachine = $StateMachine
onready var rng = $NetworkRandomNumberGenerator

# Variables that are saved in state for rollback
var velocity := SGFixed.vector2(0, 0)
var input_prefix := "player1_"
var is_on_floor := false
var controlBuffer := [[0, 0, 0]]

var facingRight := true # for flipping the sprite
var frame : int = 0 # Frame counter for anything that happens over time

# like Input.get_vector but for SGFixedVector2
func get_fixed_input_vector(negative_x: String, positive_x: String, negative_y: String, positive_y: String) -> SGFixedVector2:
	var input_vector = SGFixed.vector2(0, 0) # note: SGFixedVector2 is always passed by reference and can be copied with SGFixedVector2.copy()
	input_vector.x = 0
	input_vector.y = 0
	if Input.is_action_pressed(negative_x):
		input_vector.x -= 1
	if Input.is_action_pressed(positive_x):
		input_vector.x += 1
	if Input.is_action_pressed(negative_y):
		input_vector.y -= 1
	if Input.is_action_just_pressed(positive_y):
		input_vector.y += 1
	return input_vector

func _get_local_input() -> Dictionary:
	var input_vector = get_fixed_input_vector(input_prefix + "left", input_prefix + "right", input_prefix + "down", input_prefix + "up")
	var input := {}
	if input_vector != SGFixed.vector2(0, 0):
		input["input_vector_x"] = input_vector.x
		input["input_vector_y"] = input_vector.y
	if Input.is_action_just_pressed(input_prefix + "bomb"):
		input["drop_bomb"] = true
	if Input.is_action_just_pressed(input_prefix + "light"):
		input["attack_light"] = true
	if Input.is_action_just_pressed(input_prefix + "medium"):
		input["attack_medium"] = true
	if Input.is_action_just_pressed(input_prefix + "heavy"):
		input["attack_heavy"] = true
	if Input.is_action_just_pressed(input_prefix + "impact"):
		input["impact"] = true
	if Input.is_action_just_pressed(input_prefix + "dash"):
		input["dash"] = true
	if Input.is_action_just_pressed(input_prefix + "shield"):
		input["shield"] = true
	if Input.is_action_pressed(input_prefix + "sprint_macro"): # pressed, not just pressed to allow for holding
		input["sprint_macro"] = true
	
	return input