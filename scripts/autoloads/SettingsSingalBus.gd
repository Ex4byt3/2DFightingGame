extends Node

# signals for changing the current menu
signal show_main_menu
signal show_settings_menu
signal show_online_menu
signal set_lobby_settings(lobby_settings_dict)

# Signals for the settings menu
signal window_mode_selected(index)
signal resolution_selected(index)
signal set_settings_dict(settings_dict)
signal load_settings_data(settings_dict)

func emit_show_main_menu() -> void:
	emit_signal("show_main_menu")


func emit_show_settings_menu() -> void:
	emit_signal("show_settings_menu")


func emit_show_online_menu() -> void:
	emit_signal("show_online_menu")


func emit_set_settings_dict(settings_dict: Dictionary) -> void:
	emit_signal("set_settings_dict", settings_dict)


func emit_window_mode_selected(index: int) -> void:
	emit_signal("window_mode_selected", index)


func emit_resolution_selected(index: int) -> void:
	emit_signal("resolution_selected", index)


func emit_load_settings_data(settings_dict: Dictionary) -> void:
	emit_signal("load_settings_data", settings_dict)


func emit_set_lobby_settings(lobby_settings_dict: Dictionary) -> void:
	emit_signal("set_lobby_settings", lobby_settings_dict)
