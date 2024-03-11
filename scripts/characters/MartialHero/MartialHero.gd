extends Character

@onready var animation = $NetworkAnimationPlayer
@onready var attackAnimationPlayer = $DebugAnimationPlayer
@onready var arrowSprite = $DebugSprite/DebugArrow
@onready var attackSprite = $DebugSprite/DebugAttack

var healthBar = null

# Character motion attributes
var walkSpeed = 4
var sprintSpeed = 8
@export_range(1, 10) var slideDecay = 4 # divisor
var slideJumpBoost = 0 # set in ready
var dashVector = SGFixed.vector2(0, 0)
@export_range(20, 50) var dashSpeed = 30
@export_range(5, 20) var keptDashSpeed = 15
@export_range(5, 20) var dashDuration = 6
var sprintInputLeinency = 6
@export_range(5, 20) var airAcceleration = 4 # divisor
var maxAirSpeed = 6
var gravity = (SGFixed.ONE / 10) * 6 # divsor
var maxAirJump = 1
var airJump = 0
var knockback_multiplier = 1
var weight = 100
var shortHopForce = 12
var fullHopForce = 16
var airHopForce = 12
@export_range(0, 5) var jumpSquatFrames = 3
var maxFallSpeed = 20

# Character attack attributes
var damage = 0
var takeDamage = false

# Valid motion inputs for the character, listed in priority
const motion_inputs = {
	623: 'DP',
	236: 'QCF',
	214: 'QCB'
}

# Local character data
var martial_hero_img = preload("res://assets/menu/images/ramlethal.jpg")
var martial_hero_name = "Martial Hero"
var max_health = 10000


func _ready():
	set_up_direction(SGFixed.vector2(0, -SGFixed.ONE))
	_handle_connecting_signals()
	_scale_to_fixed()
	_rotate_client_player()
	
	MenuSignalBus.emit_send_character_settings()


##################################################
# ONREADY FUNCTIONS
##################################################
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "apply_character_settings", "_apply_character_settings")


# Scale appropriate variables to fixed point numbers
func _scale_to_fixed() -> void:
	# gravity = SGFixed.div()
	maxAirSpeed *= SGFixed.ONE
	fullHopForce *= SGFixed.NEG_ONE
	shortHopForce *= SGFixed.NEG_ONE
	airHopForce *= SGFixed.NEG_ONE
	airAcceleration = SGFixed.ONE / airAcceleration
	slideDecay = SGFixed.ONE / slideDecay
	slideJumpBoost = SGFixed.ONE + (SGFixed.ONE / 2) # to maintain intiger division // 1.5


# Rotate the second player
func _rotate_client_player() -> void:
	if self.name == "ClientPlayer":
		facingRight = false
		# also flip collision layer and mask for client player
		$HurtBox.set_collision_layer_bit(1, false)
		$HurtBox.set_collision_layer_bit(2, true)


##################################################
# STATUS MANIPULATION FUNCTIONS
##################################################
func _apply_character_settings(character_settings: Dictionary) -> void:
	print("[SYSTEM] " + self.name + " received character settings!")
	num_lives = character_settings.character_lives
	burst = character_settings.initial_burst
	meter = character_settings.initial_meter
	print("[SYSTEM] " + self.name + "'s character settings have been applied!")
	
	MenuSignalBus.emit_update_lives(num_lives, self.name)
	
	_init_character_data()


func _init_character_data() -> void:
	character_img = martial_hero_img
	character_name = martial_hero_name
	health = max_health
	
	MenuSignalBus.emit_update_character_image(character_img, self.name)
	MenuSignalBus.emit_update_character_name(character_name, self.name)
	MenuSignalBus.emit_update_max_health(max_health, self.name)


func _setup_round() -> void:
	health = max_health


##################################################
# NETWORK RELATED FUNCTIONS
##################################################
func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	input.erase("drop_bomb")
	if ticks_since_real_input > 2:
		input.erase("input_vector")
	return input


func _network_process(input: Dictionary) -> void:
	# Update the character's health in the status overlay
	MenuSignalBus.emit_update_health(health, self.name)
	
	# Check if the character has been ko'd
	if health <= 0:
		num_lives -= 1
		if num_lives > 0:
			MenuSignalBus.emit_life_lost(self.name)
			MenuSignalBus.emit_update_lives(num_lives, self.name)
	
	# Transition state and calculate velocity off of this logic
	input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	stateMachine.transition_state(input)
	
	overlappingHurtbox = $HurtBox.get_overlapping_areas()
	if len(overlappingHurtbox) > 0:
		if overlappingHurtbox[0].used == false and overlappingHurtbox[0].attacking_player != self.name:
			takeDamage = true
			damage = overlappingHurtbox[0].damage
			overlappingHurtbox[0].used = true
	
	# Update position based off of velocity
	move_and_slide()
	
	# Update is_on_floor, does not work if called before move_and_slide, works if called a though
	isOnFloor = is_on_floor() 


##################################################
# STATE MACHINE FUNCTIONS
##################################################
func _save_state() -> Dictionary:
	var control_buffer = []
	for item in controlBuffer:
		control_buffer.append(item.duplicate())
	return {
		playerState = stateMachine.state,
		control_buffer = control_buffer,

		fixed_position_x = fixed_position.x,
		fixed_position_y = fixed_position.y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,

		dashVector_x = dashVector.x,
		dashVector_y = dashVector.y,
		airJump = airJump,
		isOnFloor = isOnFloor,
		usedJump = usedJump,
		frame = frame,
		damage = damage,
		takeDamage = takeDamage, # TODO: replace with HITSTUN state
		facingRight = facingRight,
		
		health = health,
		max_health = max_health,
		burst = burst,
		meter = meter,
		character_img = character_img, # TODO: is only loaded once, does not change, remove from state
		character_name = character_name, # TODO: is only loaded once, does not change, remove from state
		num_lives = num_lives
		
	}


func _load_state(loadState: Dictionary) -> void:
	stateMachine.state = loadState['playerState']
	controlBuffer = []
	for item in loadState['control_buffer']:
		controlBuffer.append(item.duplicate())
	fixed_position.x = loadState['fixed_position_x']
	fixed_position.y = loadState['fixed_position_y']
	velocity.x = loadState['velocity_x']
	velocity.y = loadState['velocity_y']

	dashVector.x = loadState['dashVector_x']
	dashVector.y = loadState['dashVector_y']
	airJump = loadState['airJump']
	usedJump = loadState['usedJump']
	isOnFloor = loadState['isOnFloor']

	health = loadState['health']
	damage = loadState['damage']
	takeDamage = loadState['takeDamage'] # TODO: replace with HITSTUN state
	facingRight = loadState['facingRight']
	frame = loadState['frame']
	
	health = loadState['health']
	max_health = loadState['max_health']
	burst = loadState['burst']
	meter = loadState['meter']
	character_img = loadState['character_img'] # TODO: is only loaded once, does not change, remove from state
	character_name = loadState['character_name'] # TODO: is only loaded once, does not change, remove from state
	num_lives = num_lives
	
	sync_to_physics_engine()


func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	fixed_position = old_state['fixed_position'].lerp(new_state['fixed_position'], weight)
