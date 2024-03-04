extends Control


# Preload the game scenes as packed scenes
# var steam_scene = preload("res://scenes/maps/SteamGame.tscn")
# var local_scene = preload("res://scenes/maps/LocalGame.tscn")
#var local_texture = preload("res://assets/menu/main/icons/active_local_icon.png")
var map_holder_scene = preload("res://scenes/maps/MapHolder.tscn")

# Onready var for primary buttons
@onready var local_tab = $MainPane/LocalTab
@onready var training_tab = $MainPane/TrainingTab
@onready var records_tab = $MainPane/RecordsTab
@onready var footer_notes = $MainPane/Footer/FooterNotes

@onready var online_button = $MainPane/MenuButtons/OnlineButton
@onready var local_button = $MainPane/MenuButtons/LocalButton
@onready var training_button = $MainPane/MenuButtons/TrainingButton
@onready var records_button = $MainPane/MenuButtons/RecordsButton


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()


# Connect to button signals
func handle_connecting_signals() -> void:
	# Connect signals for the menu's primary buttons
	MenuSignalBus._connect_Signals(online_button.base_button, self, "toggled", "on_online_button_toggled")
	MenuSignalBus._connect_Signals(local_button.base_button, self, "toggled", "on_local_button_toggled")
	MenuSignalBus._connect_Signals(training_button.base_button, self, "toggled", "on_training_button_toggled")
	MenuSignalBus._connect_Signals(records_button.base_button, self, "toggled", "on_records_button_toggled")
	
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "mouse_entered_slinky", "_change_footer_text")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "mouse_exited_slinky", "_change_footer_text")


func _change_footer_text(hovered_button: String) -> void:
	match hovered_button:
		"ONLINE":
			footer_notes.set_text("Start custom matches with players around the world!")
		"LOCAL":
			footer_notes.set_text("Play alone or with friends locally!")
		"TRAINING":
			footer_notes.set_text("Learn to play the game or practice your skills!")
		"RECORDS":
			footer_notes.set_text("Review your gameplay records and other information!")
		"DEFAULT":
			footer_notes.set_text("Welcome to Project Delta!")


#
func on_online_button_toggled(button_pressed):
	if button_pressed == true:
#		MenuSignalBus.emit_show_online_menu()
#		MenuSignalBus.emit_change_menu("ONLINE")
		MenuSignalBus.emit_change_screen(self, get_parent().menu_preloads.OnlineMenu, false)


#
func on_local_button_toggled(button_pressed):
	if button_pressed == true:
		NetworkGlobal.NETWORK_TYPE = 0
		GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
#		MenuSignalBus._change_Scene(self, map_holder_scene)
		MenuSignalBus.emit_start_match()
#		var scene_change_error: int = get_tree().change_scene_to(local_scene)


#
func on_training_button_toggled(button_pressed):
	if button_pressed == true:
		training_tab.visible = true
	else:
		training_tab.visible = false


#
func on_records_button_toggled(button_pressed):
	if button_pressed == true:
		records_tab.visible = true
	else:
		records_tab.visible = false

