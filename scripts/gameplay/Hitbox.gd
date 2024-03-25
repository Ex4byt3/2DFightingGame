extends SGArea2D
class_name Hitbox

# Hitbox parent class, all variables that are shared among all hitboxes
var attacking_player # Name of attacking player (client/server)
var attacked_player # Name of attacked player (client/server)

var damage := 1000 # Amount of damage done (default 1000)

var knockbackForce = 0 # Angle of knockback done (default none)
var knockbackAngle = 0 # Angle of knockback done (default none)
var staticKnockback = false # If the knockback is static (default false)

var hitstun = 0 # Amount of hitstun (default none)

var tick = 0 # Current tick the hitbox is on
var used = false # If the hitbox is used
var hitboxShapes = [] # The shapes of our hitbox over time (frames)
var width = 0 # The current width of our hitbox
var height = 0 # The current height of our hitbox

var despawnAt = 20 # When our hitbox despawns
