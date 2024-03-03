extends VBoxContainer


onready var displayed_time = $Header/Timer/TimerBackground/DisplayedTime

# Player variables
var p1_name: String
var p2_name: String
var p1_character
var p2_character
var p1_health: int = 100
var p2_health: int = 100
var p1_burst: int = 0
var p2_burst: int = 0
var p1_meter: int = 0
var p2_meter: int = 0
var p1_lives: int = 3
var p2_lives: int = 3

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


func _init_ui() -> void:
	_init_timer()

##################################################
# PROCESS FUNCTIONS
##################################################
func _update_ui() -> void:
	_set_time()


func _update_player_data() -> void:
	pass


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
