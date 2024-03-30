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

# hit and block stun are in terms of advantage

# Light attack hands (punches)
# Medium attack kicks
# Heavy attack swords
const attacks = {
	"neutral_light": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 4}, # START UP FRAMES
				{"x": 0, "y": 0, "width": 100, "height": 100, "ticks": 20}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 7} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 620,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 5 * SGFixed.ONE,
			"angle": 0
		},
		"hitstop": 8,
		"hitstun": 2,
		"blockstop": 6,
		"blockstun": -1,
		"mask": 2, # mid
	},
	"neutral_medium": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 6}, # START UP FRAMES
				{"x": 100, "y": 0, "width": 100, "height": 100, "ticks": 20}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 6} # RECOVERY FRAMES
			],
		"damage": 715,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 10 * SGFixed.ONE,
			"angle": 0
		},
		"hitstop": 8,
		"hitstun": 1,
		"blockstop": 6,
		"blockstun": -2,
		"mask": 1, # low
	},
	"neutral_heavy": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 11}, # START UP FRAMES
				{"x": 100, "y": 0, "width": 200, "height": 100, "ticks": 6}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 21} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1143,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 30 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4 / 2
		},
		"hitstop": 15,
		"hitstun": -5,
		"blockstop": 8,
		"blockstun": -8,
		"mask": 2, # mid
	},
	"forward_light": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 8}, # START UP FRAMES
				{"x": 50, "y": 30, "width": 90, "height": 30, "ticks": 5}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 17} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 810,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 80 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 13,
		"hitstun": -5,
		"blockstop": 7,
		"blockstun": -8,
		"mask": 2, # mid
	},
	"forward_medium": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 24}, # START UP FRAMES
				{"x": 70, "y": 30, "width": 100, "height": 50, "ticks": 2}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 11} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 952,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 150 * SGFixed.ONE,
			"angle": 0
		},
		"hitstop": 14,
		"hitstun": 7,
		"blockstop": 7,
		"blockstun": 4,
		"mask": 2, # mid
	},
	"forward_heavy": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 14}, # START UP FRAMES
				{"x": 100, "y": 20, "width": 100, "height": 70, "ticks": 4}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 20} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1238,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 280 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		#"knockdown": 1 # uncertain if we will have attacks with knockdown
		"hitstop": 14,
		"hitstun": 29,
		"blockstop": 7,
		"blockstun": -7,
		"mask": 2, # mid
	},
	"crouching_light": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 4}, # START UP FRAMES
				{"x": 40, "y": -20, "width": 80, "height": 30, "ticks": 4}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 8} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 524,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 1 * SGFixed.ONE,
			"angle": 0
		},
		"hitstop": 11,
		"hitstun": 1,
		"blockstop": 6,
		"blockstun": -2,
		"mask": 2, # mid
	},
	"crouching_medium": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 5}, # START UP FRAMES
				{"x": 50, "y": -30, "width": 100, "height": 100, "ticks": 4}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 10} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 620,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 4 * SGFixed.ONE,
			"angle": 0
		},
		"hitstop": 12,
		"hitstun": 1,
		"blockstop": 6,
		"blockstun": -2,
		"mask": 1, # low
	},
	"crouching_forward": { # TO CHANGE
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 10}, # START UP FRAMES
				{"x": 0, "y": 0, "width": 100, "height": 50, "ticks": 6}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 18} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 809,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 40 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 13,
		"hitstun": 17,
		"blockstop": 7,
		"blockstun": 30,
		"mask": 1,
	},
	"crouching_heavy": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 10}, # START UP FRAMES
				{"x": 50, "y": 10, "width": 100, "height": 50, "ticks": 1}, # ACTIVE FRAMES
				{"x": 30, "y": 60, "width": 100, "height": 150, "ticks": 4}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 28} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 952,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 12 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_2 - 2000
		},
		"hitstop": 15,
		"hitstun": 2,
		"blockstop": 8,
		"blockstun": -13,
		"mask": 2, # mid
	},
	"crouching_impact": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 9}, # START UP FRAMES
				{"x": 60, "y": -40, "width": 100, "height": 50, "ticks": 6}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 18} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 810,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 6 * SGFixed.ONE,
			"angle": -SGFixed.PI_DIV_4
		},
		#"knockdown": 2, # uncertain if we will have attacks with knockdown
		"hitstop": 13,
		"hitstun": 48,
		"blockstop": 7,
		"blockstun": -10,
		"mask": 1, # low
	},
	"impact": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 19}, # START UP FRAMES
				{"x": 60, "y": 0, "width": 100, "height": 100, "ticks": 4}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 25} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1071,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 4 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_2
		},
		"hitstop": 13,
		"hitstun": 0,
		"blockstop": 7,
		"blockstun": -15,
		"mask": 4, # high
	},
	"air_light": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 5}, # START UP FRAMES
				{"x": 30, "y": 20, "width": 100, "height": 50, "ticks": 3}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 9} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 620,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 3 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 11,
		"hitstun": 0,
		"blockstop": 6,
		"blockstun": 0,
		"mask": 4, # high
	},
	"air_medium": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 6}, # START UP FRAMES
				{"x": 60, "y": 10, "width": 100, "height": 50, "ticks": 4}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 6} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 715,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 8 * SGFixed.ONE,
			"angle": SGFixed.PI_DIV_4
		},
		"hitstop": 12,
		"hitstun": 2,
		"blockstop": 6,
		"blockstun": -1,
		"mask": 4, # high
	},
	"air_heavy": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 12}, # START UP FRAMES
				{"x": 80, "y": -10, "width": 120, "height": 150, "ticks": 4}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 23} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1143,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 10 * SGFixed.ONE,
			"angle": -SGFixed.PI_DIV_4
		},
		"hitstop": 15,
		"hitstun": 8,
		"blockstop": 8,
		"blockstun": 5,
		"mask": 4, # high
	},
	"air_impact": {
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 12}, # START UP FRAMES
				{"x": 50, "y": 20, "width": 100, "height": 50, "ticks": 6}, # ACTIVE FRAMES
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 15} # RECOVERY FRAMES, the last hitbox is always treated as recovery
			],
		"damage": 1071,
		"knockback": {
			"static": false,
			"mult": false,
			"force": 10 * SGFixed.ONE,
			"angle": 0
		},
		"hitstop": 13,
		"hitstun": 0,
		"blockstop": 7,
		"blockstun": 0,
		"mask": 4, # high
	}
}

func get_hitboxes(attack_type: String) -> Array:
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
