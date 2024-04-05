extends Node


enum CharacterID {Robot}
enum MapID {TheBox}

const DEFAULT_CHARACTER_ID = CharacterID.Robot
const DEFAULT_MAP_ID = MapID.TheBox

var selected_map: int = DEFAULT_MAP_ID
var loaded_map

var host_character_id = DEFAULT_CHARACTER_ID
var client_character_id = DEFAULT_CHARACTER_ID
var host_character
var client_character

const character_starting_pos_y = 1299 * SGFixed.ONE
const host_starting_pos_x = 64749568
const client_starting_pos_x = 99287040

var in_match: bool = false
var in_combat: bool = false
var player_control_disabled: bool = true

# Variables used for settings timers
var round_time: int = 180
var countdown_banner_time: int = 3
var winner_banner_time: int = 3
var banner_gap_time: int = 0.2

var local_player_ready: bool = true
var opposing_player_ready: bool = true

# Array to hold round winners
var winners: Array = []

# Dictionary containing for match settings
var match_settings: Dictionary = {}


# TODO: Refactor this functionality once the new networking
# script has been created
func _update_winners(loser) -> void:
	var winner
	if loser == "ServerPlayer":
		winner = "ClientPlayer"
	else:
		winner = "ServerPlayer"
	winners.append(winner)
