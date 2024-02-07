extends Control

onready var selection_highlight = $SelectionHighlight
onready var info_pane = $InfoPane
onready var button_icon = $InfoPane/HBoxContainer/ButtonIcon
onready var button_label = $InfoPane/HBoxContainer/ButtonLabel
onready var button_highlight = $InfoPane/ButtonHighlight
onready var base_button = $BaseButton

# Custom properties
# DO NOT MODIFY IN CODE
export(bool) var is_active
export(bool) var is_selected
export(int) var collapse_width
export(int) var base_width
export(int) var expanded_width
export(int) var slide_offset
export(Texture) var icon_texture
export(String) var button_text

#
var resting_position = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	set_button_appearance()
	handle_connecting_signals()


func set_button_appearance() -> void:
	button_icon.set_texture(icon_texture)
	button_label.set_text(button_text)
	resting_position = self.rect_position.x


func handle_connecting_signals() -> void:
	base_button.connect("mouse_entered", self, "on_mouse_entered")
	base_button.connect("focus_entered", self, "on_mouse_entered")
	base_button.connect("mouse_exited", self, "on_mouse_exited")
	base_button.connect("focus_exited", self, "on_mouse_exited")
	base_button.connect("toggled", self, "on_button_toggled")
	SettingsSignalBus.connect("set_buttons_inactive", self, "set_inactive")
	SettingsSignalBus.connect("set_buttons_active", self, "set_active")
	SettingsSignalBus.connect("reset_buttons", self, "on_reset_buttons")


func on_mouse_entered() -> void:
	if is_active and not is_selected:
		button_expand_width()
		button_highlight.visible = true
		button_slide_right()


func on_mouse_exited() -> void:
	if not is_selected and is_active:
		button_revert_width()
		button_highlight.visible = false
		button_slide_left()


func on_button_toggled(button_pressed) -> void:
	if button_pressed:
		is_selected = true
		button_expand_width()
		SettingsSignalBus.emit_set_buttons_inactive()
	else:
		is_selected = false
		button_revert_width()
		button_slide_left()
		button_highlight.visible = false
		SettingsSignalBus.emit_set_buttons_active()


func _input(event) -> void:
	if InputMap.event_is_action(event, "menu_back", true):
		if not is_active:
			set_active()
		elif is_selected:
			base_button.pressed = false


func set_inactive() -> void:
	if not is_selected:
		is_active = false
		button_collapse_width()
		base_button.disabled = true
		selection_highlight.visible = false


func set_active() -> void:
	if not is_active:
		is_active = true
		button_revert_width()
		base_button.disabled = false
		selection_highlight.visible = true


func button_collapse_width() -> void:
	var tween = create_tween()
	tween.tween_property(info_pane, "rect_size", Vector2(collapse_width, 80), 0.05)


func button_revert_width() -> void:
	var tween = create_tween()
	tween.tween_property(info_pane, "rect_size", Vector2(base_width, 80), 0.05)


func button_expand_width() -> void:
	var tween = create_tween()
	tween.tween_property(info_pane, "rect_size", Vector2(expanded_width, 80), 0.05)


# Moves the button to the right by a number of pixels equal to the slide_offset value
func button_slide_right() -> void:
	var tween = create_tween()
	tween.tween_property(info_pane, "rect_position", Vector2(info_pane.rect_position.x + slide_offset, info_pane.rect_position.y), 0.05)


# Returns the button to its resting position
func button_slide_left() -> void:
	var tween = create_tween()
	tween.tween_property(info_pane, "rect_position", Vector2(resting_position, info_pane.rect_position.y), 0.05)