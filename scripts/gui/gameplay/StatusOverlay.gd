extends VBoxContainer


@onready var heart = preload("res://scenes/gui/gameplay/Life.tscn")
@onready var countdown_banner = preload("res://scenes/gui/gameplay/CountdownBanner.tscn")
@onready var player_win_banner = preload("res://scenes/gui/gameplay/PlayerWinBanner.tscn")

@onready var center_pane = $CenterPane

@onready var p1_character_image = $Header/P1Info/CharacterImage
@onready var p1_character_name = $Header/P1Info/HealthHeader/CharacterName
@onready var p2_character_image = $Header/P2Info/CharacterImage
@onready var p2_character_name = $Header/P2Info/HealthHeader/CharacterName

@onready var p1_combo_bar = $Header/P1Info/ComboDamage
@onready var p2_combo_bar = $Header/P2Info/ComboDamage

@onready var displayed_time = $Header/Timer/TimerBackground/DisplayedTime
@onready var p1_health_bar = $Header/P1Info/HealthBar
@onready var p2_health_bar = $Header/P2Info/HealthBar
@onready var p1_burst_bar = $Header/P1Info/BurstBar
@onready var p2_burst_bar = $Header/P2Info/BurstBar
@onready var p1_meter_bar = $Footer/P1Meter/MeterBar
@onready var p2_meter_bar = $Footer/P2Meter/MeterBar
@onready var p1_meter_label = $Footer/P1Meter/MeterLabel
@onready var p2_meter_label = $Footer/P2Meter/MeterLabel
@onready var p1_lives_display = $Header/P1Info/HealthHeader/Lives
@onready var p2_lives_display = $Header/P2Info/HealthHeader/Lives

@onready var p1_current_health = $Header/P1Info/HealthBar/HealthOverlay/CurrentHealth
@onready var p2_current_health = $Header/P2Info/HealthBar/HealthOverlay/CurrentHealth

# TODO: Add steam name above character bar.
# The character's name should be shown on the health bar.

# Player variables
var p1_persona: String # TODO: Get from lobby
var p2_persona: String # ^ Same
var p1_health_max: int = 10000
var p2_health_max: int = 10000

# Variables updated on process
var p1_health_val: int = 10000
var p2_health_val: int = 10000
var p1_health_old: int = 10000
var p2_health_old: int = 10000
var p1_burst_val: int = 0
var p2_burst_val: int = 0

# Meter variables
var p1_meter_max: int = 0
var p2_meter_max: int = 0
var p1_meter_charge: int = 0
var p2_meter_charge: int = 0
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


func _process(_delta):
	_update_ui()
	


##################################################
# ONREADY FUNCTIONS
##################################################
func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(SyncManager, self, "sync_started", "_init_timer")
	MenuSignalBus._connect_Signals(match_timer, self, "timeout", "_on_timeout")
	
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "apply_match_settings", "_apply_match_settings")
	
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_health", "_update_health")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_burst", "_update_burst")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_meter_charge", "_update_meter_charge")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_meter_val", "_update_meter_val")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_lives", "_update_lives")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_max_health", "_update_max_health")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_character_image", "_update_character_image")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "update_character_name", "_update_character_name")
	#MenuSignalBus._connect_Signals(MenuSignalBus, self, "life_lost", "_life_lost")
	
	#MatchSignalBus.combat_start.connect(_spawn_countdown_banner.bind(true))
	MatchSignalBus.round_stop.connect(_spawn_round_stop_banners)
	MatchSignalBus.combat_stop.connect(_spawn_victor_banner)


func _init_timer() -> void:
	add_child(match_timer)
	match_timer.set_one_shot(true)
	match_timer.set_wait_time(match_time)
	match_timer.start()


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
func _update_health_diplay() -> void:
	p1_current_health.set_text(str(p1_health_val) + "/" + str(p1_health_max))
	p2_current_health.set_text(str(p2_health_val) + "/" + str(p2_health_max))


func _set_player_health() -> void:
	p1_health_bar.value = p1_health_val
	p2_health_bar.value = p2_health_val


func _set_player_burst() -> void:
	p1_burst_bar.value = p1_burst_val
	p2_burst_bar.value = p2_burst_val


func _set_player_meter_charge() -> void:
	p1_meter_bar.value = p1_meter_charge
	p2_meter_bar.value = p2_meter_charge

func _set_player_meter_val() -> void:
	p1_meter_label.text = (str)(p1_meter_val)
	p2_meter_label.text = (str)(p2_meter_val)

func _update_health(health_val: int, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_health_old = p1_health_val
			p1_health_val = health_val
			p1_health_bar.value = p1_health_val
			p1_current_health.set_text(str(p1_health_val) + "/" + str(p1_health_max))
			if not p1_health_val == p1_health_old:
				#print ("[COMBAT] Animating server health")
				_animate_health(p1_combo_bar, health_val)
		"ClientPlayer": # Player 2
			p2_health_old = p2_health_val
			p2_health_val = health_val
			p2_health_bar.value = p2_health_val
			p2_current_health.set_text(str(p2_health_val) + "/" + str(p2_health_max))
			if not p2_health_val == p2_health_old:
				#print("[COMBAT] Animating client health")
				_animate_health(p2_combo_bar, health_val)
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")
	#_set_player_health()
	#_update_health_diplay()


func _update_burst(burst_val: int, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_burst_val = burst_val
		"ClientPlayer": # Player 2
			p2_burst_val = burst_val
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")
	_set_player_burst()


func _update_meter_charge(meter_charge: int, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_meter_charge = meter_charge
		"ClientPlayer": # Player 2
			p2_meter_charge = meter_charge
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")
	_set_player_meter_charge()

func _update_meter_val(meter_val: int, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_meter_val = meter_val
		"ClientPlayer": # Player 2
			p2_meter_val = meter_val
		_: # Player does not exist
			print("[SYSTEM] ERROR: player does not exist")
	_set_player_meter_val()


func _update_lives(num_lives: int, player_id: String) -> void:
	match player_id:
		"ServerPlayer": # Player 1
			p1_num_lives = num_lives
			if p1_lives_display.get_child_count() > 0:
				for child in p1_lives_display.get_children():
					child.queue_free()
			for num in range(0, p1_num_lives):
				p1_lives_display.add_child(heart.instantiate())
		"ClientPlayer": # Player 2
			p2_num_lives = num_lives
			if p2_lives_display.get_child_count() > 0:
				for child in p2_lives_display.get_children():
					child.queue_free()
			for num in range(0, p2_num_lives):
				p2_lives_display.add_child(heart.instantiate())
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
	_update_health_diplay()


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
func _animate_health(damage_bar, target_value: int) -> void:
	var tween = create_tween()
	tween.tween_property(damage_bar, "value", target_value, 1)


##################################################
# BANNER FUNCTIONS
##################################################
func _spawn_round_stop_banners() -> void:
	if not MatchData.winners.is_empty():
		_spawn_round_win_banner()
	MatchData.player_control_disabled = true
	await get_tree().create_timer(MatchData.winner_banner_time + MatchData.banner_gap_time).timeout
	_spawn_countdown_banner(false)


func _spawn_round_win_banner() -> void:
	var new_banner = player_win_banner.instantiate()
	center_pane.add_child(new_banner)
	new_banner.text_display.set_text(MatchData.winners.back() + " Wins")
	await get_tree().create_timer(MatchData.winner_banner_time).timeout
	#if banner_timer.timeout:
	new_banner.queue_free()


func _spawn_countdown_banner(is_combat_start: bool) -> void:
	if is_combat_start and not NetworkGlobal.NETWORK_TYPE == NetworkGlobal.NetworkType.LOCAL:
		await SyncManager.sync_started # wait until the peer is connected
	
	var new_banner = player_win_banner.instantiate()
	center_pane.add_child(new_banner)
	new_banner.text_display.set_text("READY")
	await get_tree().create_timer(1).timeout
	for second in range(MatchData.countdown_banner_time, 0, -1):
		new_banner.text_display.set_text(str(second))
		await get_tree().create_timer(1).timeout
	new_banner.text_display.set_text("START")
	await get_tree().create_timer(1).timeout
	new_banner.queue_free()
	MatchSignalBus.emit_banner_done()
	MatchData.player_control_disabled = false


func _spawn_victor_banner() -> void:
	var new_banner = player_win_banner.instantiate()
	center_pane.add_child(new_banner)
	if p1_num_lives > 0:
		new_banner.text_display.set_text("ServerPlayer Wins")
	else:
		new_banner.text_display.set_text("ClientPlayer Wins")
	MatchSignalBus.emit_banner_done()
