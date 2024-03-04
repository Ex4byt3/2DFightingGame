extends Control


@onready var debug_toggle = $MainPane/Contents/DebugToggle
@onready var leave_match_button = $MainPane/Contents/LeaveMatchButton


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(debug_toggle, self, "toggled", "_on_debug_toggled")
	MenuSignalBus._connect_Signals(leave_match_button, self, "button_up", "_on_leave_match_button_pressed")

##################################################
# HELPER FUNCTIONS
##################################################
func _on_debug_toggled(button_checked: bool) -> void:
	MenuSignalBus.emit_update_debug_visibility(button_checked)


func _on_leave_match_button_pressed() -> void:
	MenuSignalBus.emit_leave_match()
