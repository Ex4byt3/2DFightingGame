extends Node

const DummyNetworkAdaptor = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")

onready var message_label = $Messages/MessageLabel
onready var sync_lost_label = $Messages/SyncLostLabel
onready var server_player = $ServerPlayer
onready var client_player = $ClientPlayer
onready var johnny = $Johnny

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_match()
	
func setup_match():
	
	if NetworkGlobal.NETWORK_TYPE != 0:
		print("Network type not set to local, exiting...")
		get_tree().exit()
	
	client_player.input_prefix = "player2_"
	SyncManager.network_adaptor = DummyNetworkAdaptor.new()
	SyncManager.start()
