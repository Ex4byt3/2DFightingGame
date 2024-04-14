class_name PlayerKeybinds
extends Resource

##################################################
# INPUT CONSTANTS
##################################################
# These are taken from project -> settings -> input map

# Define constants for player 1 controls
const JUMP = "player1_up"
const CROUCH = "player1_down"
const MOVE_LEFT = "player1_left"
const MOVE_RIGHT = "player1_right"
const LIGHT_ATTACK = "player1_light"
const MEDIUM_ATTACK = "player1_medium"
const HEAVY_ATTACK = "player1_heavy"
const IMPACT = "player1_impact"
const DASH = "player1_dash"
const BLOCK = "player1_block"
const SHIELD = "player1_shield"

# Define constants for player 2 controls
const JUMP_P2 = "player2_up"
const CROUCH_P2 = "player2_down"
const MOVE_LEFT_P2 = "player2_left"
const MOVE_RIGHT_P2 = "player2_right"
const LIGHT_ATTACK_P2 = "player2_light"
const MEDIUM_ATTACK_P2 = "player2_medium"
const HEAVY_ATTACK_P2 = "player2_heavy"
const IMPACT_P2 = "player2_impact"
const DASH_P2 = "player2_dash"
const BLOCK_P2 = "player2_block"
const SHIELD_P2 = "player2_shield"


##################################################
# DEFAULT KEYBINDS
##################################################
# Default keybindings for player 1
@export var default_jump_key: InputEventKey = InputEventKey.new()
@export var default_crouch_key: InputEventKey = InputEventKey.new()
@export var default_move_left_key: InputEventKey = InputEventKey.new()
@export var default_move_right_key: InputEventKey = InputEventKey.new()
@export var default_light_attack_key: InputEventKey = InputEventKey.new()
@export var default_medium_attack_key: InputEventKey = InputEventKey.new()
@export var default_heavy_attack_key: InputEventKey = InputEventKey.new()
@export var default_impact_key: InputEventKey = InputEventKey.new()
@export var default_dash_key: InputEventKey = InputEventKey.new()
@export var default_block_key: InputEventKey = InputEventKey.new()
@export var default_shield_key: InputEventKey = InputEventKey.new()

# Default keybindings for player 2
@export var default_jump_key_p2: InputEventKey = InputEventKey.new()
@export var default_crouch_key_p2: InputEventKey = InputEventKey.new()
@export var default_move_left_key_p2: InputEventKey = InputEventKey.new()
@export var default_move_right_key_p2: InputEventKey = InputEventKey.new()
@export var default_light_attack_key_p2: InputEventKey = InputEventKey.new()
@export var default_medium_attack_key_p2: InputEventKey = InputEventKey.new()
@export var default_heavy_attack_key_p2: InputEventKey = InputEventKey.new()
@export var default_impact_key_p2: InputEventKey = InputEventKey.new()
@export var default_dash_key_p2: InputEventKey = InputEventKey.new()
@export var default_block_key_p2: InputEventKey = InputEventKey.new()
@export var default_shield_key_p2: InputEventKey = InputEventKey.new()


##################################################
# CUSTOM KEYBINDS
##################################################
# Custom keybindings for player 1
var jump_key = InputEventKey.new()
var crouch_key = InputEventKey.new()
var move_left_key = InputEventKey.new()
var move_right_key = InputEventKey.new()
var light_attack_key = InputEventKey.new()
var medium_attack_key = InputEventKey.new()
var heavy_attack_key = InputEventKey.new()
var impact_key = InputEventKey.new()
var dash_key = InputEventKey.new()
var block_key = InputEventKey.new()
var shield_key = InputEventKey.new()

# Custom keybindings for player 2
var jump_key_p2 = InputEventKey.new()
var crouch_key_p2 = InputEventKey.new()
var move_left_key_p2 = InputEventKey.new()
var move_right_key_p2 = InputEventKey.new()
var light_attack_key_p2 = InputEventKey.new()
var medium_attack_key_p2 = InputEventKey.new()
var heavy_attack_key_p2 = InputEventKey.new()
var impact_key_p2 = InputEventKey.new()
var dash_key_p2 = InputEventKey.new()
var block_key_p2 = InputEventKey.new()
var shield_key_p2 = InputEventKey.new()
