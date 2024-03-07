extends SGCharacterBody2D
class_name Character


# for debug overlay
const direction_mapping = {
	[1, 1]: "UP RIGHT", # 9
	[1, 0]: "RIGHT", # 6
	[0, 1]: "UP", # 8
	[0, -1]: "DOWN", # 2
	[1, -1]: "DOWN RIGHT", # 3
	[-1, -1]: "DOWN LEFT", # 1
	[-1, 0]: "LEFT", # 4
	[-1, 1]: "UP LEFT" # 7
}

# convert a vector to numpad notation
const directions = {
	[0,0]: 5, # Neutral
	[0,1]: 8, # Up
	[0,-1]: 2, # Down
	[1,0]: 6, # Forward
	[-1,0]: 4, # Back
	[1,1]: 9, # Up Forward
	[1,-1]: 3, # Down Forward
	[-1,1]: 7, # Up Back
	[-1,-1]: 1 # Down Back
}

# State machine
@onready var stateMachine = $StateMachine
#@onready var rng = $NetworkRandomNumberGenerator

# Variables for every character
var input_vector := SGFixed.vector2(0, 0)
var input_prefix := "player1_"
var isOnFloor := false
var controlBuffer := [[0, 0, 0]]
var motionInputLeinency = 45
var overlappingHitBoxes := []
# will need to replace with some sort of array to cover similar cases other than jump
var usedJump = false

var facingRight := true # for flipping the sprite
var frame : int = 0 # Frame counter for anything that happens over time

# Variables for status in all characters
var character_name: String
var character_img: Texture2D
var health: int
var burst: int
var meter: int
var num_lives: int


##################################################
# INPUT FUNCTIONS
##################################################
# like Input.get_vector but for SGFixedVector2
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


func _get_local_input() -> Dictionary:
	input_vector = get_fixed_input_vector(input_prefix + "left", input_prefix + "right", input_prefix + "down", input_prefix + "up")
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
