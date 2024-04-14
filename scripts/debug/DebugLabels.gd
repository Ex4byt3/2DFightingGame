extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_debug", "_on_update_debug")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_input_buffer", "_on_update_input_buffer")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_debug_visibility", "_on_update_debug_visibility")


func _on_update_debug(debug_data: Dictionary) -> void:
	var current_label = self.get_node(debug_data.player_type + "DebugLabel")
	if debug_data.player_type == "ServerPlayer":
		current_label.text = "PLAYER ONE DEBUG:\nPOSITION: " + debug_data.pos_x + ", " + debug_data.pos_y + "\nVELOCITY: " + debug_data.velocity_x + ", " + debug_data.velocity_y + "\nINPUT VECTOR: " + debug_data.input_vector_x + ", " + debug_data.input_vector_y + "\nKB_MULT: " + debug_data.knockback_multiplier + "\nHS_MULT: " + debug_data.hitstun_multiplier + "\nSTATE: " + debug_data.state + "\nFRAME: " + debug_data.frame
	else:
		current_label.text = "PLAYER TWO DEBUG:\nPOSITION: " + debug_data.pos_x + ", " + debug_data.pos_y + "\nVELOCITY: " + debug_data.velocity_x + ", " + debug_data.velocity_y + "\nINPUT VECTOR: " + debug_data.input_vector_x + ", " + debug_data.input_vector_y + "\nKB_MULT: " + debug_data.knockback_multiplier + "\nHS_MULT: " + debug_data.hitstun_multiplier + "\nSTATE: " + debug_data.state + "\nFRAME: " + debug_data.frame


func _on_update_input_buffer(input_data: Dictionary) -> void:
	var current_label = self.get_node(input_data.player_type + "InputBuffer")
	if input_data.player_type == "ServerPlayer":
		current_label.text = "PLAYER ONE INPUT BUFFER:\n"
	else:
		current_label.text = "PLAYER TWO INPUT BUFFER:\n"
	
	for new_input in input_data.inputs:
		current_label.text += new_input[0] + " " + new_input[1] + " TICKS\n"


func _on_update_debug_visibility(button_checked) -> void:
	if not button_checked:
		self.visible = false
	else:
		self.visible = true
