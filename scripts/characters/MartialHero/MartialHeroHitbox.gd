extends SGFixedNode2D

# Variables to hold hitbox shapes and related data
var attacks = {
	"light": [
		{"width": 0, "height": 0, "ticks": 10}, # START UP FRAMES
		{"width": 100, "height": 100, "ticks": 10}, # ACTIVE FRAMES
		{"width": 200, "height": 50, "ticks": 10}, # ACTIVE FRAMES
		{"width": 0, "height": 0, "ticks": 10} # RECOVERY FRAMES
	]
}

func get_hitbox_shapes(attack_type: String) -> Array:
	return attacks[attack_type]
