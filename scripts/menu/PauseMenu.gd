extends Control


onready var lobby_quit_button = $MainPane/Contents/LobbyQuitButton
onready var debug_toggle = $MainPane/Contents/DebugToggle

export var return_screen: String = "Lobby"


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _load_menu_settings() -> void:
	lobby_quit_button.set_text("Return to " + return_screen)


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(lobby_quit_button, self, "button_up", "_quit_to_lobby")
	MenuSignalBus._connect_Signals(debug_toggle, self, "toggled", "_on_debug_toggled")


func _quit_to_lobby() -> void:
	pass


func _on_debug_toggled(button_checked: bool) -> void:
	print(button_checked)
	MenuSignalBus.emit_update_debug_visibility(button_checked)
