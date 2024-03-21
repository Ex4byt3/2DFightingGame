extends SGCharacterBody2D

# Character class which contains variables/functions applicable to all character archetypes
class_name Character

# For our debug overlay
const direction_mapping = {  # Numpad Notation:
	[-1, -1]: "DOWN LEFT",   # 1
	[0, -1]:  "DOWN",        # 2
	[1, -1]:  "DOWN RIGHT",  # 3
	[-1, 0]:  "LEFT",        # 4
	[0, 0]:   "NEUTRAL",     # 5
	[1, 0]:   "RIGHT",       # 6
	[-1, 1]:  "UP LEFT",     # 7
	[0, 1]:   "UP",          # 8
	[1, 1]:   "UP RIGHT"     # 9
}

# Convert vector to Numpad Notation
const directions = {
	[-1, -1]: 1, # Down Back
	[0, -1]:  2, # Down
	[1, -1]:  3, # Down Forward
	[-1, 0]:  4, # Back
	[0, 0]:   5, # Neutral
	[1, 0]:   6, # Forward
	[-1, 1]:  7, # Up Back
	[0, 1]:   8, # Up
	[1, 1]:   9  # Up Forward
}

# State machine
@onready var stateMachine = $StateMachine
@onready var gameManager = get_node("../GameManager")

# Variables for every character
var input_vector := SGFixed.vector2(0, 0)
var input_prefix := "player1_"
var isOnFloor := false
var controlBuffer := [[0, 0, 0]]
var motionInputLeinency = 45
var overlappingHurtbox := []
var usedJump = false # will need to replace with some sort of array to cover similar cases other than jump
var facingRight := true # for flipping the sprite
var frame : int = 0 # Frame counter for anything that happens over time
var recovery = false # If the attack has ended
var attack_ended = false # If the attack has ended

# Variables for status in all characters
var character_name: String
var character_img: Texture2D
var num_lives: int
var health: int
var burst: int
var meter: int
var max_meter = 90000
var meter_rate = 10
var is_dead: bool = false

var input := {} # Input dictionary
func _network_preprocess(userInput: Dictionary) -> void:
	input = userInput

# Input functions
# Like Input.get_vector but for SGFixedVector2
func get_fixed_input_vector(negative_x: String, positive_x: String, negative_y: String, positive_y: String) -> SGFixedVector2:
	var new_vector = SGFixed.vector2(0, 0) # note: SGFixedVector2 is always passed by reference and can be copied with SGFixedVector2.copy()
	new_vector.x = 0
	new_vector.y = 0
	if Input.is_action_pressed(negative_x):
		new_vector.x -= 1
	if Input.is_action_pressed(positive_x):
		new_vector.x += 1
	if Input.is_action_pressed(negative_y):
		new_vector.y -= 1
	if Input.is_action_pressed(positive_y):
		new_vector.y += 1
	return new_vector

# Getting local input using SG Physics
func _get_local_input() -> Dictionary:
	input_vector = get_fixed_input_vector(input_prefix + "left", input_prefix + "right", input_prefix + "down", input_prefix + "up")
	var userInput := {}
	if input_vector != SGFixed.vector2(0, 0):
		userInput["input_vector_x"] = input_vector.x
		userInput["input_vector_y"] = input_vector.y
	if Input.is_action_just_pressed(input_prefix + "bomb"):
		userInput["drop_bomb"] = true
	if Input.is_action_just_pressed(input_prefix + "light"):
		userInput["attack_light"] = true
	if Input.is_action_just_pressed(input_prefix + "medium"):
		userInput["attack_medium"] = true
	if Input.is_action_just_pressed(input_prefix + "heavy"):
		userInput["attack_heavy"] = true
	if Input.is_action_just_pressed(input_prefix + "impact"):
		userInput["impact"] = true
	if Input.is_action_just_pressed(input_prefix + "dash"):
		userInput["dash"] = true
	if Input.is_action_just_pressed(input_prefix + "shield"):
		userInput["shield"] = true
	if Input.is_action_pressed(input_prefix + "sprint_macro"): # pressed, not just pressed to allow for holding
		userInput["sprint_macro"] = true
	if Input.is_action_just_pressed(input_prefix + "jump"):
		userInput["jump"] = true
	
	return userInput

# Increase meter function
func increase_meter(amount: int) -> void:
	if meter < max_meter:
		meter += amount
		# only ARMG will allow meter to go over max
		if meter > max_meter:
			meter = max_meter
	#print("Meter increased by ", amount, ". New meter value: ", meter)

# Decrease meter function
func decrease_meter(amount: int) -> void:
	if meter > 0:
		meter -= amount
		# you can't have negative meter
		if meter < 0:
			meter = 0
	#print("Meter decreased by ", amount, ". New meter value: ", meter)
