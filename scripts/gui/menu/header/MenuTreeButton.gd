extends PanelContainer


@onready var button = $Button
@onready var icon = $ButtonOverlay/Icon
@onready var menu_name = $ButtonOverlay/MenuName
@onready var button_overlay = $ButtonOverlay


# Called when the node enters the scene tree for the first time.
func _ready():
	# DOES NOT WORK: button_overlay.MOUSE_FILTER_IGNORE
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
