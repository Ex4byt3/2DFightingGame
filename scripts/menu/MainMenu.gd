extends Control


# Preload the game scenes as packed scenes
var steam_scene = preload("res://scenes/maps/SteamGame.tscn")
var local_scene = preload("res://scenes/maps/LocalGame.tscn")
#var local_texture = preload("res://assets/menu/main/icons/active_local_icon.png")

# Onready var for primary buttons
onready var local_tab = $MainPane/LocalTab
onready var training_tab = $MainPane/TrainingTab
onready var records_tab = $MainPane/RecordsTab


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_connecting_signals()


# Connect to button signals
func handle_connecting_signals() -> void:
	# Connect signals for the menu's primary buttons
	SettingsSignalBus._connect_Signals($MainPane/MenuButtons/OnlineButton.base_button, self, "toggled", "on_online_button_toggled")
	SettingsSignalBus._connect_Signals($MainPane/MenuButtons/LocalButton.base_button, self, "toggled", "on_local_button_toggled")
	SettingsSignalBus._connect_Signals($MainPane/MenuButtons/TrainingButton.base_button, self, "toggled", "on_training_button_toggled")
	SettingsSignalBus._connect_Signals($MainPane/MenuButtons/RecordsButton.base_button, self, "toggled", "on_records_button_toggled")
#	$MainPane/MenuButtons/OnlineButton.base_button.connect("toggled", self, "on_online_button_toggled")
#	$MainPane/MenuButtons/LocalButton.base_button.connect("toggled", self, "on_local_button_toggled")
#	$MainPane/MenuButtons/TrainingButton.base_button.connect("toggled", self, "on_training_button_toggled")
#	$MainPane/MenuButtons/RecordsButton.base_button.connect("toggled", self, "on_records_button_toggled")


#
func on_online_button_toggled(button_pressed):
	if button_pressed == true:
		SettingsSignalBus.emit_show_online_menu()


#
func on_local_button_toggled(button_pressed):
	if button_pressed == true:
		NetworkGlobal.NETWORK_TYPE = 0
		GameSignalBus.emit_network_button_pressed(NetworkGlobal.NETWORK_TYPE)
		SettingsSignalBus._change_Scene(self, local_scene)
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

