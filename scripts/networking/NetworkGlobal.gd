extends Node

# -1 = Network type undecided
#  0 = Local Game
#  1 = Enet Game
#  2 = Steam Game

var NETWORK_TYPE = -1

# Local Rollback Logic (Probably don't need this)
# var LOCAL_IS_HOST: bool = false

# RPC Rollback Logic
var RPC_IS_HOST: bool = false
var RPC_IP: String = ""
var RPC_PORT: int = 0

# Steam Rollback Logic
var STEAM_IS_HOST: bool = false
var STEAM_OPP_ID: int = 1
