extends Character

# Our nodes that we use in the scene
@onready var animation = $NetworkAnimationPlayer
@onready var attackAnimationPlayer = $DebugAnimationPlayer
@onready var arrowSprite = $DebugSprite/DebugArrow
@onready var attackSprite = $DebugSprite/DebugAttack

# SGFixed numbers
var ONE = SGFixed.ONE
var NEG_ONE = SGFixed.NEG_ONE

# Character motion attributes
@export_range(1, 10) var slideDecay = 4 # divisor
@export_range(20, 50) var dashSpeed = 30
@export_range(5, 20) var keptDashSpeed = 15
@export_range(5, 20) var dashDuration = 6
@export_range(5, 20) var airAcceleration = 4 # divisor
var walkSpeed = 4
var sprintSpeed = 8
var slideJumpBoost = 0 # set in ready
var dashVector = SGFixed.vector2(0, 0)
var knockbackForce = 0
var knockbackAngle = 0
var sprintInputLeinency = 6
var maxAirSpeed = 6
var knockdownVelocity = 40 # Velocity at which the player will enter knockdown when hitting the floor
var gravity = (ONE / 10) * 6 # divisor
var maxAirJump = 1
var airJump = 0
var knockback_multiplier = 1
var weight = 100
var weight_knockback_scale = 100 # divisor. knockback = force / (weight / weight_knockback_scale)
var quickGetUpFrames = 30
var shortHopForce = 12
var fullHopForce = 16
var airHopForce = 12
var jumpSquatFrames = 3
var maxFallSpeed = 20

# Character meter variables
var meter_frame_counter = 0 
var meter_frame_rate = 60
# TODO: other forms of meter gain

# Character attack attributes
var damage = 0
var takeDamage = false
var thrownHits = 0

# Valid motion inputs for the character, listed in priority
const motion_inputs = {
	623: 'DP',
	236: 'QCF',
	214: 'QCB'
	# TODO: list actual special move inputs
}

# Local character data
var martial_hero_img = preload("res://assets/menu/images/ramlethal.jpg")
var martial_hero_name = "Martial Hero"
const max_health = 10000

# Calling all onready functions
func _ready():
	set_up_direction(SGFixed.vector2(0, -ONE))
	_handle_connecting_signals()
	_scale_to_fixed()
	_rotate_client_player()


# Connecting signals to our menu
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "apply_match_settings", "_apply_match_settings")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "setup_round", "_setup_round")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "start_round", "_start_round")


# Scale appropriate variables to fixed point numbers
func _scale_to_fixed() -> void:
	maxAirSpeed *= ONE
	fullHopForce *= NEG_ONE
	shortHopForce *= NEG_ONE
	airHopForce *= NEG_ONE
	airAcceleration = ONE / airAcceleration
	slideDecay = ONE / slideDecay
	slideJumpBoost = ONE + (ONE / 2) # to maintain intiger division // 1.5
	weight *= ONE
	knockback_multiplier *= ONE
	weight_knockback_scale *= ONE
	knockdownVelocity *= ONE


# Rotate the second player
func _rotate_client_player() -> void:
	if self.name == "ClientPlayer":
		facingRight = false
		# also flip collision layer and mask for client player
		$HurtBox.set_collision_mask_bit(1, false)
		$HurtBox.set_collision_mask_bit(2, true)


# Status manipulation function
func _apply_match_settings(match_settings: Dictionary) -> void:
	print("[SYSTEM] " + self.name + " received settings!")
	num_lives = match_settings.character_lives
	burst = match_settings.initial_burst
	meter = match_settings.initial_meter
	print("[SYSTEM] " + self.name + "'s settings have been applied!")
	
	MenuSignalBus.emit_update_lives(num_lives, self.name)
	print("[SYSTEM] " + self.name + "'s lives remaining: " + str(num_lives))
	MenuSignalBus.emit_update_burst(burst, self.name)
	MenuSignalBus.emit_update_meter(meter, self.name)
	
	_init_character_data()

# Initializing the character data
func _init_character_data() -> void:
	character_img = martial_hero_img
	character_name = martial_hero_name
	health = max_health
	
	MenuSignalBus.emit_update_character_image(character_img, self.name)
	MenuSignalBus.emit_update_character_name(character_name, self.name)
	MenuSignalBus.emit_update_max_health(max_health, self.name)

# Settuping up the round health
func _setup_round() -> void:
	health = max_health
	print("[SYSTEM] Reset " + self.name + "'s health: " + str(health))
	MenuSignalBus.emit_update_health(health, self.name)

# Network-related function
func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	input.erase("drop_bomb")
	if ticks_since_real_input > 2:
		input.erase("input_vector")
	return input


func _network_process(input: Dictionary) -> void:
	# Update the character's health in the status overlay
	MenuSignalBus.emit_update_health(health, self.name)

	# increase_meter_over_time() # This was currently not rollback safe, commented for rollback testing hitboxes
	
	# Transition state and calculate velocity off of this logic
	input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	stateMachine.transition_state(input)
	
	# Update position based off of velocity
	move_and_slide()
	
	# Update is_on_floor, does not work if called before move_and_slide, works if called after though
	isOnFloor = is_on_floor() 

func increase_meter_over_time() -> void:
	if meter_frame_counter >= meter_frame_rate:
		increase_meter(meter_rate)
		meter_frame_counter = 0
		#print("Meter increased over time.")
	else:
		meter_frame_counter += 1

func check_hitbox_collision() -> void:
	overlappingHurtbox = $HurtBox.get_overlapping_areas() # should only ever return 1 hitbox so we always use index 0
	if len(overlappingHurtbox) > 0: 
		if overlappingHurtbox[0].used == false and overlappingHurtbox[0].attacking_player != self.name:
			takeDamage = true
			damage = overlappingHurtbox[0].damage # TODO: take damage funciton
			# TODO: other hitbox properties
			overlappingHurtbox[0].used = true

# TODO: implement this function
func take_damage() -> void:
	health -= damage
	MenuSignalBus.emit_update_health(health, self.name)

func apply_knockback(force: int, angle_radians: int):
	# Assuming 'force' is scaled already
	var knockback = SGFixed.vector2(ONE, 0) # RIGHT
	var weight_scale = SGFixed.div(weight, weight_knockback_scale) # Can adjust the second number to adjust weight scaling.
	knockback.rotate(-angle_radians) # -y is up
	knockback.imul(SGFixed.div(force, weight_scale))
	knockback.imul(knockback_multiplier)
	velocity = knockback

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
		knockbackForce = knockbackForce,
		knockbackAngle = knockbackAngle,
		airJump = airJump,
		isOnFloor = isOnFloor,
		usedJump = usedJump,
		frame = frame,
		damage = damage,
		takeDamage = takeDamage, # TODO: replace with HITSTUN state
		facingRight = facingRight,
		thrownHits = thrownHits,
		
		health = health,
		#max_health = max_health,
		burst = burst,
		meter = meter,
		#character_img = character_img, # TODO: is only loaded once, does not change, remove from state
		#character_name = character_name, # TODO: is only loaded once, does not change, remove from state
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
	knockbackForce = loadState['knockbackForce']
	knockbackAngle = loadState['knockbackAngle']
	airJump = loadState['airJump']
	usedJump = loadState['usedJump']
	isOnFloor = loadState['isOnFloor']

	health = loadState['health']
	damage = loadState['damage']
	takeDamage = loadState['takeDamage'] # TODO: replace with HITSTUN state
	facingRight = loadState['facingRight']
	frame = loadState['frame']
	thrownHits = loadState['thrownHits']
	
	health = loadState['health']
	#max_health = loadState['max_health']
	burst = loadState['burst']
	meter = loadState['meter']
	#character_img = loadState['character_img'] # TODO: is only loaded once, does not change, remove from state
	#character_name = loadState['character_name'] # TODO: is only loaded once, does not change, remove from state
	num_lives = num_lives
	
	sync_to_physics_engine()


func _interpolate_state(old_state: Dictionary, new_state: Dictionary, player_weight: float) -> void:
	fixed_position = old_state['fixed_position'].lerp(new_state['fixed_position'], player_weight)
