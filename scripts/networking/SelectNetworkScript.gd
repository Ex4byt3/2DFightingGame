extends Node2D

# Onready variables for the different networking scripts
@onready var LocalConnect = preload("res://scripts/networking/LocalConnect.gd")
@onready var RPCConnect = preload("res://scripts/networking/RPCConnect.gd")
@onready var SteamConnect = preload("res://scripts/networking/SteamConnect.gd")
# Onready variables for the different maps
@onready var Map1 = preload("res://scenes/maps/Map1.tscn")

func _ready():
	# Whatever map is selected get's instanced, added, and renamed
	var map = Map1.instantiate()
	add_child(map)
	$Map1.name = "Map" # change the maps name to "Map" reguardless of what map it is

	match NetworkGlobal.NETWORK_TYPE:
		NetworkGlobal.NetworkType.LOCAL:
			$Map.set_script(LocalConnect)
		NetworkGlobal.NetworkType.ENET:
			$Map.set_script(RPCConnect)
		NetworkGlobal.NetworkType.STEAM:
			$Map.set_script(SteamConnect)
		_:
			print("error: No network type selected.")
			return
	$Map._ready() # call the _ready function of the map
	$Map.set_process(true) # start the map's process function
