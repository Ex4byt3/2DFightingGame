extends Sprite2D

var current_frame: int = 0
var cached_state: String = "Idle"

@onready var sprite = self

func _ready():
	pass

func advance_frame(current_state):
	if current_state != cached_state:
		cached_state = current_state
		current_frame = 0
		sprite.frame = 0
	else:
		sprite.frame = (sprite.frame + 1) % sprite.hframes
