extends Camera2D

@export var min_distX: float = 1200 # The X distance between players before the camera stops zooming in.
@export var min_distY: float = 400 # The Y distance between players before the camera stops zooming in.
@export var max_zoom: float = 0.8 # Max zoom out value. Set to match the width of the stage.
@export var min_zoom: float = 1.5 # Min zoom in value.
@export_range(0.1, 2) var zoom_scale: float = 1.2
var players = []
var cam_y_pos # y value of the cam's position should be constant.
var max_distX: float = 2226 # Max distance between players. Set to match the width of the stage.
var max_distY: float = 1200

@onready var server_player = $"../ServerPlayer"
@onready var client_player = $"../ClientPlayer"

func _ready():
	initialize_cam()

func _process(_delta):
	update_position()
	zoom_camera()

func initialize_cam():
	players += [server_player, client_player]
	cam_y_pos = get_limit(SIDE_BOTTOM)

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
	max_distanceX = max(min_distX, max_distanceX)
	max_distanceY = max(min_distY, max_distanceY)
	var zoom_amount:float = min(scale_zoomX(max_distanceX), scale_zoomY(max_distanceY))
	zoom_amount = min(zoom_amount, min_zoom)
	zoom_amount = max(zoom_amount, max_zoom)
	self.zoom = Vector2(zoom_amount, zoom_amount)

func scale_zoomX(dist: float) -> float:
	var val = ((dist - min_distX) / (max_distX - min_distX)) * (max_zoom - min_zoom) + min_zoom
	return val / zoom_scale

func scale_zoomY(dist: float) -> float:
	var val = ((dist - min_distY) / (max_distY - min_distY)) * (max_zoom - min_zoom) + min_zoom
	return val / zoom_scale
