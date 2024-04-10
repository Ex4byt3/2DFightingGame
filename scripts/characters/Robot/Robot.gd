extends Character

# Our nodes that we use in the scene
@onready var animation = $AnimatedSprite2D/FixedAnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var wallR = get_parent().get_node("WallStaticBody_R")
@onready var wallL = get_parent().get_node("WallStaticBody_L")
@onready var ceiling = get_parent().get_node("CeilingStaticBody")
@onready var opponent = get_parent().get_node("ClientPlayer") if self.name == "ServerPlayer" else get_parent().get_node("ServerPlayer")

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
var advancingLowSpeed = 24 # TODO: current pushboxes break this move kinda sorta

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
var baseMeterRate = 300
var meter_frame_counter = 0 
var meter_frame_rate = 60
var totalGameFrames = 10800
var currentGameFrame = 0
var armg = 1
# TODO: other forms of meter gain

# Character attack attributes
var thrownHits = 0
var hitstunFrames = 0
var blockstunFrames = 0
var lastSlideCollision = null
var changedVelocity = false

var last_dash_on_floor = false
var dash_meter_cost = 1

var reset_round = false
var hit_landed = 0

# Valid motion inputs for the character, listed in priority
const motion_inputs = {
	# 623: 'DP',
	236: 'QCF',
	214: 'QCB'
}

# Local character data
var robot_img = preload("res://assets/menu/images/RoboPort.png")
var robot_name = "Robot"
var robot_max_health = 10000


# Sound Effect Preloads
const sounds := {
	hit0 = preload("res://assets/sound/sound effects/shots/fuzzyGunShot-dur2Short-pitch1Low.wav"),
	hit1 = preload("res://assets/sound/sound effects/shots/fuzzyGunShot-dur2Short-pitch2Medium.wav"),
	hit2 = preload("res://assets/sound/sound effects/shots/fuzzyGunShot-dur2Short-pitch3High.wav"),
	hitI = {
		# The following is an example of what settings can be set for the audio:
		# World position to use positional audio.
		#position = global_position,
		# Change the volume (default = 0.0).
		#volume_db = 1.5,
		# Change the pitch (default = 1.0).
		#pitch_scale = 0.5,
		# Change the audio bus (default = 'Sound').
		#bus = 'Music',
	},
	# neutral_heavy = preload("res://assets/sound/sound effects/shots/laserShot-dur3Medium-pitch1Low.wav"), # TODO: play at the wrong time, at start instead of at active frames
	# neutral_heavyI = {},
	# neutral_impact = preload("res://assets/sound/sound effects/shots/laserShot-dur3Medium-pitch1Low.wav"),
	# neutral_impactI = {},
}

# Calling all onready functions
func _ready():
	animation.play("Idle")
	set_up_direction(SGFixed.vector2(0, -ONE))
	_handle_connecting_signals()
	_scale_to_fixed()
	_rotate_client_player()
	_init_character_data(robot_img, robot_name, robot_max_health)
	hurtBox.get_node("MainShape").shape = SGRectangleShape2D.new()
	hurtBox.get_node("MainShape").shape.set_extents(SGFixed.vector2(4487098, 6750123)) # default hurtbox size
	hurtBox.get_node("SecondaryShape").shape = SGRectangleShape2D.new()
	hurtBox.get_node("SecondaryShape").shape.set_extents(SGFixed.vector2(0, 0)) # secondary hurtbox for attacks that are not disjointed
	hitbox.get_node("MainShape").shape = SGRectangleShape2D.new()
	hitbox.get_node("MainShape").shape.set_extents(SGFixed.vector2(0, 0)) # default hitbox size
	if self.name == "ServerPlayer":
		opponent = get_parent().get_node("ClientPlayer")
	else:
		opponent = get_parent().get_node("ServerPlayer")
	

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
	advancingLowSpeed *= ONE

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
		hitbox.set_collision_layer_bit(2, false)
		hitbox.set_collision_layer_bit(1, true)

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
	return input

func get_input_vector():
	var vector = SGFixed.vector2(0, 0)
	vector.y = vector.y + 1 if input & Buttons.up else vector.y
	vector.y = vector.y - 1 if input & Buttons.down else vector.y
	vector.x = vector.x - 1 if input & Buttons.left else vector.x
	vector.x = vector.x + 1 if input & Buttons.right else vector.x
	return vector

func _game_process(input: int) -> int:
	
	if self.name == "ServerPlayer":
		opponent = get_parent().get_node("ClientPlayer")
	else:
		opponent = get_parent().get_node("ServerPlayer")
	
	# Deal with meter
	_meter_func()
	
	# Transition state and calculate velocity off of this logic
	# input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))\
	input_vector = get_input_vector()
	stateMachine.transition_state(input)
	
	# Update position based off of velocity
	# Also update collision values
	wallBounceVelocity.x = velocity.x
	wallBounceVelocity.y = velocity.y
	move_and_slide()
	_slide_collision()
	
	# Update collision booleans, does not work if called before move_and_slide, works if called after though
	isOnFloor = is_on_floor()
	isOnCeiling = is_on_ceiling()
	hitstopBuffer = 0 # hitstop buffer only lives for 1 game process
	
	# Resetting round variables
	if reset_round:
		_reset_round()
	
	return hitstop

func _slide_collision() -> void:
	lastSlideCollision = get_last_slide_collision()
	isOnWallR = false
	isOnWallL = false
	changedVelocity = false
	
	if lastSlideCollision != null:
		if lastSlideCollision.get_collider() == wallR:
			isOnWallR = true
		elif lastSlideCollision.get_collider() == wallL:
			isOnWallL = true

func increase_meter_over_time() -> void:
	#var time_multiplier = 1.0 + (1.0 - current_time / total_game_time)
	if meter_frame_counter >= meter_frame_rate:
		var remainingFrames = totalGameFrames - currentGameFrame
		#print("", remainingFrames)
		var elapsedFrames = currentGameFrame
		var time_multiplier = max(1, 100 * (totalGameFrames - remainingFrames) / totalGameFrames)
		var adjustedMeterRate = baseMeterRate + (baseMeterRate * time_multiplier) / 100
		# print(adjustedMeterRate)
		increase_meter(adjustedMeterRate)
		meter_frame_counter = 0
		#print("Meter increased over time", adjustedMeterRate)
	else:
		meter_frame_counter += 1

func _meter_func() -> void:
	MenuSignalBus.emit_update_meter_charge(meterCharge, self.name)
	MenuSignalBus.emit_update_meter_val(meterVal, self.name)
	currentGameFrame += 1
	
	if meterVal < 9:
		increase_meter_over_time()
		if hit_landed > 0:
			increase_meter(hit_landed * 2)
	if hit_landed > 0:
			hit_landed = 0
	
	while meterCharge >= meterValRate:
		meterVal += 1
		meterCharge -= meterValRate

func _reset_round() -> void:
	animation.play("Idle")
	
	meterVal += armg
	armg = 1
	
	if meterVal >= 9:
		meterCharge = 0
	
	if self.name == "ServerPlayer":
		facingRight = true
		fixed_position.x = 988 * ONE
		fixed_position.y = 1299 * ONE
	else:
		facingRight = false
		fixed_position.x = 1515 * ONE
		fixed_position.y = 1299 * ONE
		
	#is_disabled = true
	reset_round = false
	
	
######################
# ROLLBACK FUNCTIONS #
######################
func _save_state() -> Dictionary:
	var control_buffer = []
	for item in controlBuffer:
		control_buffer.append(item.duplicate())
	var input_buffer_array = []
	for item in inputBufferArray:
		input_buffer_array.append(item)
	# var input_history = []
	# for item in inputHistory:
	# 	input_history.append(item)
	return {
		input = input,
		inputBuffer = inputBuffer,
		bufferIdx = bufferIdx,
		inputBufferArray = input_buffer_array,
		playerState = stateMachine.state,
		controlBuffer = control_buffer,
		pressed = pressed,
		
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
		meterCharge = meterCharge,
		meterVal = meterVal,
		num_lives = num_lives,
		
		meter_frame_counter = meter_frame_counter,
		meter_frame_rate = meter_frame_rate,
		currentGameFrame = currentGameFrame,

		hitstop = hitstop,
		knockbackMultiplier = knockbackMultiplier,
		hitstunMultiplier = hitstunMultiplier,

		hitstopBuffer = hitstopBuffer,
		
		last_dash_on_floor = last_dash_on_floor,
		dash_meter_cost = dash_meter_cost,
		reset_round = reset_round,
		armg = armg,
		
		is_dead = is_dead,
		is_disabled = is_disabled,

		# held = held_,
		hit_landed = hit_landed,
		# inputHistory = input_history,
		# inputHistoryIdx = inputHistoryIdx
	}

func _load_state(loadState: Dictionary) -> void:
	input = loadState['input']
	inputBuffer = loadState['inputBuffer']
	inputBufferArray = []
	bufferIdx = loadState['bufferIdx']
	for item in loadState['inputBufferArray']:
		inputBufferArray.append(item)
	# held = []
	# for item in loadState['held']:
	# 	held.append(item)
	stateMachine.state = loadState['playerState']
	controlBuffer = []
	for item in loadState['controlBuffer']:
		controlBuffer.append(item.duplicate())
	pressed = loadState['pressed']
	
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

	#health = loadState['health']
	facingRight = loadState['facingRight']
	frame = loadState['frame']
	thrownHits = loadState['thrownHits']
	hitstunFrames = loadState['hitstunFrames']
	blockstunFrames = loadState['blockstunFrames']
	prevVelocity.x = loadState['prevVelocity_x']
	prevVelocity.y = loadState['prevVelocity_y']
	
	health = loadState['health']
	burst = loadState['burst']
	meterCharge = loadState['meterCharge']
	meterVal = loadState['meterVal']
	num_lives = loadState['num_lives']

	meter_frame_counter = loadState["meter_frame_counter"]
	meter_frame_rate = loadState["meter_frame_rate"]
	currentGameFrame = loadState['currentGameFrame']

	hitstop = loadState['hitstop']
	knockbackMultiplier = loadState['knockbackMultiplier']
	hitstunMultiplier = loadState['hitstunMultiplier']

	hitstopBuffer = loadState['hitstopBuffer']
	last_dash_on_floor = loadState['last_dash_on_floor']
	dash_meter_cost = loadState['dash_meter_cost']
	reset_round = loadState['reset_round']
	armg = loadState['armg']
	
	is_dead = loadState['is_dead']
	is_disabled = loadState['is_disabled']
	hit_landed = loadState['hit_landed']

	# inputHistory = []
	# for item in loadState['inputHistory']:
	# 	inputHistory.append(item)
	# inputHistoryIdx = loadState['inputHistoryIdx']
	
	sync_to_physics_engine()
	
	MenuSignalBus.emit_update_health(health, self.name)
	MenuSignalBus.emit_update_lives(num_lives, self.name)

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, player_weight: float) -> void:
	fixed_position = old_state['fixed_position'].lerp(new_state['fixed_position'], player_weight)
