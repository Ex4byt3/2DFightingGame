extends GameOption


# Onready variable for the window mode options button
@onready var window_mode_options = $HBoxContainer/WindowModeOptions

## Define an array for the window options
#const WINDOW_MODE_ARRAY: Array = [
#	"     Bordered Window",
#	"     Borderless Window",
#	"     Fullscreen",
#	"     Borderless Fullscreen",
#]
var window_mode = SettingsData.WINDOW_MODE_ARRAY

# Called when the node enters the scene tree for the first time.
func _ready():
	set_data("Window Mode", "Display")
	handle_connecting_signals()
	add_window_mode_items()
	load_window_mode()


# Connect signals used in this scene
func handle_connecting_signals() -> void:
	window_mode_options.connect("item_selected", Callable(self, "_on_window_mode_selected"))


# Add the items in the resolutions dictionary to the dropdown
func add_window_mode_items() -> void:
	for mode in window_mode:
		window_mode_options.add_item(mode)


# When a resolution is selected, change the window size to match
func _on_window_mode_selected(index: int) -> void:
	MenuSignalBus.emit_window_mode_selected(index)
#	match index:
#		0: # bordered window
#			OS.set_borderless_window(false)
#			OS.set_window_fullscreen(false)
#		1: # borderless window
#			OS.set_borderless_window(true)
#			OS.set_window_fullscreen(false)
#		2: # fullscreen
#			OS.set_borderless_window(false)
#			OS.set_window_fullscreen(true)
#		3: # borderless fullscreen
#			OS.set_borderless_window(true)
#			OS.set_window_fullscreen(true)


# Load and apply the saved resolution settings
# This occurs at game launch
func load_window_mode() -> void:
	var window_mode_index = SettingsData.window_mode_index
	window_mode_options.select(window_mode_index)
#	_on_window_mode_selected(window_mode_index)
