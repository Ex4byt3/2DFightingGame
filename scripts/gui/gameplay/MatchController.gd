extends Node2D
class_name MatchController

# Onready variable to preload the MapHolder scene
@onready var map_holder = preload("res://scenes/maps/MapHolder.tscn")

# Variables for matches
var is_p1_ready: bool = false
var is_p2_ready: bool = false

var host_character_id: String = "MartialHero"
var client_character_id: String = "MartialHero"
var curr_round: int

var is_host: bool
var host_ready: bool
var client_ready: bool
var in_combat: bool

var selected_map: String = "TheBox"

# Dictionary containing for match settings
var match_settings: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


##################################################
# ONREADY FUNCTIONS
##################################################
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "create_match", "_create_match")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "leave_match", "_leave_match")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_match_settings", "_update_match_settings")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "life_lost", "_life_lost")


##################################################
# MATCH CONTROL FUNCTIONS
##################################################
func _create_match() -> void:
	_init_combat()


func _leave_match() -> void:
	SyncManager.stop()
	for child in get_children():
		child.queue_free()


func _update_match_settings(new_settings:Dictionary) -> void:
	match_settings = new_settings
	MenuSignalBus.emit_apply_match_settings(match_settings)


##################################################
# COMBAT CONTROL FUNCTIONS
##################################################
func _init_combat() -> void:
	var new_map_holder = map_holder.instantiate()
	add_child(new_map_holder)
	MenuSignalBus.emit_send_match_settings()


func _start_combat() -> void:
	pass


func _end_combat() -> void:
	pass


##################################################
# ROUND CONTROL FUNCTIONS
##################################################
func _start_new_round(player_id: String) -> void:
	print("\n[SYSTEM] " + player_id + " KO'd")
	print("[SYSTEM] Setting up new round...")
	MenuSignalBus.emit_setup_round()



