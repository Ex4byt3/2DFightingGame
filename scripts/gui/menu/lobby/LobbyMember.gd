extends Control


@onready var name_label = $Panel/MarginContainer/VBoxContainer/NameLabel
@onready var member_avatar = $Panel/MarginContainer/VBoxContainer/MemberAvatar
@onready var status_label = $Panel/MarginContainer/VBoxContainer/StatusLabel
@onready var challenge_button = $Panel/MarginContainer/VBoxContainer/ChallengeButton

var member_steam_id: int
var member_steam_name: String
var member_status: String = "Status: FREE"
var member_avatar_img: Image
var member_avatar_texture: ImageTexture
var is_host: bool = false

enum MEMBER_STATUS {FREE, IN_MATCH, SPECTATING}


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()
	_set_member_info()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(Steam, self, "avatar_loaded", "_on_avatar_loaded")


func _set_member_info() -> void:
	Steam.getPlayerAvatar(Steam.AVATAR_SMALL, member_steam_id)
	name_label.set_text(member_steam_name)
	_set_member_status(MEMBER_STATUS.FREE)


func _set_member_status(new_status: int) -> void:
	match new_status:
		MEMBER_STATUS.FREE:
			member_status = "Status: FREE"
		MEMBER_STATUS.IN_MATCH:
			member_status = "Status: IN MATCH"
		MEMBER_STATUS.SPECTATING:
			member_status = "Status: SPECTATING"
	status_label.set_text(member_status)


func _on_avatar_loaded(id: int, avatar_size: int, avatar_buffer: PackedByteArray) -> void:
	# Check if the current member needs to have its avatar updated
	if id == member_steam_id and (not member_avatar_img or not avatar_buffer == member_avatar_img.get_data()):
	#if not member_avatar_texture:
		print("[STEAM] Setting avatar set for " + str(Steam.getFriendPersonaName(id)))
		
		# Create the image and texture for loading the avatar
		member_avatar_img = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)

		# Set the texture
		member_avatar_texture = ImageTexture.create_from_image(member_avatar_img)
		
		# Apply the created texture to the member
		member_avatar.set_texture(member_avatar_texture)

