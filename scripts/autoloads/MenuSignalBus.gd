extends Node

# Signals for changing the currently visible menu
signal setup_menu
signal toggle_settings_visibility
signal start_match
signal leave_match
signal change_screen(current_screen, new_screen, is_backout)
signal change_menu(menu)

# Signals for the settings menu
signal window_mode_selected(index)
signal resolution_selected(index)
signal set_settings_dict(settings_dict)
signal load_settings_data(settings_dict)

# Signals for gameplay ui
signal load_ui(ui_settings)
signal update_debug(debug_data)
signal update_input_buffer(input_data)
signal update_debug_visibility(button_checked)

# Signals for slinky buttons
signal set_buttons_inactive
signal set_buttons_active
signal reset_buttons
signal mouse_entered_slinky(button_name)
signal mouse_exited_slinky(button_name)


##########################################################
# Emit functions for changing the currently visible menu #
##########################################################
func emit_setup_menu() -> void:
	emit_signal("setup_menu")

func emit_toggle_settings_visibility() -> void:
	emit_signal("toggle_settings_visibility")

func emit_start_match() -> void:
	emit_signal("start_match")

func emit_leave_match() -> void:
	emit_signal("leave_match")

func emit_change_screen(current_screen, new_screen, is_backout: bool) -> void:
	emit_signal("change_screen", current_screen, new_screen, is_backout)

func emit_change_menu(menu: String) -> void:
	emit_signal("change_menu", menu)


###############################
# Emit functions for settings #
###############################

func emit_set_settings_dict(settings_dict: Dictionary) -> void:
	emit_signal("set_settings_dict", settings_dict)

func emit_window_mode_selected(index: int) -> void:
	emit_signal("window_mode_selected", index)

func emit_resolution_selected(index: int) -> void:
	emit_signal("resolution_selected", index)

func emit_load_settings_data(settings_dict: Dictionary) -> void:
	emit_signal("load_settings_data", settings_dict)


###############################
# Emit functions for gameplay ui #
###############################

func emit_load_ui(ui_settings: Dictionary) -> void:
	emit_signal("load_ui_local", ui_settings)

func emit_update_debug(debug_data: Dictionary) -> void:
	emit_signal("update_debug", debug_data)

func emit_update_input_buffer(input_data: Dictionary) -> void:
	emit_signal("update_input_buffer", input_data)

func emit_update_debug_visibility(button_checked: bool) -> void:
	emit_signal("update_debug_visibility", button_checked)


#####################################
# Emit functions for slinky buttons #
#####################################

func emit_set_buttons_inactive() -> void:
	emit_signal("set_buttons_inactive")

func emit_set_buttons_active() -> void:
	emit_signal("set_buttons_active")

func emit_reset_buttons() -> void:
	emit_signal("reset_buttons")

func emit_mouse_entered_slinky(button_name: String) -> void:
	emit_signal("mouse_entered_slinky", button_name)

func emit_mouse_exited_slinky(button_name: String) -> void:
	emit_signal("mouse_exited_slinky", button_name)

#####################################
# Global menu functions #
#####################################

# Connect a signal and show the success code
func _connect_Signals(origin, target, connecting_signal: String, connecting_function: String) -> void:
	var signal_error: int = origin.connect(connecting_signal, Callable(target, connecting_function))
	if signal_error > OK:
		print("[" + str(target) + "] Connecting "+str(connecting_signal)+" to "+str(connecting_function)+" failed: "+str(signal_error))


func _change_Scene(current_scene, target_scene) -> void:
	var scene_change_error: int = current_scene.get_tree().change_scene_to_packed(target_scene)
	if scene_change_error > OK:
		print("[" + target_scene.get_file() + "] Scene change failed: "+str(scene_change_error))
