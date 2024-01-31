extends Node


# Definitions of signals
signal rpc_server_start(host, port)
signal rpc_client_start(host, port)
signal steam_server_start(steamid)
signal steam_client_start(steamid)
signal local_play_start
signal network_button_pressed(network_type)
signal create_lobby(lobby_settings)


func emit_rpc_server_start(host: String, port: int) -> void:
	emit_signal("rpc_server_start", host, port)


func emit_rpc_client_start(host: String, port: int) -> void:
	emit_signal("rpc_client_start", host, port)


func emit_steam_server_start(steamid: int) -> void:
	emit_signal("steam_server_start", steamid)


func emit_steam_client_start(steamid: int) -> void:
	emit_signal("steam_client_start", steamid)


func emit_local_play_start() -> void:
	print("signal sent")
	emit_signal("local_play_start")

func emit_network_button_pressed(network_type: int) -> void:
	emit_signal("network_button_pressed", network_type)

func emit_create_lobby(lobby_settings: Dictionary) -> void:
	emit_signal("create_lobby")
