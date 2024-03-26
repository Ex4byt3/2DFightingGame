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
@onready var pushBox = $PushBox
@onready var gameManager = get_node("../GameManager")

# Variables for every character
var input_vector := SGFixed.vector2(0, 0)
var input_prefix := "player1_"
var controlBuffer := [[0, 0, 0]]
var motionInputLeinency = 45
var overlappingHurtbox := []
var overlappingPushbox := []
var usedJump = false # will need to replace with some sort of array to cover similar cases other than jump
var facingRight := true # for flipping the sprite
var frame : int = 0 # Frame counter for anything that happens over time
var recovery = false # If the attack has ended
var attack_ended = false # If the attack has ended
var involnrable = false # If the character is invulnerable
var hurtboxCollision = {} # hurtboxCollision dictionary
var pushboxCollision = {} # pushboxCollision dictionary
var weightKnockbackScale = 100 * SGFixed.ONE # The higher the number, the less knockback the character will take
var weight = 100 # The weight of the character
var knockbackMultiplier = 1 # The higher the number, the more knockback the character will take
var pushForce = 5 * SGFixed.ONE
var pushVector = SGFixed.vector2(0, 0)

# Variables for status in all characters
var character_name: String
var character_img: Texture2D
var num_lives: int
var max_health: int
var health: int
var burst: int
var meter: int
var max_meter = 90000
var meter_rate = 10
var is_dead: bool = false

# Collision booleans
var isOnCeiling := false
var isOnFloor := false
var isOnWallL := false
var isOnWallR := false
var wallBounceVelocity := SGFixed.vector2(0, 0)

var input := {} # Input dictionary

func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "apply_match_settings", "_apply_match_settings")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "setup_round", "_reset_character")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "start_round", "_start_round")


func _apply_match_settings(match_settings: Dictionary) -> void:
	print("[COMBAT] " + self.name + " received settings!")
	num_lives = match_settings.character_lives
	burst = match_settings.initial_burst
	meter = match_settings.initial_meter
	print("[COMBAT] " + self.name + "'s settings have been applied!")
	
	MenuSignalBus.emit_update_lives(num_lives, self.name)
	MenuSignalBus.emit_update_burst(burst, self.name)
	MenuSignalBus.emit_update_meter(meter, self.name)


# Setting up the round health
func _reset_character() -> void:
	health = max_health
	print("[COMBAT] Reset " + self.name + "'s health: " + str(health))
	
	MenuSignalBus.emit_update_health(health, self.name)
	MenuSignalBus.emit_player_ready(self.name)


func _get_lives():
	return num_lives


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
	# only ARMG will allow meter to go over max
	if meter < max_meter:
		meter += amount
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

func check_collisions() -> void:
	hurtboxCollision = {}
	pushboxCollision = {}
	overlappingHurtbox = hurtBox.get_overlapping_areas() # should only ever return 1 hitbox so we always use index 0
	if len(overlappingHurtbox) > 0: 
		if !overlappingHurtbox[0].used:
			# TODO: other hitbox properties
			overlappingHurtbox[0].used = true
			hurtboxCollision = {
				damage = overlappingHurtbox[0].damage,
				hitstun = overlappingHurtbox[0].hitstun,
				knockbackForce = overlappingHurtbox[0].knockbackForce,
				knockbackAngle = overlappingHurtbox[0].knockbackAngle,
			}
	overlappingPushbox = pushBox.get_overlapping_areas()
	if len(overlappingPushbox) > 0:
		var pushDirection = (self.get_global_fixed_position().sub(overlappingPushbox[0].get_global_fixed_position())).normalized()
		pushVector = pushDirection.mul(pushForce)
		pushVector.y = 0
	else:
		pushVector = SGFixed.vector2(0, 0)

# TODO: implement this function
func take_damage(damage) -> void:
	health -= damage
	MenuSignalBus.emit_update_health(health, self.name)

func apply_knockback(force: int, angle_radians: int):
	# Assuming 'force' is scaled already
	var knockback = SGFixed.vector2(SGFixed.ONE, 0) # RIGHT
	var weight_scale = SGFixed.div(weight, weightKnockbackScale) # Can adjust the second number to adjust weight scaling.
	knockback.rotate(-angle_radians) # -y is up
	knockback.imul(SGFixed.div(force, weight_scale))
	knockback.imul(knockbackMultiplier)
	velocity = knockback

func apply_hitstop(duration):
	# duration is in seconds
	get_tree().paused = true
	await get_tree().create_timer(duration).timeout
	get_tree().paused = false

func apply_pushbox_force() -> void:
	pass
