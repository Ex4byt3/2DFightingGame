extends Node

enum NETWORK_TYPES {
	LOCAL,
	ENET,
	STEAM,
}

# -1 = Network type undecided
var NETWORK_TYPE = -1

# Local Rollback Logic (Probably don't need this)


# RPC Rollback Logic

# Steam Rollback Logic
var IS_STEAM_HOST: bool = false
var OPP_STEAM_ID: int = 1