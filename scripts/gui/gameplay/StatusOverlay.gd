extends VBoxContainer


@onready var heart = preload("res://scenes/gui/gameplay/Life.tscn")

@onready var p1_character_image = $Header/P1Info/CharacterImage
@onready var p1_character_name = $Header/P1Info/HealthHeader/CharacterName
@onready var p2_character_image = $Header/P2Info/CharacterImage
@onready var p2_character_name = $Header/P2Info/HealthHeader/CharacterName

@onready var displayed_time = $Header/Timer/TimerBackground/DisplayedTime
@onready var p1_health_bar = $Header/P1Info/HealthBar
@onready var p2_health_bar = $Header/P2Info/HealthBar
@onready var p1_burst_bar = $Header/P1Info/BurstBar
@onready var p2_burst_bar = $Header/P2Info/BurstBar
@onready var p1_meter_bar = $Footer/P1Meter/MeterBar
@onready var p2_meter_bar = $Footer/P2Meter/MeterBar
@onready var p1_lives_display = $Header/P1Info/HealthHeader/Lives
@onready var p2_lives_display = $Header/P2Info/HealthHeader/Lives

@onready var p1_current_health = $Header/P1Info/HealthBar/HealthOverlay/CurrentHealth
@onready var p2_current_health = $Header/P2Info/HealthBar/HealthOverlay/CurrentHealth

# TODO: Add steam name above character bar.
# The character's name should be shown on the health bar.

# Player variables
var p1_steam_persona: String # TODO: Get from lobby
var p2_steam_persona: String # ^ Same
var p1_health_max: int = 100 # TODO: Grab from character specific script
var p2_health_max: int = 100 # ^ Same

# Variables updated on process
var p1_health_val: int = 0
var p2_health_val: int = 0
var p1_burst_val: int = 0
var p2_burst_val: int = 0
var p1_meter_val: int = 0
var p2_meter_val: int = 0

# Variables updated on signal call
var p1_num_lives: int = 2 # Grab from lobby
var p2_num_lives: int = 2 # Same

# Timer variables
var match_time: int = 180
var match_timer := Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	#_init_ui()


func _process(delta):
	_update_ui()
	p1_current_health.set_text(str(p1_health_val) + "/" + str(p1_health_max))
	p2_current_health.set_text(str(p2_health_val) + "/" + str(p2_health_max))


##################################################
# ONREADY FUNCTIONS
##################################################
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(SyncManager, self, "sync_started", "_init_timer")
	MenuSignalBus._connect_Signals(match_timer, self, "timeout", "_on_timeout")
	
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "apply_match_settings", "_apply_match_settings")
	
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_health", "_update_health")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_burst", "_update_burst")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_meter", "_update_meter")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_lives", "_update_lives")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_max_health", "_update_max_health")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_character_image", "_update_character_image")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_character_name", "_update_character_name")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "life_lost", "_life_lost")


func _init_timer() -> void:
	add_child(match_timer)
	match_timer.set_one_shot(true)
	match_timer.set_wait_time(match_time)
	match_timer.start()


func _init_health() -> void:
	p1_health_bar.max_value = p1_health_max 
	p2_health_bar.max_value = p2_health_max
	p1_health_bar.value = p1_health_max 
	p2_health_bar.value = p2_health_max


func _apply_match_settings(match_settings: Dictionary) -> void:
	match_time = match_settings.time_limit


##################################################
# PROCESS FUNCTIONS
##################################################
func _update_ui() -> void:
	_set_time()


##################################################
# PLAYER STATUS FUNCTIONS
##################################################
func _set_player_health() -> void:
	p1_health_bar.value = p1_health_val
	p2_health_bar.value = p2_health_val


func _set_player_burst() -> void:
	p1_burst_bar.value = p1_burst_val
	p2_burst_bar.value = p2_burst_val


func _set_player_meter() -> void:
	p1_meter_bar.value = p1_meter_val
	p2_meter_bar.value = p2_meter_val


func _update_health(health_val: int, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_health_val = health_val
		"ClientPlayer": # Player 2
			p2_health_val = health_val
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")
	_set_player_health()


func _update_burst(burst_val: int, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_burst_val = burst_val
		"ClientPlayer": # Player 2
			p2_burst_val = burst_val
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")
	_set_player_burst()


func _update_meter(meter_val: int, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_meter_val = meter_val
		"ClientPlayer": # Player 2
			p2_meter_val = meter_val
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")
	_set_player_meter()


func _update_lives(num_lives: int, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_num_lives = num_lives
			var p1_num_lives_displayed = p1_lives_display.get_child_count()
			
			if p1_num_lives_displayed < p1_num_lives:
				for num in range(p1_num_lives_displayed, p1_num_lives):
					p1_lives_display.add_child(heart.instantiate())
			elif p1_num_lives_displayed > p1_num_lives:
				for num in range(p1_num_lives, p1_num_lives_displayed):
					p1_lives_display.get_child(0).queue_free()
		"ClientPlayer": # Player 2
			p2_num_lives = num_lives
			var p2_num_lives_displayed = p2_lives_display.get_child_count()
			
			if p2_num_lives_displayed < p2_num_lives:
				for num in range(p2_num_lives_displayed, p2_num_lives):
					p2_lives_display.add_child(heart.instantiate())
			elif p2_num_lives_displayed > p2_num_lives:
				for num in range(p2_num_lives, p2_num_lives_displayed):
					p2_lives_display.get_child(0).queue_free()
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")


func _update_max_health(health_val: int, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_health_max = health_val
			p1_health_val = p1_health_max
			p1_health_bar.max_value = p1_health_max
			p1_health_bar.value = p1_health_val
		"ClientPlayer": # Player 2
			p2_health_max = health_val
			p2_health_val = p2_health_max
			p2_health_bar.max_value = p2_health_max
			p2_health_bar.value = p2_health_val
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")


func _update_character_image(character_image: Texture2D, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_character_image.set_texture(character_image) 
		"ClientPlayer": # Player 2
			p2_character_image.set_texture(character_image) 
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")


func _update_character_name(character_name: String, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_character_name.set_text(character_name)
		"ClientPlayer": # Player 2
			p2_character_name.set_text(character_name)
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")


##################################################
# TIMER FUNCTIONS
##################################################
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

