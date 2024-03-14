extends Hitbox

@onready var despawn_timer = $DespawnTimer
@onready var collision_shape = $Hitbox_Shape

# FUTURE:
# hitbox.shape.size = Vector2(width, height)


func _network_spawn(data: Dictionary) -> void:
	damage = data['damage']
	attacking_player = data['attacking_player']
	if attacking_player == "ClientPlayer":
		set_collision_mask_bit(2, false)
		set_collision_mask_bit(1, true)
	hitboxShapes = data['hitboxShapes']
	var timer = 0
	for shapeItem in hitboxShapes:
		timer += shapeItem["ticks"]
	despawn_timer.wait_ticks = timer
	despawn_timer.start()

func _network_despawn() -> void:
	despawn_timer.stop()

func _network_process(_input: Dictionary) -> void:
	var timer = 0
	for shapeItem in hitboxShapes:
		if get_parent().get_parent().frame > shapeItem["ticks"] + timer:
			timer += shapeItem["ticks"]
		else:
			var rectangle_shape = SGRectangleShape2D.new()
			rectangle_shape._set_extents_x(shapeItem["width"] * SGFixed.HALF)
			rectangle_shape._set_extents_y(shapeItem["height"] * SGFixed.HALF)
			# rectangle_shape.set_extents(SGFixedVector2(shapeItem["width"], shapeItem["height"])) 
			# ^ This doesnt work bc SGFixedVector2 isn't in the SGArea2D class for some reason?
			# Yeah idk I looked through literally all the code for sgarea2d and apparently it never needs fixedvector2 somehow
			$Hitbox_Shape.shape = rectangle_shape
			# print("HERE ", shapeItem["width"], " ", shapeItem["height"], " ", get_parent().get_parent().frame)
			break

func _on_despawn_timer_timeout():
	SyncManager.despawn(self)

func _save_state() -> Dictionary:
	return {
		used = used,
		tick = tick
	}

func _load_state(loadState: Dictionary) -> void:
	used = loadState['used']
	tick = loadState['tick']
	sync_to_physics_engine()
