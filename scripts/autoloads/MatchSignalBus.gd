extends Node

signal update_ui_visibility(button_checked)

signal apply_match_settings

signal match_start
signal match_stop
signal combat_start
signal combat_stop
signal setup_round
signal round_start
signal round_stop

signal banner_done

signal quit_to_menu
signal match_over


func emit_update_ui_visibility(button_checked: bool) -> void:
	emit_signal("update_ui_visibility", button_checked)

func emit_apply_match_settings() -> void:
	emit_signal("apply_match_settings")


func emit_combat_start() -> void:
	emit_signal("combat_start")

func emit_combat_stop() -> void:
	emit_signal("combat_stop")

func _emit_setup_round() -> void:
	emit_signal("setup_round")

func emit_round_start() -> void:
	emit_signal("round_start")

func emit_round_stop() -> void:
	emit_signal("round_stop")


func emit_banner_done() -> void:
	emit_signal("banner_done")


func emit_quit_to_menu() -> void:
	emit_signal("quit_to_menu")

func emit_match_over() -> void:
	emit_signal("match_over")
