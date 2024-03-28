extends PanelContainer


@onready var character_icon = $MarginContainer/CharacterIcon

@export var icon: Texture
@export var character_id: String

var is_host: bool = true
var is_pressed: bool = false
var is_hovered: bool = false

var selected_by: Dictionary = {
	"Host": false,
	"Client": false
}

# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	_set_icon(icon)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_hovered:
		if is_host:
			selected_by.Host = not selected_by.Host
		else:
			selected_by.Client = not selected_by.Client
		MenuSignalBus.emit_character_selected(character_id, Steam.getSteamID())


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(self, self, "mouse_entered", "_on_mouse_entered")
	MenuSignalBus._connect_Signals(self, self, "mouse_exited", "_on_mouse_exited")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "character_selected", "_on_character_selected")


func _set_icon(icon: Texture) -> void:
	character_icon.set_texture(icon)


func _on_mouse_entered() -> void:
	is_hovered = true


func _on_mouse_exited() -> void:
	is_hovered = false

func _on_character_selected(new_id: String, new_selection: Dictionary) -> void:
	if not character_id == new_id:
		if selected_by.Host == true and new_selection.Host == true:
			selected_by.Host = false
		if selected_by.Client == true and new_selection.Client == true:
			selected_by.Client = false
		if not selected_by.Host and not selected_by.Client:
			is_pressed = false
	else:
		is_pressed = true


