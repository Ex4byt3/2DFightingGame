extends SGArea2D
@onready var collisionShape = $MainShape
@onready var player = get_parent().get_parent() # Name of attacking player (client/server)
@onready var map = player.get_parent()
@onready var opponent = map.get_node("ClientPlayer" if player.name == "ServerPlayer" else "ClientPlayer") # Name of attacked player (client/server)
@onready var sprite = $Sprite2D

var velocity := SGFixed.vector2(0, 0)
var lifespan := 0
var properties = {}
var used := false
var spawnDelay := 0

func _network_spawn(data: Dictionary) -> void:
	properties = data
	if player.facingRight:
		fixed_position_x = player.fixed_position_x + properties["startPos"][0]
		velocity.x = properties["velocity"][0]
	else:
		fixed_position_x = player.fixed_position_x - properties["startPos"][0]
		velocity.x = -properties["velocity"][0]
		sprite.flip_h = true
	fixed_position_y = player.fixed_position_y + properties["startPos"][1]
	velocity.y = properties["velocity"][1]
	collisionShape.shape = SGRectangleShape2D.new()
	collisionShape.shape._set_extents_x(properties["width"]) # shape is static
	collisionShape.shape._set_extents_y(properties["height"])
	lifespan = properties["lifespan"]
	spawnDelay = properties["spawnDelay"]
	sprite.texture = properties["sprite"]

	if player.name == "ClientPlayer":
		set_collision_layer_bit(2, false)
		set_collision_layer_bit(1, true)

func _game_process() -> void:
	if lifespan <= 0:
		SyncManager.despawn(self)
	lifespan -= 1
	fixed_position = fixed_position.add(velocity)
	sync_to_physics_engine()

func _save_state() -> Dictionary:
	return {
		properties = properties,
		width = collisionShape.shape._get_extents_x(),
		height = collisionShape.shape._get_extents_y(),
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		lifespan = lifespan,
	}

func _load_state(loadState: Dictionary) -> void:
	properties = loadState["properties"]
	collisionShape.shape._set_extents_x(loadState['width'])
	collisionShape.shape._set_extents_y(loadState['height'])
	fixed_position_x = loadState["fixed_position_x"]
	fixed_position_y = loadState["fixed_position_y"]
	velocity.x = loadState["velocity_x"]
	velocity.y = loadState["velocity_y"]
	lifespan = loadState["lifespan"]

	sync_to_physics_engine()