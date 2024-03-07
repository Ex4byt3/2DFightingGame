extends Node


# Signals for changing the currently visible menu
signal setup_menu
signal goto_previous_menu(menu)
signal change_screen(current_screen, new_screen, is_backout)
signal toggle_settings_visibility

# Signals for the settings menu
signal window_mode_selected(index)
signal resolution_selected(index)
signal set_settings_dict(settings_dict)
signal load_settings_data(settings_dict)

# Signals for matches
signal create_match
signal start_match
signal start_round
signal setup_round
signal leave_match
signal life_lost(player_id)
signal player_ready(player_id)

# Signals for match settings
signal send_match_settings
signal send_character_settings
signal send_required_match_data
signal receive_required_match_data(match_settings, character_settings)
signal apply_match_settings(match_settings)
signal apply_character_settings(character_settings)
signal set_match_settings_source(using_owner_settings)

# Signals for gameplay ui
signal load_ui(ui_settings)
signal update_debug(debug_data)
signal update_input_buffer(input_data)
signal update_debug_visibility(button_checked)

# Signals for status ui
signal update_health(health_val, player_id)
signal update_burst(burst_val, player_id)
signal update_meter(meter_val, player_id)
signal update_lives(num_lives, player_id)
signal update_max_health(health_val, player_id)
signal update_character_image(character_image, player_id)
signal update_character_name(character_name, player_id)

# Signals for slinky buttons
signal set_buttons_inactive
signal set_buttons_active
signal reset_buttons
signal mouse_entered_slinky(button_name)
signal mouse_exited_slinky(button_name)


##################################################
# EMIT FUNCTIONS FOR MANIPULATING THE GAME MENU
##################################################
func emit_setup_menu() -> void:
	emit_signal("setup_menu")

func emit_goto_previous_menu(menu: String) -> void:
	emit_signal("goto_previous_menu", menu)

func emit_change_screen(current_screen, new_screen, is_backout: bool) -> void:
	emit_signal("change_screen", current_screen, new_screen, is_backout)

func emit_toggle_settings_visibility() -> void:
	emit_signal("toggle_settings_visibility")


##################################################
# EMIT FUNCTIONS FOR SETTINGS
##################################################
func emit_set_settings_dict(settings_dict: Dictionary) -> void:
	emit_signal("set_settings_dict", settings_dict)

func emit_window_mode_selected(index: int) -> void:
	emit_signal("window_mode_selected", index)

func emit_resolution_selected(index: int) -> void:
	emit_signal("resolution_selected", index)

func emit_load_settings_data(settings_dict: Dictionary) -> void:
	emit_signal("load_settings_data", settings_dict)


##################################################
# EMIT FUNCTIONS FOR MATCHES
##################################################
func emit_create_match() -> void:
	emit_signal("create_match")

func emit_start_match() -> void:
	emit_signal("start_match")

func emit_start_round() -> void:
	emit_signal("start_round")

func emit_setup_round() -> void:
	emit_signal("setup_round")

func emit_leave_match() -> void:
	emit_signal("leave_match")

func emit_life_lost(player_id: String) -> void:
	emit_signal("life_lost", player_id)

func emit_player_ready(player_id: String) -> void:
	emit_signal("player_ready", player_id)


##################################################
# EMIT FUNCTIONS FOR MATCH SETTINGS
##################################################
func emit_send_match_settings() -> void:
	emit_signal("send_match_settings")
#
func emit_send_character_settings() -> void:
	emit_signal("send_character_settings")

func emit_send_required_match_data() -> void:
	emit_signal("send_required_match_data")

func emit_receive_required_match_data(match_settings: Dictionary, character_settings: Dictionary) -> void:
	emit_signal("receive_required_match_data", match_settings, character_settings)

func emit_apply_match_settings(match_settings: Dictionary) -> void:
	emit_signal("apply_match_settings", match_settings)

func emit_apply_character_settings(character_settings: Dictionary) -> void:
	emit_signal("apply_character_settings", character_settings)

func emit_set_match_settings_source(using_owner_settings: bool) -> void:
	emit_signal("set_match_settings_source", using_owner_settings)


##################################################
# EMIT FUNCTIONS FOR GAMEPLAY UI
##################################################
func emit_load_ui(ui_settings: Dictionary) -> void:
	emit_signal("load_ui_local", ui_settings)

func emit_update_debug(debug_data: Dictionary) -> void:
	emit_signal("update_debug", debug_data)

func emit_update_input_buffer(input_data: Dictionary) -> void:
	emit_signal("update_input_buffer", input_data)

func emit_update_debug_visibility(button_checked: bool) -> void:
	emit_signal("update_debug_visibility", button_checked)


##################################################
# EMIT FUNCTIONS FOR MATCH STATUS UI
##################################################
func emit_update_health(health_val: int, player_id: String) -> void:
	emit_signal("update_health", health_val, player_id)

func emit_update_burst(burst_val: int, player_id: String) -> void:
	emit_signal("update_burst", burst_val, player_id)

func emit_update_meter(meter_val: int, player_id: String) -> void:
	emit_signal("update_meter", meter_val, player_id)

func emit_update_lives(num_lives: int, player_id: String) -> void:
	emit_signal("update_lives", num_lives, player_id)

func emit_update_max_health(health_val: int, player_id: String) -> void:
	emit_signal("update_max_health", health_val, player_id)

func emit_update_character_image(character_image: Texture2D, player_id: String) -> void:
	emit_signal("update_character_image", character_image, player_id)

func emit_update_character_name(character_name: String, player_id: String) -> void:
	emit_signal("update_character_name", character_name, player_id)


##################################################
# EMIT FUNCTIONS FOR SLINKY BUTTONS
##################################################
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


##################################################
# GLOBAL FUNCTIONS
##################################################
# Connect a signal and show the success code
func _connect_Signals(origin, target, connecting_signal: String, connecting_function: String) -> void:
	var signal_error: int = origin.connect(connecting_signal, Callable(target, connecting_function))
	if signal_error > OK:
		print("[" + str(target) + "] Connecting "+str(connecting_signal)+" to "+str(connecting_function)+" failed: "+str(signal_error))


func _change_Scene(current_scene, target_scene) -> void:
	var scene_change_error: int = current_scene.get_tree().change_scene_to_packed(target_scene)
	if scene_change_error > OK:
		print("[" + target_scene.get_file() + "] Scene change failed: "+str(scene_change_error))
