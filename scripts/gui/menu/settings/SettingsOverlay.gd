extends Control


@onready var searchbar = $PanelContainer/MarginContainer/VBoxContainer/HeaderBox/Searchbar
@onready var setting_checks = $PanelContainer/MarginContainer/VBoxContainer/MainBox/LeftEdge/MarginContainer/SettingChecks
@onready var settings_box = $PanelContainer/MarginContainer/VBoxContainer/MainBox/SettingsBox
@onready var graphics_section = $PanelContainer/MarginContainer/VBoxContainer/MainBox/SettingsBox/GraphicsSection
@onready var sound_section = $PanelContainer/MarginContainer/VBoxContainer/MainBox/SettingsBox/SoundSection
@onready var network_section = $PanelContainer/MarginContainer/VBoxContainer/MainBox/SettingsBox/NetworkSection
@onready var accessibility_section = $PanelContainer/MarginContainer/VBoxContainer/MainBox/SettingsBox/AccessibilitySection

@onready var music_slider = $PanelContainer/MarginContainer/VBoxContainer/MainBox/SettingsBox/SoundSection/MusicSlider/HBoxContainer/MusicSlider
@onready var effects_slider = $PanelContainer/MarginContainer/VBoxContainer/MainBox/SettingsBox/SoundSection/EffectsSlider/HBoxContainer/EffectsSlider

var sections: Dictionary = {
	"Graphics": graphics_section,
	"Sound": sound_section,
	"Network": network_section,
	"Accessibility": accessibility_section
}


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(searchbar, self, "text_changed", "_search_settings")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_section_visibility", "_update_section_visibility")
	music_slider.drag_ended.connect(_update_music_volume)
	effects_slider.drag_ended.connect(_update_effects_volume)


##################################################
# SETTINGS SEARCH FUNCTIONALITY
##################################################
func _update_section_visibility(section_title: String, is_pressed: bool) -> void:
	if is_pressed:
		sections.get(section_title).visible = true
	else:
		sections.get(section_title).visible = true


func _search_settings(search_text: String) -> void:
	for section in settings_box.get_children():
		for setting in section.get_children():
			if not setting.name == "SectionHeader":
				if contains_search_text(setting, search_text):
					setting.visible =true
				else:
					setting.visible = false


func contains_search_text(setting, search_text: String):
	if setting.option_name.findn(search_text) > -1 or not search_text:
		return true
	else:
		return false


func _update_music_volume(val_changed: bool) -> void:
	if val_changed:
		MenuSignalBus.emit_music_volume_changed(music_slider.value)


func _update_effects_volume(val_changed:bool) -> void:
	if val_changed:
		MenuSignalBus.emit_effects_volume_changed(effects_slider.value)
