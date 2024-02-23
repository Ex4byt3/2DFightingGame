extends Character

# Character Attributes
var walkingSpeed = 4
var sprintingSpeed = 8
var sprintInputLeinency = 6
var airAcceleration : int = 0
var maxAirSpeed = 6
var gravity = 2
var airJumpMax = 0
var airJump = 0
var knockback_multiplier = 1
var weight = 100
var shortHopForce = 8
var fullHopForce = 16
var jumpSquatFrames = 4

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

func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	input.erase("drop_bomb")
	if ticks_since_real_input > 2:
		input.erase("input_vector")
	return input

func _network_process(input: Dictionary) -> void:
	# Transition state and calculate velocity off of this logic
	[velocity, frame] = stateMachine.transition_state(input, velocity, is_on_floor, frame)
	
	# Update position based off of velocity
	fixed_position = fixed_position.add(velocity)
	velocity = move_and_slide(velocity, SGFixed.vector2(0, -SGFixed.ONE))
	
	# Update is_on_floor, does not work if called before move_and_slide, works if called a though
	is_on_floor = is_on_floor() 
	
func _save_state() -> Dictionary:
	var control_buffer = []
	for item in controlBuffer:
		control_buffer.append(item.duplicate())
	return {
		control_buffer = control_buffer,
		fixed_position_x = fixed_position.x,
		fixed_position_y = fixed_position.y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		is_on_floor = is_on_floor,
		frame = frame
	}

func _load_state(state: Dictionary) -> void:
	controlBuffer = []
	for item in state['control_buffer']:
		controlBuffer.append(item.duplicate())
	fixed_position.x = state['fixed_position_x']
	fixed_position.y = state['fixed_position_y']
	velocity.x = state['velocity_x']
	velocity.y = state['velocity_y']
	is_on_floor = state['is_on_floor']
	frame = state['frame']
	sync_to_physics_engine()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	fixed_position = old_state['fixed_position'].linear_interpolate(new_state['fixed_position'], weight)
