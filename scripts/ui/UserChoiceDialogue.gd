extends Control


@onready var choice_title = $MainPane/TitlePanel/CenterContainer/ChoiceTitle
@onready var choice_context = $MainPane/ContextPanel/ChoiceContext
@onready var accept = $MainPane/Choices/Accept
@onready var reject = $MainPane/Choices/Reject

var title_text: String
var context_text: String


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	_set_dialogue_text()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(accept, get_parent(), "button_up", "_on_dialogue_accepted")
	MenuSignalBus._connect_Signals(reject, get_parent(), "button_up", "_on_dialogue_rejected")


func _set_dialogue_text() -> void:
	choice_title.set_text(title_text)
	choice_context.set_text(context_text)
