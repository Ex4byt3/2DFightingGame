extends Camera2D

var zoom_scaleX = 1650 # Scales the X distance of the players to a reasonable zooming value.
var zoom_scaleY = 600 # Scales the Y distance of the players to a reasonable zooming value.
var min_zoomX: float = 1200 # The X distance between players before the camera stops zooming in.
var min_zoomY: float = 400 # The Y distance between players before the camera stops zooming in.
var max_zoom: float = 1.25 # Max zoom out value. Set to match the width of the stage.
var cam_y_pos: float = -93 # y value of the cam's position should be constant.
var players = []

@onready var server_player = $"../ServerPlayer"
@onready var client_player = $"../ClientPlayer"

func _ready():
	players += [server_player, client_player]

func _process(_delta):
	update_position()
	zoom_camera()

func update_position():
	# Place cam position to the avg X position of all players
	var playerAvg: Vector2 = Vector2.ZERO
	for i in players:
		playerAvg += i.position
	playerAvg /= players.size()
	self.position = Vector2(playerAvg.x, cam_y_pos)

func zoom_camera():
	# Zoom camera based on the distance of the 2 furthest players. Accounts for min X/Y zoom settings.
	var max_distanceX: float = 0
	var max_distanceY: float = 0
	for i in players:
		for j in players:
			if i==j: continue
			var distX: float = abs(i.position.x - j.position.x)
			var distY: float = abs(i.position.y - j.position.y)
			max_distanceX = max(distX, max_distanceX)
			max_distanceY = max(distY, max_distanceY)
	max_distanceX = max(min_zoomX, max_distanceX)
	max_distanceY = max(min_zoomY, max_distanceY)
	var zoom_amount:float = max(max_distanceX / zoom_scaleX, max_distanceY / zoom_scaleY)
	zoom_amount = min(max_zoom, zoom_amount)
	self.zoom = Vector2(zoom_amount, zoom_amount)
