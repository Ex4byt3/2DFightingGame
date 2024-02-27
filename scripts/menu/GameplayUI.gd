extends Control


onready var current_time = $VBoxContainer/Header/Timer/TimerBackground/CurrentTime

var p1_name: String
var p2_name: String
var p1_character
var p2_character
var p1_health: int
var p2_health: int
var p1_burst: int
var p2_burst: int
var p1_meter: int
var p2_meter: int
var p1_lives: int
var p2_lives: int
var match_time: int = 180
var match_timer := Timer.new()



# Called when the node enters the scene tree for the first time.
func _ready():
	_init_ui()
	_handle_connecting_signals()


func _process(delta):
	_update_ui()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(match_timer, self, "timeout", "_on_timeout")


func _init_ui() -> void:
	_init_timer()


func _update_ui() -> void:
	_set_time()


func _init_timer() -> void:
	add_child(match_timer)
	match_timer.set_one_shot(true)
	match_timer.set_wait_time(match_time)
	match_timer.start()


func _set_time() -> void:
	var minutes: int = match_timer.time_left / 60
	var seconds: int = match_timer.time_left - 60 * minutes
	current_time.set_text(str(minutes) + ":" + str(seconds))


func _on_timeout() -> void:
	pass
