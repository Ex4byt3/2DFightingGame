extends SGCharacterBody2D

# Character class which contains variables/functions applicable to all character archetypes
class_name Character

# Constants
enum Buttons {
	# directions are their numpad notation in the first 4 bits (& 15)
	up = 1 << 0,
	down = 1 << 1,
	left = 1 << 2,
	right = 1 << 3,
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
	1: "up",
	2: "down",
	4: "left",
	8: "right",
	16: "light",
	32: "medium",
	64: "heavy",
	128: "impact",
	256: "dash",
	512: "shield",
	1024: "sprint",
	2048: "jump"
}

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
# UDLR
# const directions = {
# 	0b0110: 1, # Down Left
# 	0b0100: 2, # Down
# 	0b0101: 3, # Down Right
# 	0b0010: 4, # Left
# 	0b0000: 5, # Neutral
# 	0b0001: 6, # Right
# 	0b1010: 7, # Up Left
# 	0b1000: 8, # Up
# 	0b1001: 9  # Up Right
# }

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
var is_disabled: bool = false

# Collision booleans
var isOnCeiling := false
var isOnFloor := false
var isOnWallL := false
var isOnWallR := false
var wallBounceVelocity := SGFixed.vector2(0, 0)

var input : int = 0
var hitstopBuffer : int = 0 # bit mask of any input pressed in hitstun
# buffers are all circular to avoid reindexing
var inputBufferArray := [0, 0, 0, 0]
var inputBuffer : int = 0
var bufferIdx := 0

# this is a little silly
# var inputHistory := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
# var inputHistoryIdx := 0

func _ready():
	_handle_connecting_signals()

func _handle_connecting_signals() -> void:
	MenuSignalBus.apply_match_settings.connect(_apply_match_settings)
	MatchSignalBus.setup_round.connect(_reset_character)
	#MenuSignalBus.setup_round.connect(_reset_character)
	#MatchSignalBus.setup_round.connect(_reset_character)
	#MenuSignalBus.start_round.connect(_start_round)
	#MatchSignalBus.start_combat.connect(_start_combat)


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
	#print("[COMBAT] Reset " + self.name + "'s health: " + str(health))
	#MenuSignalBus.emit_player_ready(self.name)
	knockbackMultiplier = SGFixed.ONE # reset knockback multiplier to 1
	hitstunMultiplier = SGFixed.ONE # reset hitstun multiplier to 1
	print("[COMBAT] Reset " + self.name + "'s health: " + str(health))
	
	#MenuSignalBus.emit_update_health(health, self.name)
	#MenuSignalBus.emit_player_ready(self.name)


func _network_preprocess(userInput: Dictionary) -> void:
	if !userInput.has("input"):
		print("[NETWORKING] Missing input")
		return
	input = userInput["input"]
	inputBuffer = input
	inputBufferArray[bufferIdx] = input
	bufferIdx = (bufferIdx + 1) % 4 # 4 frame buffer
	inputBuffer = 0
	for i in inputBufferArray:
		inputBuffer |= i

	# note: currently holds exactly 30 frames but can copy the logic from control buffer and have it store the number of frames the input was pressed aswell
	# inputHistory[inputHistoryIdx] = input
	# inputHistoryIdx = (inputHistoryIdx + 1) % 30 # 30 frame buffer

# Getting local input using SG Physics
func _get_local_input() -> Dictionary:
	# var newInputVector = get_fixed_input_vector(input_prefix + "left", input_prefix + "right", input_prefix + "down", input_prefix + "up")
	var userInput := {"input": 0}
	if Input.is_action_pressed(input_prefix + "up"):
		userInput["input"] += Buttons.up
	if Input.is_action_pressed(input_prefix + "down"):
		userInput["input"] += Buttons.down
	if Input.is_action_pressed(input_prefix + "left"):
		userInput["input"] += Buttons.left
	if Input.is_action_pressed(input_prefix + "right"):
		userInput["input"] += Buttons.right
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
	if Input.is_action_pressed(input_prefix + "sprint_macro"):
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

func check_collisions() -> int:
	var isHit = 0
	hurtboxCollision = {}
	pushboxCollision = {}
	overlappingHurtbox = hurtBox.get_overlapping_areas() # should only ever return 1 hitbox so we always use index 0
	if len(overlappingHurtbox) > 0:
		if !overlappingHurtbox[0].used:
			# TODO: other hitbox properties
			overlappingHurtbox[0].used = true
			hurtboxCollision = overlappingHurtbox[0].properties
			if overlappingHurtbox[0].properties["projectile"]:
				SyncManager.despawn(overlappingHurtbox[0])
			# TODO: canceling a move out of CF M calls this with an empty hurtboxCollision dictionary
				# or just CFM is buggy af
			isHit = hurtboxCollision["onHit"]["damage"]
	overlappingPushbox = pushBox.get_overlapping_areas()
	if len(overlappingPushbox) > 0:
		var pushDirection = (self.get_global_fixed_position().sub(overlappingPushbox[0].get_global_fixed_position())).normalized()
		pushVector = pushDirection.mul(pushForce)
		pushVector.y = 0
	else:
		pushVector = SGFixed.vector2(0, 0)
	
	return isHit

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
