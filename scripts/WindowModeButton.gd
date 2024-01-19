extends Control


onready var window_mode_options = $ModeButton


# Define an array of strings for window options
const WINDOW_MODE_ARRAY = [
	"Fullscreen",
	"Bordered Window",
	"Borderless Window",
	"Borderless Fullscreen"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	add_window_mode_items()
	window_mode_options.connect("item_selected", self, "on_window_mode_selected")


func add_window_mode_items() -> void:
	for window_mode in WINDOW_MODE_ARRAY:
		window_mode_options.add_item(window_mode)


func on_window_mode_selected(index: int) -> void:
	SettingsSingalBus.emit_on_window_mode_selected(index)
	match index:
		0: # Fullscreen
			OS.set_borderless_window(false)
			OS.set_window_fullscreen(true)
		1: # Bordered Window
			OS.set_window_fullscreen(false)
			OS.set_borderless_window(false)
		2: # Borderless Window
			OS.set_borderless_window(true)
			OS.set_window_fullscreen(false)
		3: # Borderless Fullscreen
			OS.set_borderless_window(true)
			OS.set_window_fullscreen(true)
