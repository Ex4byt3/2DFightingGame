extends GameOption


# Onready variable for the resolution options button
onready var resolution_options = $HBoxContainer/ResolutionOptions

## Define a dictionary for screen resolution options
#const RESOLUTION_DICTIONARY: Dictionary = {
#	"     640 x 360" : Vector2(640, 360),
#	"     853 x 480" : Vector2(853, 480),
#	"     1280 x 720" : Vector2(1280, 720),
#	"     1920 x 1080" : Vector2(1920, 1080),
#}
var resolutions = SettingsData.RESOLUTION_DICTIONARY

# Called when the node enters the scene tree for the first time.
func _ready():
	set_data("Window Resolution", "Display")
	_handle_connecting_signals()
	_add_resolution_items()
	_load_resolution()


# Connect signals used in this scene
func _handle_connecting_signals() -> void:
	resolution_options.connect("item_selected", self, "_on_resolution_selected")


# Add the items in the resolutions dictionary to the dropdown
func _add_resolution_items() -> void:
	for resolution in resolutions:
		resolution_options.add_item(resolution)


# When a resolution is selected, change the window size to match
func _on_resolution_selected(index: int) -> void:
	MenuSignalBus.emit_resolution_selected(index)
#	match index:
#		0: # 640 x 360
#			OS.set_window_size(RESOLUTION_DICTIONARY.values()[0])
#		1: # 853 x 480
#			OS.set_window_size(RESOLUTION_DICTIONARY.values()[1])
#		2: # 1280 x 720
#			OS.set_window_size(RESOLUTION_DICTIONARY.values()[2])
#		3: # 1920 x 1080
#			OS.set_window_size(RESOLUTION_DICTIONARY.values()[3])


# Load and apply the saved resolution settings
# This occurs at game launch
func _load_resolution() -> void:
	var resolution_index = SettingsData.resolution_index
	resolution_options.select(resolution_index)
#	_on_resolution_selected(resolution_index)
