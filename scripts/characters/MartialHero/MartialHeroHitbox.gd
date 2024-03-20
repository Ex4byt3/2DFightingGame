extends SGFixedNode2D

var ONE = SGFixed.ONE

# Variable that holds attack hitbox shapes and related data
var attacks = {
	"neutral_light": [
		{"width": 0, "height": 0, "ticks": 10}, # START UP FRAMES
		{"width": 100, "height": 100, "ticks": 10}, # ACTIVE FRAMES
		{"width": 200, "height": 50, "ticks": 10}, # ACTIVE FRAMES
		{"width": 0, "height": 0, "ticks": 10} # RECOVERY FRAMES
	],
}

# Variable that holds attack damages
var damages = {
	"neutral_light": 1000
}

# Variable that holds attack knockback
var knockbacks = {
	"neutral_light": {
		"force": 40 * ONE,
		"angle": SGFixed.PI_DIV_4
	}
}

func get_hitbox_shapes(attack_type: String) -> Array:
	return attacks[attack_type]

func get_damages(attack_type: String):
	return damages[attack_type]

func get_knockbacks(attack_type: String):
	return knockbacks[attack_type]
