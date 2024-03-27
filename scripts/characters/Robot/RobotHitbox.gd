extends SGFixedNode2D

var ONE = SGFixed.ONE

# Every attack as the following properties:
	# name: the name of the attack
	# hitboxes: the position (x, y), width, height, and duration; used to animate the hitbox
	# damage: base damage of the attack
	# knockback: base knockback of the attack
	# hitstun: base hitstun of the attack
	# mask: where the attack hits, most attacks are "mid" but can also but either "high" or "low"
	# 2 is the second bit and is therefore mid, 1 would be a low and 4 would be a high

# Variable that holds attack hitbox shapes and related data

# Light attack hands (punches)
# Medium attack kicks
# Heavy attack swords
const attacks = {
	"neutral_light": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 5}, # START UP FRAMES
				{"width": 80, "height": 30, "ticks": 4}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 7} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 620,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 11,
		"hitstun": 12,
		"blockstun": 30,
		"mask": 2,
		"spawn_x": 0,
		"spawn_y": -50 * SGFixed.ONE,
	},
	"neutral_medium": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 7}, # START UP FRAMES
				{"width": 120, "height": 100, "ticks": 8}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 6} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 715,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 12,
		"hitstun": 14,
		"mask": 1,
		"spawn_x": 0,
		"spawn_y": 50 * SGFixed.ONE,
	},
	"neutral_heavy": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 12}, # START UP FRAMES
				{"width": 100, "height": 50, "ticks": 6}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 21} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1143,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 15,
		"hitstun": 21,
		"mask": 2,
		"spawn_x": 0,
		"spawn_y": 0,
	},
	"forward_light": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 9}, # START UP FRAMES
				{"width": 90, "height": 30, "ticks": 5}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 17} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 810,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 13,
		"hitstun": 16,
		"mask": 2,
		"spawn_x": 0,
		"spawn_y": -60 * SGFixed.ONE,
	},
	"forward_medium": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 25}, # START UP FRAMES
				{"width": 100, "height": 50, "ticks": 2}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 11} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 952,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 14,
		"hitstun": 19,
		"mask": 2,
		"spawn_x": 0,
		"spawn_y": -50 * SGFixed.ONE,
	},
	"forward_heavy": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 15}, # START UP FRAMES
				{"width": 100, "height": 70, "ticks": 4}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 20} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1238,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 14,
		"hitstun": 19,
		"mask": 2,
		"spawn_x": 0,
		"spawn_y": 0,
	},
	"crouching_light": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 5}, # START UP FRAMES
				{"width": 80, "height": 30, "ticks": 4}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 8} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 524,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 11,
		"hitstun": 13,
		"mask": 4,
		"spawn_x": 0,
		"spawn_y": 50 * SGFixed.ONE,
	},
	"crouching_medium": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 6}, # START UP FRAMES
				{"width": 100, "height": 100, "ticks": 4}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 10} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 620,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 12,
		"hitstun": 15,
		"mask": 1,
		"spawn_x": 0,
		"spawn_y": 100 * SGFixed.ONE,
	},
	"crouching_forward": { # TO CHANGE
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 10}, # START UP FRAMES
				{"width": 100, "height": 50, "ticks": 6}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 18} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 809,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 13,
		"hitstun": 17,
		"mask": 1,
		"spawn_x": 0,
		"spawn_y": 0,
	},
	"crouching_heavy": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 11}, # START UP FRAMES
				{"width": 100, "height": 50, "ticks": 1}, # ACTIVE FRAMES
				{"width": 100, "height": 150, "ticks": 4}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 28} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 952,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 15,
		"hitstun": 22,
		"mask": 4,
		"spawn_x": 0,
		"spawn_y": 0,
	},
	"crouching_impact": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 10}, # START UP FRAMES
				{"width": 100, "height": 50, "ticks": 6}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 18} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 810,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 13,
		"hitstun": 17,
		"mask": 1,
		"spawn_x": 0,
		"spawn_y": 0,
	},
	"impact": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 20}, # START UP FRAMES
				{"width": 100, "height": 100, "ticks": 4}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 25} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1071,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 13,
		"hitstun": 16,
		"mask": 2,
		"spawn_x": 0,
		"spawn_y": 0,
	},
	"air_light": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 5}, # START UP FRAMES
				{"width": 100, "height": 50, "ticks": 4}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 7} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 620,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 11,
		"hitstun": 12,
		"mask": 2,
		"spawn_x": 0,
		"spawn_y": 0,
	},
	"air_medium": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 7}, # START UP FRAMES
				{"width": 100, "height": 50, "ticks": 8}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 6} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 715,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 12,
		"hitstun": 14,
		"mask": 1,
		"spawn_x": 0,
		"spawn_y": -50 * SGFixed.ONE,
	},
	"air_heavy": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 12}, # START UP FRAMES
				{"width": 100, "height": 50, "ticks": 6}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 21} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1143,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 15,
		"hitstun": 21,
		"mask": 2,
		"spawn_x": 0,
		"spawn_y": 0,
	},
	"air_impact": {
		"hitboxes": [
				{"width": 0, "height": 0, "ticks": 20}, # START UP FRAMES
				{"width": 100, "height": 50, "ticks": 4}, # ACTIVE FRAMES
				{"width": 0, "height": 0, "ticks": 25} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1071,
		"knockback": {
			"static": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 13,
		"hitstun": 16,
		"mask": 2,
		"spawn_x": 0,
		"spawn_y": 0,
	}
}

func get_hitbox_shapes(attack_type: String) -> Array:
	return attacks[attack_type]["hitboxes"]

func get_damage(attack_type: String):
	return attacks[attack_type]["damage"]

func get_knockback(attack_type: String):
	return attacks[attack_type]["knockback"]

func get_hitstop(attack_type: String):
	return attacks[attack_type]["hitstop"]
func get_blockstun(attack_type: String):
	return attacks[attack_type]["blockstun"]

func get_hitstun(attack_type: String):
	return attacks[attack_type]["hitstun"]

func get_mask(attack_type: String):
	return attacks[attack_type]["mask"]

func get_spawn_vector(attack_type: String):
	return SGFixed.vector2(attacks[attack_type]["spawn_x"], attacks[attack_type]["spawn_y"])
