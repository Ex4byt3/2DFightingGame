extends PanelContainer


@onready var button = $Button
@onready var icon = $ButtonOverlay/Icon
@onready var menu_name = $ButtonOverlay/MenuName


# Called when the node enters the scene tree for the first time.
func _ready():
	menu_name.MOUSE_FILTER_IGNORE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
