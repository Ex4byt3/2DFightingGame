class_name PlayerKeybinds
extends Resource


# Define constants for player 1 controls
const JUMP = "player1_up"
const CROUCH = "player1_down"
const MOVE_LEFT = "player1_left"
const MOVE_RIGHT = "player1_right"


# Define constants for player 2 controls
const JUMP_P2 = "player2_up"
const CROUCH_P2 = "player2_down"
const MOVE_LEFT_P2 = "player2_left"
const MOVE_RIGHT_P2 = "player2_right"


# These are the default keybinds, do not modify them from here
# Default keybindings for player 1
export(InputEventKey) var default_jump_key = InputEventKey.new()
export(InputEventKey) var default_crouch_key = InputEventKey.new()
export(InputEventKey) var default_move_left_key = InputEventKey.new()
export(InputEventKey) var default_move_right_key = InputEventKey.new()
# Default keybindings for player 2
export(InputEventKey) var default_jump_key_p2 = InputEventKey.new()
export(InputEventKey) var default_crouch_key_p2 = InputEventKey.new()
export(InputEventKey) var default_move_left_key_p2 = InputEventKey.new()
export(InputEventKey) var default_move_right_key_p2 = InputEventKey.new()


# These are the custom keybinds, do not modify them from here
# Custom keybindings for player 1
var jump_key = InputEventKey.new()
var crouch_key = InputEventKey.new()
var move_left_key = InputEventKey.new()
var move_right_key = InputEventKey.new()
# Custom keybindings for player 2
var jump_key_p2 = InputEventKey.new()
var crouch_key_p2 = InputEventKey.new()
var move_left_key_p2 = InputEventKey.new()
var move_right_key_p2 = InputEventKey.new()
