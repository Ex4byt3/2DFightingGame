extends Control


@onready var text_display = $PanelContainer/MarginContainer/TextDisplay

signal delete_banner

var countdown_length: int = 4
var countdown_timer: Timer = Timer.new()
#var countdown_timer: NetworkTimer = NetworkTimer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	_start_countdown()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_update_timer()


func _handle_connecting_signals() -> void:
	countdown_timer.timeout.connect(_on_timeout)


func _update_timer() -> void:
	if countdown_timer.time_left >= 1:
		text_display.set_text(str(int(countdown_timer.time_left)))
	else:
		text_display.set_text("START")


func _start_countdown() -> void:
	add_child(countdown_timer)
	countdown_timer.set_one_shot(true)
	countdown_timer.set_wait_time(countdown_length)
	countdown_timer.start()


func _on_timeout() -> void:
	countdown_timer.stop()
	await get_tree().create_timer(1).timeout
	#MatchSignalBus.emit_round_start()
	emit_signal("delete_banner")
