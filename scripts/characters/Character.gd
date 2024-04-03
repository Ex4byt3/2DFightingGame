extends SGCharacterBody2D

# Character class which contains variables/functions applicable to all character archetypes
class_name Character

# Constants
enum Buttons {
	# directions are their numpad notation in the first 4 bits (& 15)
	light = 1 << 4,
	medium = 1 << 5,
	heavy = 1 << 6,
	impact = 1 << 7,
	dash = 1 << 8,
	shield = 1 << 9,
	sprint = 1 << 10,
	jump = 1 << 11
}
const ReverseButtons = {
	16: "light",
	32: "medium",
	64: "heavy",
	128: "impact",
	256: "dash",
	512: "shield",
	1024: "sprint",
	2048: "jump"
}
const ButtonsIndex = {
	"light": 2,
	"medium": 3,
	"heavy": 4,
	"impact": 5,
	"dash": 6,
	"shield": 7,
	"sprint": 8,
	"jump": 9
}

var held = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

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

const dash_animaiton_map = {
	[0, 0]: "DashR",
	[1, 0]: "DashR",
	[-1, 0]: "DashR",
	[1, 1]: "DashUR",
	[-1, 1]: "DashUR",
	[1, -1]: "DashDR",
	[-1, -1]: "DashDR",
	[0, 1]: "DashU",
	[0, -1]: "DashD"
}

# State machine
@onready var stateMachine = $StateMachine
@onready var hurtBox = $HurtBox
@onready var hurtBoxShape = $HurtBox/HurtBox
@onready var pushBox = $PushBox
@onready var gameManager = get_node("../GameManager")
@onready var hitbox = $Hitbox

@onready var FixedAnimator = $FixedAnimationPlayer

# Variables for every character
var input_vector := SGFixed.vector2(0, 0)
var input_prefix := "player1_"
var controlBuffer := [[0, 0, 0]]
var motionInputLeinency = 45
var overlappingHurtbox := []
var overlappingPushbox := []
var pressed : int = 0
var facingRight := true # for flipping the sprite
var frame : int = 0 # Frame counter for anything that happens over time
var recovery = false # If the attack has ended
var attack_ended = false # If the attack has ended
var involnrable = false # If the character is invulnerable
var hurtboxCollision = {} # hurtboxCollision dictionary
var pushboxCollision = {} # pushboxCollision dictionary
var weightKnockbackScale = 100 * SGFixed.ONE # The higher the number, the less knockback the character will take
var weight = 100 # The weight of the character
var knockbackMultiplier = SGFixed.ONE # The higher the number, the more knockback the character will take
var hitstunMultiplier = SGFixed.ONE # The higher the number, the more hitstun the character will take
var pushForce = 5 * SGFixed.ONE
var pushVector = SGFixed.vector2(0, 0)
var blockMask : int = 0
var hitstop = 0

# Variables for status in all characters
var character_name: String
var character_img: Texture2D
var num_lives: int
var max_health: int
var health: int
var burst: int
var meterVal: int
var meterCharge: int
var meterValRate = 10000
var max_meter = 10000
var meter_rate = 100
var is_dead: bool = false

# Collision booleans
var isOnCeiling := false
var isOnFloor := false
var isOnWallL := false
var isOnWallR := false
var wallBounceVelocity := SGFixed.vector2(0, 0)

var input : int = 0
var hitstopBuffer : int = 0 # bit mask of any input pressed in hitstun
var inputBufferArray := [0, 0, 0, 0]
var inputBuffer : int = 0
var attackDuration = 0 # How long the attack lasts
var bufferIdx := 0

func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "apply_match_settings", "_apply_match_settings")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "setup_round", "_reset_character")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "start_round", "_start_round")


func _init_character_data(this_img, this_name, this_max_health) -> void:
	character_img = this_img
	character_name = this_name
	max_health = this_max_health
	
	health = max_health

	MenuSignalBus.emit_update_character_image(character_img, self.name)
	MenuSignalBus.emit_update_character_name(character_name, self.name)
	MenuSignalBus.emit_update_max_health(max_health, self.name)


func _apply_match_settings(match_settings: Dictionary) -> void:
	print("[COMBAT] " + self.name + " received settings!")
	num_lives = match_settings.character_lives
	burst = match_settings.initial_burst
	meterCharge = match_settings.initial_meter
	print("[COMBAT] " + self.name + "'s settings have been applied!")
	
	MenuSignalBus.emit_update_lives(num_lives, self.name)
	MenuSignalBus.emit_update_burst(burst, self.name)
	MenuSignalBus.emit_update_meter_charge(meterCharge, self.name)


# Setting up the round health
func _reset_character() -> void:
	health = max_health
	print("[COMBAT] Reset " + self.name + "'s health: " + str(health))
	
	MenuSignalBus.emit_update_health(health, self.name)
	MenuSignalBus.emit_player_ready(self.name)


func _network_preprocess(userInput: Dictionary) -> void:
	input = userInput["input"]
	inputBufferArray[bufferIdx] = input
	bufferIdx = (bufferIdx + 1) % 4
	inputBuffer = 0
	for i in inputBufferArray:
		inputBuffer |= i

	################################
	# Capcom style of input buffer #
	################################
	if held[0] != input & 15:
		held[0] = input & 15
		held[1] = 1
	else:
		held[1] += 1

	if input & Buttons.light:
		held[ButtonsIndex.light] += 1
	else:
		if held[ButtonsIndex.light] > 0:
			held[ButtonsIndex.light] = -1 # negative edge
		else: 
			held[ButtonsIndex.light] -= 1

	if input & Buttons.medium:
		held[ButtonsIndex.medium] += 1
	else:
		if held[ButtonsIndex.medium] > 0:
			held[ButtonsIndex.medium] = -1 # negative edge
		else: 
			held[ButtonsIndex.medium] -= 1
	
	if input & Buttons.heavy:
		held[ButtonsIndex.heavy] += 1
	else:
		if held[ButtonsIndex.heavy] > 0:
			held[ButtonsIndex.heavy] = -1 # negative edge
		else: 
			held[ButtonsIndex.heavy] -= 1

	if input & Buttons.impact:
		held[ButtonsIndex.impact] += 1
	else:
		if held[ButtonsIndex.impact] > 0:
			held[ButtonsIndex.impact] = -1 # negative edge
		else: 
			held[ButtonsIndex.impact] -= 1

	held[ButtonsIndex.light] = held[ButtonsIndex.light] + 1 if input & Buttons.light else 0
	held[ButtonsIndex.medium] = held[ButtonsIndex.medium] + 1 if input & Buttons.medium else 0
	held[ButtonsIndex.heavy] = held[ButtonsIndex.heavy] + 1 if input & Buttons.heavy else 0
	held[ButtonsIndex.impact] = held[ButtonsIndex.impact] + 1 if input & Buttons.impact else 0

	held[ButtonsIndex.dash] = held[ButtonsIndex.dash] + 1 if input & Buttons.dash else 0
	held[ButtonsIndex.shield] = held[ButtonsIndex.shield] + 1 if input & Buttons.shield else 0
	held[ButtonsIndex.sprint] = held[ButtonsIndex.sprint] + 1 if input & Buttons.sprint else 0
	held[ButtonsIndex.jump] = held[ButtonsIndex.jump] + 1 if input & Buttons.jump else 0

	# if inputInt > 0:
	# 	print(inputInt)
	# 	print(held)

# Input functions
# Like Input.get_vector but for SGFixedVector2
func get_fixed_input_vector(negative_x: String, positive_x: String, negative_y: String, positive_y: String) -> Array:
	var new_vector = [0, 0]
	if Input.is_action_pressed(negative_x):
		new_vector[0] -= 1
	if Input.is_action_pressed(positive_x):
		new_vector[0] += 1
	if Input.is_action_pressed(negative_y):
		new_vector[1] -= 1
	if Input.is_action_pressed(positive_y):
		new_vector[1] += 1
	return new_vector

# Getting local input using SG Physics
func _get_local_input() -> Dictionary:
	var newInputVector = get_fixed_input_vector(input_prefix + "left", input_prefix + "right", input_prefix + "down", input_prefix + "up")
	var userInput := {"input": 0}
	userInput["input_vector_x"] = newInputVector[0]
	userInput["input_vector_y"] = newInputVector[1]
	match newInputVector:
		[-1, -1]:
			userInput["input"] += 1
		[0, -1]:
			userInput["input"] += 2
		[1, -1]:
			userInput["input"] += 3
		[-1, 0]:
			userInput["input"] += 4
		[0, 0]:
			userInput["input"] += 5
		[1, 0]:
			userInput["input"] += 6
		[-1, 1]:
			userInput["input"] += 7
		[0, 1]:
			userInput["input"] += 8
		[1, 1]:
			userInput["input"] += 9

	if Input.is_action_pressed(input_prefix + "light"):
		userInput["input"] += Buttons.light
	if Input.is_action_pressed(input_prefix + "medium"):
		userInput["input"] += Buttons.medium
	if Input.is_action_pressed(input_prefix + "heavy"):
		userInput["input"] += Buttons.heavy
	if Input.is_action_pressed(input_prefix + "impact"):
		userInput["input"] += Buttons.impact
	if Input.is_action_pressed(input_prefix + "dash"):
		userInput["input"] += Buttons.dash
	if Input.is_action_pressed(input_prefix + "shield"):
		userInput["input"] += Buttons.shield
	if Input.is_action_pressed(input_prefix + "sprint_macro"): # pressed, not just pressed to allow for holding
		userInput["input"] += Buttons.sprint
	if Input.is_action_pressed(input_prefix + "jump"):
		userInput["input"] += Buttons.jump
	
	return userInput

# Increase meter function
func increase_meter(amount: int) -> void:
	# only ARMG will allow meter to go over max
	if meterCharge < max_meter:
		meterCharge += amount
		if meterCharge > max_meter:
			meterCharge = max_meter
	#print("Meter increased by ", amount, ". New meter value: ", meter)

# Decrease meter function
func decrease_meter(amount: int) -> void:
	if meterCharge > 0:
		meterCharge -= amount
		# you can't have negative meter
		if meterCharge < 0:
			meterCharge = 0
	#print("Meter decreased by ", amount, ". New meter value: ", meter)

func check_collisions() -> void:
	hurtboxCollision = {}
	pushboxCollision = {}
	overlappingHurtbox = hurtBox.get_overlapping_areas() # should only ever return 1 hitbox so we always use index 0
	if len(overlappingHurtbox) > 0: 
		if !overlappingHurtbox[0].used:
			# TODO: other hitbox properties
			overlappingHurtbox[0].used = true
			hurtboxCollision = overlappingHurtbox[0].properties
	overlappingPushbox = pushBox.get_overlapping_areas()
	if len(overlappingPushbox) > 0:
		var pushDirection = (self.get_global_fixed_position().sub(overlappingPushbox[0].get_global_fixed_position())).normalized()
		pushVector = pushDirection.mul(pushForce)
		pushVector.y = 0
	else:
		pushVector = SGFixed.vector2(0, 0)

# TODO: implement this function
func take_damage(damage) -> void:
	# TODO: can't be below 0, dying logic
	health -= damage
	MenuSignalBus.emit_update_health(health, self.name)

func apply_knockback(force: int, angle_radians: int):
	# Assuming 'force' is scaled already
	var knockback = SGFixed.vector2(SGFixed.ONE, 0) # RIGHT
	# var weight_scale = SGFixed.div(weight, weightKnockbackScale) # Can adjust the second number to adjust weight scaling.
	knockback.rotate(-angle_radians) # -y is up
	# knockback.imul(SGFixed.div(force, weight_scale))
	knockback.imul(force)
	velocity = knockback

func apply_pushbox_force() -> void:
	pass
