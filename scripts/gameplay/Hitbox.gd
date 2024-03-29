extends SGArea2D
class_name Hitbox

# Hitbox parent class, all variables that are shared among all hitboxes
var attacking_player # Name of attacking player (client/server)
var attacked_player # Name of attacked player (client/server)

var properties = {} # Properties of the hitbox (damage, knockback, etc.)

var tick = 0 # Current tick the hitbox is on
var used = false # If the hitbox is used
var hitboxes = [] # The shapes of our hitbox over time (frames)

var despawnAt = 0 # When our hitbox despawns
