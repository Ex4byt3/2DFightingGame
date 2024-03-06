extends VBoxContainer


@onready var displayed_time = $Header/Timer/TimerBackground/DisplayedTime
@onready var p1_health_bar = $Header/P1Info/HealthBar
@onready var p2_health_bar = $Header/P2Info/HealthBar
@onready var p1_burst_bar = $Header/P1Info/BurstBar
@onready var p2_burst_bar = $Header/P2Info/BurstBar
@onready var p1_meter_bar = $Footer/P1Meter/MeterBar
@onready var p2_meter_bar = $Footer/P2Meter/MeterBar

# TODO: Add steam name above character bar.
# The character's name should be shown on the health bar.

# Player variables
var p1_steam_persona: String # TODO: Get from lobby
var p2_steam_persona: String # ^ Same
var p1_character
var p2_character
var p1_character_name: String
var p2_character_name: String
var p1_health_max: int = 10000 # TODO: Grab from character specific script
var p2_health_max: int = 10000 # ^ Same

# Variables updated on process
var p1_health_val: int = p1_health_max
var p2_health_val: int
var p1_burst_val: int = 0
var p2_burst_val: int = 0
var p1_meter_val: int = 0
var p2_meter_val: int = 0

# Variables updated on signal call
var p1_num_lives: int = 3 # Grab from lobby
var p2_num_lives: int = 3 # Same

# Timer variables
var match_time: int = 180
var match_timer := Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	_init_ui()


func _process(delta):
	_update_ui()


##################################################
# ONREADY FUNCTIONS
##################################################
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(match_timer, self, "timeout", "_on_timeout")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_health", "_update_health")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_burst", "_update_burst")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_meter", "_update_meter")


func _init_ui() -> void:
	_init_timer()


func _init_player_health() -> void:
	p1_health_bar.max_value = p1_health_max 
	p2_health_bar.max_value = p2_health_max
	p1_health_bar.value = p1_health_max
	p2_health_bar.value = p2_health_max


func _init_player_burst() -> void:
	p1_burst_bar.value = p1_burst_val
	p2_burst_bar.value = p2_burst_val


##################################################
# PROCESS FUNCTIONS
##################################################
func _update_ui() -> void:
	_set_time()


func _update_player_data() -> void:
	p1_health_bar.value = p1_health_val
	p2_health_bar.value = p2_health_val


##################################################
# UPDATE FUNCTIONS
##################################################
func _update_health(hp_val: int, player: int) -> void:
	match player:
		1: # Player 1
			p1_health_val = hp_val
		2: # Player 2
			p2_health_val = hp_val
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")


func _update_burst(burst_val: int, player: int) -> void:
	match player:
		1: # Player 1
			p1_burst_val = burst_val
		2: # Player 2
			p2_burst_val = burst_val
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")


func _update_meter(meter_val: int, player: int) -> void:
	match player:
		1: # Player 1
			p1_meter_val = meter_val
		2: # Player 2
			p2_meter_val = meter_val
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")


##################################################
# TIMER FUNCTIONS
##################################################
func _init_timer() -> void:
	add_child(match_timer)
	match_timer.set_one_shot(true)
	match_timer.set_wait_time(match_time)
	match_timer.start()


func _set_time() -> void:
	var minutes: int = match_timer.time_left / 60
	var seconds: int = match_timer.time_left - 60 * minutes
	if seconds >= 10:
		displayed_time.set_text(str(minutes) + ":" + str(seconds))
	else:
		displayed_time.set_text(str(minutes) + ":0" + str(seconds))


func _on_timeout() -> void:
	pass


##################################################
# TWEEN FUNCTIONS
##################################################
func _animate_health() -> void:
	var tween = create_tween()

