extends Control


onready var name_label = $VBoxContainer/NameLabel
onready var member_avatar = $VBoxContainer/MemberAvatar
onready var status_label = $VBoxContainer/StatusLabel
onready var challenge_button = $VBoxContainer/ChallengeButton

var member_steam_id: int
var member_steam_name: String
var member_status: String = "Status: FREE"
var member_image: Image
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


func _on_avatar_loaded(id: int, avatar_size: int, avatar_buffer: PoolByteArray) -> void:
	# Check if the current member needs to have its avatar updated
	if id == member_steam_id and (not member_image or not avatar_buffer == member_image.get_data()):
		print("[STEAM] Avatar set for " + str(member_steam_id))
		
		# Create the image and texture for loading the avatar
		member_image = Image.new()
		var avatar_texture: ImageTexture = ImageTexture.new()
		
		# Set the image and texture for loading the avatar
		member_image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
		avatar_texture.create_from_image(member_image)
		
		# Apply the created texture to the member
		member_avatar.set_texture(avatar_texture)

