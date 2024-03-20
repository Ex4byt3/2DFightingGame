extends Hitbox

@onready var despawn_timer = $DespawnTimer
@onready var collision_shape = $Hitbox_Shape

# Spawns in the hitbox with all the data passed to it
func _network_spawn(data: Dictionary) -> void:
	# Our position in the map scene (with the players as sibling nodes)
	fixed_position_x = data['fixed_position_x']
	fixed_position_y = data['fixed_position_y']
	
	# The name of the attacking player (Client or Server)
	attacking_player = data['attacking_player']
	if attacking_player == "ClientPlayer":
		set_collision_layer_bit(2, false)
		set_collision_layer_bit(1, true)
		attacked_player = get_parent().get_node("ServerPlayer")
	else:
		attacked_player = get_parent().get_node("ClientPlayer")
	
	# Our hitbox shapes overtime and damage
	hitboxShapes = data['hitboxShapes']
	damage = data['damage']
	knockbackForce = data['knockbackForce']
	knockbackAngle = data['knockbackAngle']
	
	# Our countdown until we despawn
	var timer = 0
	for shapeItem in hitboxShapes:
		timer += shapeItem["ticks"]
	despawn_timer.wait_ticks = timer
	despawn_timer.start()

# Despawns the hitbox
func _network_despawn() -> void:
	get_parent().get_node(NodePath(attacking_player)).thrownHits -= 1

# Processing the hitbox
func _network_process(_input: Dictionary) -> void:
	# Update the position relative to the parent and sync it
	fixed_position_x = get_parent().get_node(NodePath(attacking_player)).fixed_position_x
	fixed_position_y = get_parent().get_node(NodePath(attacking_player)).fixed_position_y
	sync_to_physics_engine()
	
	# If there is an overlapping area that means its hit (can only overlap other player)
	if len(get_overlapping_areas()) > 0 and !used:
		# Determine who the other player is and update variables accordingly
		attacked_player.takeDamage = true
		attacked_player.damage = damage
		attacked_player.knockbackForce = knockbackForce
		if get_parent().get_node(NodePath(attacking_player)).facingRight == true:
			attacked_player.knockbackAngle = knockbackAngle
		else:
			attacked_player.knockbackAngle = knockbackAngle + SGFixed.PI_DIV_2
		used = true # This hitbox is now used and cannot hit the other player again
	
	# If this is set this mean the despawn is commencing, count up to this tick number and despawn once its hit
	if despawnAt < 1000:
		if tick >= despawnAt:
			SyncManager.despawn(self)
	else:
		# Otherwise find out what the current shape should be based on what frame of the attack we are on
		var timer = 0
		for shapeItem in hitboxShapes:
			if get_parent().get_node(NodePath(attacking_player)).frame > shapeItem["ticks"] + timer:
				timer += shapeItem["ticks"]
			else:
				# Change the shape based on which shape we are on
				collision_shape.shape._set_extents_x(shapeItem["width"] * SGFixed.HALF)
				collision_shape.shape._set_extents_y(shapeItem["height"] * SGFixed.HALF)
				break
	# Increment our tick coutner
	tick += 1

# The attack is no longer active, destroy it and despawn it 20 ticks later (to prevent rollback despawn issues)
func _on_despawn_timer_timeout():
	width = 0
	height = 0
	despawnAt = tick + 20
	despawn_timer.stop()

func _save_state() -> Dictionary:
	return {
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		width = collision_shape.shape._get_extents_x(),
		height = collision_shape.shape._get_extents_y(),
		used = used,
		tick = tick,
		despawnAt = despawnAt
	}

func _load_state(loadState: Dictionary) -> void:
	fixed_position_x = loadState['fixed_position_x']
	fixed_position_y = loadState['fixed_position_y']
	collision_shape.shape._set_extents_x(loadState['width'])
	collision_shape.shape._set_extents_y(loadState['height'])
	used = loadState['used']
	tick = loadState['tick']
	despawnAt = loadState['despawnAt']
	sync_to_physics_engine()
