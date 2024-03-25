extends SGFixedNode2D

var ONE = SGFixed.ONE

# Variable that holds attack hitbox shapes and related data
const attacks = {
	"neutral_light": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 10}, # START UP FRAMES
				{"width": 100, "height": 100, "ticks": 10}, # ACTIVE FRAMES
				{"width": 200, "height": 50, "ticks": 10}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 10} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1000,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstun": 120
	}
}

func get_hitbox_shapes(attack_type: String) -> Array:
	return attacks[attack_type]["hitboxes"]

func get_damage(attack_type: String):
	return attacks[attack_type]["damage"]

func get_knockback(attack_type: String):
	return attacks[attack_type]["knockback"]

func get_hitstun(attack_type: String):
	return attacks[attack_type]["hitstun"]
