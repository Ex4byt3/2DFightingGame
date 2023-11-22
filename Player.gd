extends SGKinematicBody2D

const Bomb = preload("res://Bomb.tscn")
const ONE = 65536 # 1 for fixed-point math
const GRAVITY = ONE / 4
const JUMP_FORCE = ONE * 10
const MAX_SPEED = ONE * 16
const ACCELERATION = MAX_SPEED / 2
const DECELERATION = MAX_SPEED / 2

onready var rng = $NetworkRandomNumberGenerator
onready var debugLabel = $DebugLabel

var vertical_speed := 0
var is_on_ground := false
var speed := 0
var teleporting := false
var input_prefix := "player1_"

# Character-specific mechanics (placeholders for now)
var character_specifics := {
	"air_dash_count": 0, # Number of air dashes available
	"dash_cancel_cost": 0, # Meter cost for dash cancelling
	# Add more character-specific mechanics here
}

# Custom input handling for advanced mechanics
func get_fixed_input_vector(negative_x: String, positive_x: String, negative_y: String, positive_y: String) -> SGFixedVector2:
	var input_vector = SGFixed.vector2(0, 0)
	if Input.is_action_pressed(negative_x):
		input_vector.x -= ONE
	if Input.is_action_pressed(positive_x):
		input_vector.x += ONE
	if Input.is_action_pressed(negative_y):
		input_vector.y -= ONE
	if Input.is_action_pressed(positive_y):
		input_vector.y += ONE
	return input_vector

func _get_local_input() -> Dictionary:
	var input_vector = get_fixed_input_vector(input_prefix + "left", input_prefix + "right", input_prefix + "up", input_prefix + "down")
	var input := {}
	if input_vector != SGFixed.vector2(0, 0):
		input["input_vector_x"] = input_vector.x
		input["input_vector_y"] = input_vector.y
	if Input.is_action_just_pressed(input_prefix + "bomb"):
		input["drop_bomb"] = true
	if Input.is_action_just_pressed(input_prefix + "teleport"):
		input["teleport"] = true
	if Input.is_action_just_pressed(input_prefix + "dash"):
		input["dash"] = true
	if Input.is_action_just_pressed(input_prefix + "dash_cancel"):
		input["dash_cancel"] = true
	# Add more inputs for attacks, specials, etc.
	return input

func _network_process(input: Dictionary) -> void:
	debugLabel.text = str(fixed_position.x / ONE) + ", " + str(fixed_position.y / ONE) + "\n" + str(speed / ONE)

	# Handle movement and gravity
	var input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	if input_vector.x != 0:
		speed = min(speed + ACCELERATION, MAX_SPEED)
	else:
		speed = max(speed - DECELERATION, 0)

	if not is_on_ground:
		vertical_speed += GRAVITY
	else:
		vertical_speed = 0

	# Jumping mechanics
	if is_on_ground and Input.is_action_just_pressed(input_prefix + "jump"):
		vertical_speed -= JUMP_FORCE
		is_on_ground = false

	# Apply movement
	fixed_position = fixed_position.add(input_vector.mul(speed))
	fixed_position.y += vertical_speed

	# Handle character-specific mechanics
	_handle_character_mechanics(input)

	# Bomb and teleportation logic
	if input.get("drop_bomb", false):
		SyncManager.spawn("Bomb", get_parent(), Bomb, { fixed_position_x = fixed_position.x, fixed_position_y = fixed_position.y })
	if input.get("teleport", false):
		fixed_position.x = (rng.randi() % 1024) * ONE
		fixed_position.y = (rng.randi() % 600) * ONE
		teleporting = true
	else:
		teleporting = false

# Character-specific mechanics handler
func _handle_character_mechanics(input: Dictionary) -> void:
	if input.get("dash", false) and character_specifics["air_dash_count"] > 0:
		# Implement air dash logic here
		pass
	if input.get("dash_cancel", false) and character_specifics["dash_cancel_cost"] > 0:
		# Implement dash cancel logic here
		pass
	# Add more character-specific mechanics handling here

func _save_state() -> Dictionary:
	return {
		"fixed_position_x": fixed_position.x,
		"fixed_position_y": fixed_position.y,
		"speed": speed,
		"teleporting": teleporting,
		# Save character-specific states here
	}

func _load_state(state: Dictionary) -> void:
	fixed_position.x = state["fixed_position_x"]
	fixed_position.y = state["fixed_position_y"]
	speed = state["speed"]
	teleporting = state["teleporting"]
	# Load character-specific states here
	sync_to_physics_engine()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	if old_state.get("teleporting", false) or new_state.get("teleporting", false):
		return
	fixed_position = old_state["fixed_position"].linear_interpolate(new_state["fixed_position"], weight)
