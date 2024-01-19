extends Control


onready var resolution_button = $ResolutionButton


const RESOLUTION_DICTIONARY = {
	"853 x 480" : Vector2(853, 480),
	"1280 x 720" : Vector2(1280, 720),
	"1920 x 1080" : Vector2(1920, 1080),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	add_resolution_items()	
	resolution_button.connect("item_selected", self, "on_resolution_selected")


func add_resolution_items() -> void:
	for resolution in RESOLUTION_DICTIONARY:
		resolution_button.add_item(resolution)


func on_resolution_selected(index: int) -> void:
	SettingsSingalBus.emit_on_resolution_selected(index)
	match index:
		0: # 853 x 480
			OS.set_window_size(RESOLUTION_DICTIONARY.values()[0])
		1: # 1280 x 720
			OS.set_window_size(RESOLUTION_DICTIONARY.values()[1])
		2: # 1920 x 1080
			OS.set_window_size(RESOLUTION_DICTIONARY.values()[2])
