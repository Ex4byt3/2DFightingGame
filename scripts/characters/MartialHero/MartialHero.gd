extends Character

@onready var animation = $NetworkAnimationPlayer
@onready var attackAnimationPlayer = $DebugAnimationPlayer
@onready var arrowSprite = $DebugSprite/DebugArrow
@onready var attackSprite = $DebugSprite/DebugAttack

var healthBar = null

# Character Attributes
var walkingSpeed = 4
var sprintingSpeed = 8
var sprintInputLeinency = 6
var airAcceleration : int = 0
var maxAirSpeed = 6
var gravity = 2
var airJumpMax = 1
var airJump = 0
var knockback_multiplier = 1
var weight = 100
var shortHopForce = 8
var fullHopForce = 16
var jumpSquatFrames = 4
var health = 10000
var damage = 0
var takeDamage = false
var player = 1

# valid motion inputs for the character, listed in priority
const motion_inputs = {
	623: 'DP',
	236: 'QCF',
	214: 'QCB'
}

func _ready():
	stateMachine.parent = self

	# Scale appropriate variables to fixed point numbers
	gravity = SGFixed.ONE / gravity
	maxAirSpeed *= SGFixed.ONE
	fullHopForce *= SGFixed.NEG_ONE
	shortHopForce *= SGFixed.NEG_ONE
	airAcceleration = SGFixed.ONE / 5

	# Turn player 2 around
	if self.name == "ClientPlayer":
		facingRight = false
		player = 2

func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	input.erase("drop_bomb")
	if ticks_since_real_input > 2:
		input.erase("input_vector")
	return input

func _network_process(input: Dictionary) -> void:
	MenuSignalBus.emit_update_health(health, player)
	
	# Transition state and calculate velocity off of this logic
	input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	stateMachine.transition_state(input)
	
	overlappingHitBoxes = $HurtBox.get_overlapping_areas()
	if len(overlappingHitBoxes) > 0:
		if overlappingHitBoxes[0].used == false and overlappingHitBoxes[0].attacking_player != self.name:
			takeDamage = true
			damage = overlappingHitBoxes[0].damage
			overlappingHitBoxes[0].used = true
	
	# Update position based off of velocity
	set_velocity(velocity)
	set_up_direction(SGFixed.vector2(0, -SGFixed.ONE))
	move_and_slide()
	velocity = velocity
	
	# Update is_on_floor, does not work if called before move_and_slide, works if called a though
	isOnFloor = is_on_floor() 
	
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
		airJump = airJump,
		isOnFloor = isOnFloor,
		usedJump = usedJump,
		frame = frame,
		health = health,
		damage = damage,
		takeDamage = takeDamage,
		facingRight = facingRight
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
	airJump = loadState['airJump']
	usedJump = loadState['usedJump']
	isOnFloor = loadState['isOnFloor']
	health = loadState['health']
	damage = loadState['damage']
	takeDamage = loadState['takeDamage']
	facingRight = loadState['facingRight']
	frame = loadState['frame']
	sync_to_physics_engine()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	fixed_position = old_state['fixed_position'].lerp(new_state['fixed_position'], weight)
