extends SGArea2D

@onready var parent = get_parent()
func _network_process(input: Dictionary) -> void:
	fixed_position_x = parent.fixed_position_x
	fixed_position_y = parent.fixed_position_y
	sync_to_physics_engine()
	
func _save_state() -> Dictionary:
	return {
		fixed_position_x = fixed_position.x,
		fixed_position_y = fixed_position.y
	}
	
func _load_state(loadState: Dictionary) -> void:
	fixed_position.x = loadState['fixed_position_x']
	fixed_position.y = loadState['fixed_position_y']
	sync_to_physics_engine()
	
	
