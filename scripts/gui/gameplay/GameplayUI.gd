extends Control


@onready var status_overlay = $StatusOverlay
@onready var debug_overlay = $DebugOverlay
@onready var pause_menu = $PauseMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	_load_ui_settings()


##################################################
# ONREADY FUNCTIONS
##################################################
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_debug_visibility", "_on_update_debug_visibility")


##################################################
# VISIBILITY FUNCTIONS
##################################################
func _on_update_debug_visibility(button_checked: bool) -> void:
	if button_checked:
		print("[SYSTEM] Showing debug overlay")
		debug_overlay.visible = true
	else:
		print("[SYSTEM] Hiding debug overlay")
		debug_overlay.visible = false

##################################################
# INPUT FUNCTIONS
##################################################
func _input(event) -> void:
	if event.is_action_released("ui_cancel"):
		if not pause_menu.visible:
			pause_menu.visible = true
		else:
			pause_menu.visible = false


##################################################
# ONREADY FUNCTIONS
##################################################
func _load_ui_settings() -> void:
	pass
