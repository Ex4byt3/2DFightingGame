extends Control


@onready var sender_info = $HBoxContainer/SenderInfo
@onready var recipient_info = $HBoxContainer/RecipientInfo
@onready var sender_name_label = $HBoxContainer/SenderInfo/SenderNameLabel
@onready var recipient_name_label = $HBoxContainer/RecipientInfo/RecipientNameLabel
@onready var choice_box = $HBoxContainer/ChoiceBox
@onready var accept_button = $HBoxContainer/ChoiceBox/AcceptButton
@onready var reject_button = $HBoxContainer/ChoiceBox/RejectButton
@onready var pending_label = $HBoxContainer/PendingLabel

var recipient_id: int
var challenger_id: int
var recipient_name: String
var challenger_name: String
var is_challenger: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_set_tile_data()


func _set_tile_data() -> void:
	recipient_name = Steam.getFriendPersonaName(recipient_id)
	challenger_name = Steam.getFriendPersonaName(challenger_id)
	recipient_name_label.set_text(recipient_name)
	sender_name_label.set_text(challenger_name)
	
	if is_challenger:
		sender_info.visible = false
		recipient_info.visible = true
		choice_box.visible = false
		pending_label.visible = true
