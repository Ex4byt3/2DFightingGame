# This script current hold all the player logic,
# later Character.gd will need to handel only the bare framework of a character
# and then character logic will get moved to a seperate script for each character
# that will then extend this
extends SGKinematicBody2D

# State machine
onready var stateMachine = $StateMachine
onready var rng = $NetworkRandomNumberGenerator

# Variables that are saved in state for rollback
var velocity := SGFixed.vector2(0, 0)
var input_prefix := "player1_"
var is_on_floor := false
var controlBuffer := [[0, 0, 0]]

func _ready():
	stateMachine.parent = self

# like Input.get_vector but for SGFixedVector2
# note: Input.is_action_just_pressed returns a float
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
	if Input.is_action_pressed(positive_y):
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

func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	input.erase("drop_bomb")
	if ticks_since_real_input > 2:
		input.erase("input_vector")
	return input

func _network_process(input: Dictionary) -> void:
	# Get input vector
	var input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	
	# Transition state and calculate velocity off of this logic
	velocity = stateMachine.transition_state(input)
	
	# Update position based off of velocity
	fixed_position = fixed_position.add(velocity)
	velocity = move_and_slide(velocity, SGFixed.vector2(0, -SGFixed.ONE))
	
	# Update is_on_floor, does not work if called before move_and_slide, works if called a though
	is_on_floor = is_on_floor() 
	
func _save_state() -> Dictionary:
	var control_buffer = []
	for item in controlBuffer:
		control_buffer.append(item)
	return {
		control_buffer = control_buffer,
		fixed_position_x = fixed_position.x,
		fixed_position_y = fixed_position.y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		is_on_floor = is_on_floor,
	}

func _load_state(state: Dictionary) -> void:
	controlBuffer = []
	for item in state['control_buffer']:
		controlBuffer.append(item)
	fixed_position.x = state['fixed_position_x']
	fixed_position.y = state['fixed_position_y']
	velocity.x = state['velocity_x']
	velocity.y = state['velocity_y']
	is_on_floor = state['is_on_floor']
	sync_to_physics_engine()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	fixed_position = old_state['fixed_position'].linear_interpolate(new_state['fixed_position'], weight)
