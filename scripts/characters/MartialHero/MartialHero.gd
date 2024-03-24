extends Character

# Our nodes that we use in the scene
@onready var animation = $NetworkAnimationPlayer
@onready var attackAnimationPlayer = $DebugAnimationPlayer
@onready var sprite = $Sprite

# SGFixed numbers
var ONE = SGFixed.ONE
var NEG_ONE = SGFixed.NEG_ONE

# Character motion attributes
var gravity = (ONE / 10) * 6 # divisor

var slideDecay = 2 # divisor

var dashSpeed = 30
var keptDashSpeed = 15
var dashWindup = 4
var dashDuration = 18
var dashVector = SGFixed.vector2(0, 0)

var groundDeceleration = 2

var walkSpeed = 4
var walkAcceleration = 2
var crawlSpeed = 2
var crawlAcceleration = 1
var sprintSpeed = 8
var sprintAcceleration = 4
var sprintInputLeinency = 6

var slideJumpBoost = 0 # set in ready

var maxAirSpeed = 6
var airAcceleration = 2 # divisor

var knockdownVelocity = 40 # Velocity at which the player will enter knockdown when hitting the floor
var quickGetUpFrames = 30

var jumpSquatFrames = 3
var maxAirJump = 1
var airJump = 0
var shortHopForce = 8
var fullHopForce = 20
var airHopForce = 15

var maxFallSpeed = 20

# Character meter variables
var meter_frame_counter = 0 
var meter_frame_rate = 60
# TODO: other forms of meter gain

# Character attack attributes
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
	# gravity *= ONE

	slideDecay *= ONE

	# dashSpeed = dashSpeed
	# keptDashSpeed = keptDashSpeed
	# dashWindup = dashWindup
	# dashDuration = dashDuration
	# dashVector = SGFixed.vector2(0, 0)

	groundDeceleration *= ONE

	walkSpeed *= ONE
	walkAcceleration *= ONE
	crawlSpeed *= ONE
	crawlAcceleration *= ONE
	sprintSpeed *= ONE
	sprintAcceleration *= ONE
	# sprintInputLeinency = sprintInputLeinency

	slideJumpBoost *= ONE

	maxAirSpeed *= ONE
	airAcceleration = ONE / airAcceleration

	knockdownVelocity *= ONE
	quickGetUpFrames *= ONE

	# jumpSquatFrames = 3
	# maxAirJump = 1
	# airJump = 0
	shortHopForce *= SGFixed.NEG_ONE
	fullHopForce *= SGFixed.NEG_ONE
	airHopForce *= SGFixed.NEG_ONE

	maxFallSpeed *= ONE

# Rotate the second player
func _rotate_client_player() -> void:
	if self.name == "ClientPlayer":
		facingRight = false
		# also flip hurtboxCollision layer and mask for client player
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
	# TODO: implement better input prediction
	if ticks_since_real_input > 2:
		input.erase("input_vector")
	return input

func _game_process(input: Dictionary) -> void:
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


######################
# ROLLBACK FUNCTIONS #
######################
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
		facingRight = facingRight,
		thrownHits = thrownHits,
		
		health = health,
		burst = burst,
		meter = meter,
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
	facingRight = loadState['facingRight']
	frame = loadState['frame']
	thrownHits = loadState['thrownHits']
	
	health = loadState['health']
	burst = loadState['burst']
	meter = loadState['meter']
	num_lives = num_lives
	
	MenuSignalBus.emit_update_health(health, self.name)
	sync_to_physics_engine()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, player_weight: float) -> void:
	fixed_position = old_state['fixed_position'].lerp(new_state['fixed_position'], player_weight)
