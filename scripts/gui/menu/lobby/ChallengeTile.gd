extends Control


@onready var sender_info = $Panel/MarginContainer/HBoxContainer/SenderInfo
@onready var recipient_info = $Panel/MarginContainer/HBoxContainer/RecipientInfo
@onready var sender_name_label = $Panel/MarginContainer/HBoxContainer/SenderInfo/SenderNameLabel
@onready var recipient_name_label = $Panel/MarginContainer/HBoxContainer/RecipientInfo/RecipientNameLabel
@onready var choice_box = $Panel/MarginContainer/HBoxContainer/ChoiceBox
@onready var accept_button = $Panel/MarginContainer/HBoxContainer/ChoiceBox/AcceptButton
@onready var reject_button = $Panel/MarginContainer/HBoxContainer/ChoiceBox/RejectButton
@onready var pending_label = $Panel/MarginContainer/HBoxContainer/PendingLabel

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
