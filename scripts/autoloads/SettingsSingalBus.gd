extends Node


signal window_mode_selected(index)
signal resolution_selected(index)
signal set_settings_dict(settings_dict)
signal load_settings_data(settings_dict)


func emit_set_settings_dict(settings_dict: Dictionary) -> void:
	emit_signal("set_settings_dict", settings_dict)


func emit_window_mode_selected(index: int) -> void:
	emit_signal("window_mode_selected", index)


func emit_resolution_selected(index: int) -> void:
	emit_signal("resolution_selected", index)


func emit_load_settings_data(settings_dict: Dictionary) -> void:
	emit_signal("load_settings_data", settings_dict)
