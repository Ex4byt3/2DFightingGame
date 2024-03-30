extends Character

# Our nodes that we use in the scene
@onready var animation = $FixedAnimationPlayer
@onready var attackAnimationPlayer = $DebugAnimationPlayer
@onready var sprite = $Sprite
@onready var wallR = get_parent().get_node("WallStaticBody_R")
@onready var wallL = get_parent().get_node("WallStaticBody_L")
@onready var ceiling = get_parent().get_node("CeilingStaticBody")

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
var wallBounceThreshold = 20
var walkSpeed = 8
var walkAcceleration = 2
var crawlSpeed = 2
var crawlAcceleration = 1
var sprintSpeed = 20
var sprintAcceleration = 4
var sprintInputLeinency = 6

var slideJumpBoost = 0 # set in ready

var maxAirSpeed = 12
var airAcceleration = 1 # divisor

var knockdownVelocity = 40 # Velocity at which the player will enter knockdown when hitting the floor
var quickGetUpFrames = 30

var jumpSquatFrames = 3
var maxAirJump = 1
var airJump = 0
var shortHopForce = 8
var fullHopForce = 20
var airHopForce = 15
var maxFallSpeed = 20

var prevVelocity = SGFixed.vector2(0, 0)

# Character meter variables
var baseMeterRate = 10
var meter_frame_counter = 0 
var meter_frame_rate = 60
var totalGameFrames = 10800
var currentGameFrame = 0
# TODO: other forms of meter gain

# Character attack attributes
var thrownHits = 0
var hitstunFrames = 0
var blockstunFrames = 0
var lastSlideCollision = null
var changedVelocity = false

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
var martial_hero_max_health = 10000

# Calling all onready functions
func _ready():
	animation.play("Idle")
	set_up_direction(SGFixed.vector2(0, -ONE))
	_handle_connecting_signals()
	_scale_to_fixed()
	_rotate_client_player()
	_init_character_data(martial_hero_img, martial_hero_name, martial_hero_max_health)
	$HurtBox.get_node("SGCollisionShape2D").shape = SGRectangleShape2D.new()



## Connecting signals to our menu
#func _handle_connecting_signals() -> void:
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "apply_match_settings", "_apply_match_settings")
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "setup_round", "_setup_round")
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "start_round", "_start_round")


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
		hurtBox.set_collision_mask_bit(1, false)
		hurtBox.set_collision_mask_bit(2, true)

## Initializing the character data
#func _init_character_data() -> void:
	#character_img = martial_hero_img
	#character_name = martial_hero_name
	#max_health = martial_hero_max_health
	#health = max_health
	#
	#MenuSignalBus.emit_update_character_image(character_img, self.name)
	#MenuSignalBus.emit_update_character_name(character_name, self.name)
	#MenuSignalBus.emit_update_max_health(max_health, self.name)


# Network-related function
func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	# TODO: implement better input prediction
	if ticks_since_real_input > 2:
		input.erase("input_vector")
	return input

func _game_process(input: Dictionary) -> int:
	currentGameFrame += 1
	increase_meter_over_time() # This was currently not rollback safe, commented for rollback testing hitboxes
	
	# Transition state and calculate velocity off of this logic
	input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	stateMachine.transition_state(input)
	
	# Update position based off of velocity
	wallBounceVelocity.x = velocity.x
	wallBounceVelocity.y = velocity.y
	move_and_slide()
	lastSlideCollision = get_last_slide_collision()
	
	if lastSlideCollision != null:
		if lastSlideCollision.get_collider() == wallR:
			isOnWallR = true
			isOnWallL = false
		elif lastSlideCollision.get_collider() == wallL:
			isOnWallL = true
			isOnWallR = false
		else:
			isOnWallR = false
			isOnWallL = false
			changedVelocity = false
	else:
		isOnWallR = false
		isOnWallL = false
		changedVelocity = false
	
	# Update collision booleans, does not work if called before move_and_slide, works if called after though
	isOnFloor = is_on_floor()
	isOnCeiling = is_on_ceiling()

	return hitstop

func increase_meter_over_time() -> void:
	#var time_multiplier = 1.0 + (1.0 - current_time / total_game_time)
	if meter_frame_counter >= meter_frame_rate:
		var remainingFrames = totalGameFrames - currentGameFrame
		#print("", remainingFrames)
		var elapsedFrames = currentGameFrame
		var time_multiplier = max(1, 100 * (totalGameFrames - remainingFrames) / totalGameFrames)
		var adjustedMeterRate = baseMeterRate + (baseMeterRate * time_multiplier) / 100
		increase_meter(adjustedMeterRate)
		meter_frame_counter = 0
		#print("Meter increased over time", adjustedMeterRate)
	else:
		meter_frame_counter += 1


######################
# ROLLBACK FUNCTIONS #
######################
func _save_state() -> Dictionary:
	var control_buffer = []
	for item in controlBuffer:
		control_buffer.append(item.duplicate())
	var pressed_ = []
	for item in pressed:
		pressed_.append(item)
	return {
		playerState = stateMachine.state,
		controlBuffer = control_buffer,
		pressed = pressed_,
		
		fixed_position_x = fixed_position.x,
		fixed_position_y = fixed_position.y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		changedVelocity = changedVelocity,

		blockMask = blockMask,

		dashVector_x = dashVector.x,
		dashVector_y = dashVector.y,
		airJump = airJump,
		isOnFloor = isOnFloor,
		isOnCeiling = isOnCeiling,
		isOnWallL = isOnWallL,
		isOnWallR = isOnWallR,
		wallBounceVelocity_x = wallBounceVelocity.x,
		wallBounceVelocity_y = wallBounceVelocity.y,
		frame = frame,
		facingRight = facingRight,
		thrownHits = thrownHits,
		hitstunFrames = hitstunFrames,
		blockstunFrames = blockstunFrames,
		prevVelocity_x = prevVelocity.x,
		prevVelocity_y = prevVelocity.y,
		
		health = health,
		burst = burst,
		meter = meter,
		num_lives = num_lives,
		
		meter_frame_counter = meter_frame_counter,
		meter_frame_rate = meter_frame_rate,
		currentGameFrame = currentGameFrame,

		hitstop = hitstop,
		knockbackMultiplier = knockbackMultiplier,
		hitstunMultiplier = hitstunMultiplier
	}

func _load_state(loadState: Dictionary) -> void:
	stateMachine.state = loadState['playerState']
	controlBuffer = []
	for item in loadState['controlBuffer']:
		controlBuffer.append(item.duplicate())
	pressed = []
	for item in loadState['pressed']:
		pressed.append(item)
	
	fixed_position.x = loadState['fixed_position_x']
	fixed_position.y = loadState['fixed_position_y']
	velocity.x = loadState['velocity_x']
	velocity.y = loadState['velocity_y']
	changedVelocity = loadState['changedVelocity']

	blockMask = loadState['blockMask']

	dashVector.x = loadState['dashVector_x']
	dashVector.y = loadState['dashVector_y']
	airJump = loadState['airJump']
	isOnFloor = loadState['isOnFloor']
	isOnCeiling = loadState['isOnCeiling']
	isOnWallL = loadState['isOnWallL']
	isOnWallR = loadState['isOnWallR']
	wallBounceVelocity.x = loadState['wallBounceVelocity_x']
	wallBounceVelocity.y = loadState['wallBounceVelocity_y']

	health = loadState['health']
	facingRight = loadState['facingRight']
	frame = loadState['frame']
	thrownHits = loadState['thrownHits']
	hitstunFrames = loadState['hitstunFrames']
	blockstunFrames = loadState['blockstunFrames']
	prevVelocity.x = loadState['prevVelocity_x']
	prevVelocity.y = loadState['prevVelocity_y']
	
	health = loadState['health']
	burst = loadState['burst']
	meter = loadState['meter']
	num_lives = num_lives

	meter_frame_counter = loadState.get("meter_frame_counter", meter_frame_counter) # Provides a default in case it's missing
	meter_frame_rate = loadState.get("meter_frame_rate", meter_frame_rate)
	currentGameFrame = loadState['currentGameFrame']

	hitstop = loadState['hitstop']
	knockbackMultiplier = loadState['knockbackMultiplier']
	hitstunMultiplier = loadState['hitstunMultiplier']
	
	MenuSignalBus.emit_update_health(health, self.name)
	sync_to_physics_engine()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, player_weight: float) -> void:
	fixed_position = old_state['fixed_position'].lerp(new_state['fixed_position'], player_weight)
