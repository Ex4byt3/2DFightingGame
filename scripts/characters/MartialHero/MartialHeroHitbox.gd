extends SGFixedNode2D

# Variables to hold hitbox shapes and related data
var attacks = {
	"light": [
		{"width": 32, "height": 32, "ticks": 1},
		{"width": 48, "height": 48, "ticks": 2}
	],
	"medium": [
		{"width": 32, "height": 32, "ticks": 1},
		{"width": 48, "height": 48, "ticks": 2}
	],
	"heavy": [
		{"width": 32, "height": 32, "ticks": 1},
		{"width": 48, "height": 48, "ticks": 2}
	]
}

func get_hitbox_shapes(attack_type: String) -> Array:
	return attacks[attack_type]
