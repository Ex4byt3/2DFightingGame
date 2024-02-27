extends Camera2D

export var zoom_scale: int = 1650 # Scales the distance of the players to a reasonable zooming value
export var min_zoom: float = 0.5 # The distance between players before the camera stops zooming in
export var max_zoom: float = 1.25 # Max zoom out value. Set to match the width of the stage.
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
	if zoom_scale <= 0:
		zoom_scale = 1
	var zoom_amount = max(min_zoom, sqrt(max_distance) / zoom_scale)
	zoom_amount = min(zoom_amount, max_zoom)
	zoom = Vector2(zoom_amount, zoom_amount)
