extends Node2D

# Fires back a handshake when 
func sync_handshake():
	print("Syncing handshake")
	if not SteamGlobal.IS_HOST:
		pass

func sync_start():
	print("Starting sync")
	pass
	
func sync_stop():
	print("Stopping sync")
	pass
