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
	"neutral_medium": {
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
	#"neutral_heavy": {
		#
	#},
	#"forward_heavy": {
		#
	#},
	#"crouching_light": {
		#
	#},
	#"crouching_medium": {
		#
	#},
	#"crouching_forward": {
		#
	#},
	#"crouching_heavy": {
		#
	#},
	#"crouching_impact": {
		#
	#},
	#"impact": {
		#
	#},
	#"air_light": {
		#
	#},
	#"air_medium": {
		#
	#},
	#"air_heavy": {
		#
	#},
	#"air_impact": {
		#
	#}
}

func get_hitbox_shapes(attack_type: String) -> Array:
	return attacks[attack_type]["hitboxes"]

func get_damage(attack_type: String):
	return attacks[attack_type]["damage"]

func get_knockback(attack_type: String):
	return attacks[attack_type]["knockback"]

func get_hitstop(attack_type: String):
	return attacks[attack_type]["hitstop"]

func get_hitstun(attack_type: String):
	return attacks[attack_type]["hitstun"]

func get_mask(attack_type: String):
	return attacks[attack_type]["mask"]

func get_spawn_vector(attack_type: String):
	return SGFixed.vector2(attacks[attack_type]["spawn_x"], attacks[attack_type]["spawn_y"])
