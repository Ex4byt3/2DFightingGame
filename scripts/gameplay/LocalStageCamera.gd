extends Camera2D

export var zoom_scale: int = 650
export var min_zoom: float = 0.5
var players = []

onready var server_player = $"../ServerPlayer"
onready var client_player = $"../ClientPlayer"

func _ready():
	players += [server_player, client_player]

func _process(_delta):
	update_position()
	zoom_camera()

func update_position():
	var playerAvg: Vector2 = Vector2.ZERO
	for i in players:
		playerAvg += i.position
	
	playerAvg /= players.size()
	position = playerAvg

func zoom_camera():
	var max_distance: int = 0
	for i in players:
		for j in players:
			if i==j: continue
			var dist: int = (i.global_position - j.global_position).length_squared()
			max_distance = max(max_distance, dist)
	var zoom_amount = max(min_zoom, sqrt(max_distance) / zoom_scale)
	zoom = Vector2(zoom_amount, zoom_amount)
