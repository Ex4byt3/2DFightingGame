extends CanvasLayer


onready var gameplay_ui = $GameplayUI
onready var debug_overlay = $DebugOverlay
onready var pause_menu = $PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	pass


func _load_ui_state(ui_settings: Dictionary) -> void:
	pass


func _input(event) -> void:
	if InputMap.event_is_action(event, "menu_back", true) and event.is_action_released("menu_back"):
		if not pause_menu.visible:
			pause_menu.visible = true
		else:
			pause_menu.visible = false


