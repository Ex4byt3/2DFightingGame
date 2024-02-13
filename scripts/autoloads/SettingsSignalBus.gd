extends Node

# Signals for changing the currently visible menu
signal show_main_menu
signal show_settings_menu
signal show_online_menu

# Signals for lobbies
signal set_lobby_settings(lobby_settings_dict)
signal update_lobby_pane(lobby_settings)

# Signals for the settings menu
#signal save_settings
signal window_mode_selected(index)
signal resolution_selected(index)
signal set_settings_dict(settings_dict)
signal load_settings_data(settings_dict)

# Signals for slinky buttons
signal set_buttons_inactive
signal set_buttons_active
signal reset_buttons


##########################################################
# Emit functions for changing the currently visible menu #
##########################################################

func emit_show_main_menu() -> void:
	emit_signal("show_main_menu")

func emit_show_settings_menu() -> void:
	emit_signal("show_settings_menu")

func emit_show_online_menu() -> void:
	emit_signal("show_online_menu")


##############################
# Emit functions for lobbies #
##############################

func emit_set_lobby_settings(lobby_settings_dict: Dictionary) -> void:
	emit_signal("set_lobby_settings", lobby_settings_dict)

func emit_update_lobby_pane(lobby_settings: Dictionary) -> void:
	emit_signal("update_lobby_pane", lobby_settings)


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


#####################################
# Emit functions for slinky buttons #
#####################################

func emit_set_buttons_inactive() -> void:
	emit_signal("set_buttons_inactive")

func emit_set_buttons_active() -> void:
	emit_signal("set_buttons_active")

func emit_reset_buttons() -> void:
	emit_signal("reset_buttons")


#####################################
# Global menu functions #
#####################################

# Connect a signal and show the success code
func _connect_Signals(origin, target, connecting_signal: String, connecting_function: String) -> void:
	var signal_error: int = origin.connect(connecting_signal, target, connecting_function)
	if signal_error > OK:
		print("[" + str(target) + "] Connecting "+str(connecting_signal)+" to "+str(connecting_function)+" failed: "+str(signal_error))


func _connect_Signals_Output(origin, target, connecting_signal: String, connecting_function: String, output) -> void:
	var signal_error: int = origin.connect(connecting_signal, target, connecting_function, [output])
	if signal_error > OK:
		print("[" + str(target) + "] Connecting "+str(connecting_signal)+" to "+str(connecting_function)+" failed: "+str(signal_error))

func _change_Scene(current_scene, target_scene) -> void:
	var scene_change_error: int = current_scene.get_tree().change_scene_to(target_scene)
	if scene_change_error > OK:
		print("[" + String.get_file() + "] Scene change failed: "+str(scene_change_error))
