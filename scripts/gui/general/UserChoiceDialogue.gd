extends Control


@onready var choice_title_label = $MainPane/TitlePanel/CenterContainer/ChoiceTitleLabel
@onready var choice_context_label = $MainPane/ContextPanel/ChoiceContextLabel
@onready var accept_button = $MainPane/Choices/AcceptButton
@onready var reject_button = $MainPane/Choices/RejectButton

var title_text: String
var context_text: String


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	_set_dialogue_text()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(accept_button, get_parent(), "button_up", "_on_dialogue_accepted")
	MenuSignalBus._connect_Signals(reject_button, get_parent(), "button_up", "_on_dialogue_rejected")


func _set_dialogue_text() -> void:
	choice_title_label.set_text(title_text)
	choice_context_label.set_text(context_text)
