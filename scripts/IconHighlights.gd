extends GridContainer

onready var menu_icons = $"../MenuIcons"

onready var online_highlight = $OnlineHighlight
onready var local_highlight = $LocalHighlight
onready var training_highlight = $TrainingHighlight
onready var records_highlight = $RecordsHighlight
onready var quit_highlight = $QuitHighlight

onready var online_button = $"../MenuIcons/OnlineButton"
onready var local_button = $"../MenuIcons/LocalButton"
onready var training_button = $"../MenuIcons/TrainingButton"
onready var records_button = $"../MenuIcons/RecordsButton"
onready var quit_button = $"../MenuIcons/QuitButton"

onready var online_tab = $"../OnlineTab"
onready var local_tab = $"../LocalTab"
onready var training_tab = $"../TrainingTab"
onready var records_tab = $"../RecordsTab"
onready var quit_tab = $"../QuitTab"

# Called when the node enters the scene tree for the first time.
func _ready():
	for icon in menu_icons.get_children():
		icon.connect("button_up", self, "on_change_tab")
		icon.connect("mouse_exited", self, "on_change_tab")

func on_change_tab() -> void:
	if not online_tab.visible == true and online_button.pressed == false:
		animate_highlight_contract(online_highlight)
	if not local_tab.visible == true and local_button.pressed == false:
		animate_highlight_contract(local_highlight)
	if not training_tab.visible == true and training_button.pressed == false:
		animate_highlight_contract(training_highlight)
	if not records_tab.visible == true and records_button.pressed == false:
		animate_highlight_contract(records_highlight)
	if not quit_tab.visible == true and quit_button.pressed == false:
		animate_highlight_contract(quit_highlight)

func _on_OnlineButton_mouse_entered():
	animate_highlight_expand(online_highlight)


func _on_LocalButton_mouse_entered():
	animate_highlight_expand(local_highlight)


func _on_TrainingButton_mouse_entered():
	animate_highlight_expand(training_highlight)


func _on_RecordsButton_mouse_entered():
	animate_highlight_expand(records_highlight)


func _on_QuitButton_mouse_entered():
	animate_highlight_expand(quit_highlight)


func animate_highlight_expand(highlight: TextureProgress) -> void:
	var tween := create_tween()
	tween.tween_property(highlight, "value", 100, 0.2)

func animate_highlight_contract(highlight: TextureProgress) -> void:
	var tween := create_tween()
	tween.tween_property(highlight, "value", 0, 0.2)
