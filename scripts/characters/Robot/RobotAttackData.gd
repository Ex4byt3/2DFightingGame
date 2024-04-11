extends SGCollisionShape2D
const ONE = SGFixed.ONE

const attacks = {
	# dubug attack
	"_neutral_light": {
		"projectile": false,
		"hitboxes": [
				{"x": -200, "y": 40, "width": 150, "height": 150, "ticks": 5},
				{"x": 60, "y": 40, "width": 150, "height": 150, "ticks": 30},
				{"x": -90, "y": 40, "width": 150, "height": 150, "ticks": 30}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"neutral_light",
				"crouching_light",
				"neutral_medium",
				"crouching_medium",
				"neutral_heavy",
				"crouching_heavy"
			],
		},
		"onHit": {
			"damage": 9999,
			"adv": 0,
			"gain": 0,
			"hitstop": 30,
			"knockdown": 0,
			"knockback": {
				"gain": 1966,
				"static": false,
				"mult": false,
				"force": 2 * ONE,
				"angle": 0
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 8,
			"adv": - 1,
			"mask": 2, # mid
			"knockback": {
				"force": 1 * ONE,
				"angle": 0
			}
		}
	},

	"neutral_light": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 4},
				{"x": 90, "y": 40, "width": 90, "height": 70, "ticks": 3},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 5}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"neutral_light",
				"crouching_light",
				"neutral_medium",
				"crouching_medium",
				"neutral_heavy",
				"crouching_heavy"
			],
		},
		"onHit": {
			"damage": 170,
			"adv": 0,
			"gain": 1000,
			"hitstop": 6,
			"knockdown": 0,
			"knockback": {
				"gain": 3000,
				"static": false,
				"mult": true,
				"force": 2 * ONE,
				"angle": 25735
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 8,
			"adv": - 1,
			"mask": 2, # mid
			"knockback": {
				"force": 1 * ONE,
				"angle": 0
			}
		}
	},

	"neutral_medium": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 6},
				{"x": 85, "y": 10, "width": 100, "height": 60, "ticks": 5},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 6}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"neutral_heavy",
				"crouching_heavy",
				"neutral_impact",
				"crouching_impact"
			],
		},
		"onHit": {
			"damage": 250,
			"adv": - 2,
			"gain": 2000,
			"hitstop": 8,
			"knockdown": 0,
			"knockback": {
				"gain": 6000,
				"static": false,
				"mult": true,
				"force": 3 * ONE,
				"angle": 25735 
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 8,
			"adv": - 2,
			"mask": 2, # mid
			"knockback": {
				"force": 1 * ONE,
				"angle": 0
			}
		}
	},

	"neutral_heavy": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 9},
				{"x": 170, "y": -40, "width": 240, "height": 90, "ticks": 6},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 15}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"crouching_heavy",
				"neutral_impact",
				"forward_heavy"
			],
		},
		"onHit": {
			"damage": 274,
			"adv": - 2,
			"gain": 3276,
			"hitstop": 10,
			"knockdown": 1,
			"knockback": {
				"gain": 4000,
				"static": false,
				"mult": false,
				"force": 3 * ONE,
				"angle": 25735
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 9,
			"adv": - 5,
			"mask": 2, # mid
			"knockback": {
				"force": 2 * ONE,
				"angle": 0
			}
		}
	},

	"neutral_impact": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 20},
				{"x": 190, "y": -20, "width": 270, "height": 210, "ticks": 4},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 24}
			],
		"cancelable": {
			"jump": false,
			"type": 1,
			"moves": [
			],
		},
		"onHit": {
			"damage": 223,
			"adv": - 8,
			"gain": 3276,
			"hitstop": 10,
			"knockdown": 1,
			"knockback": {
				"gain": 3000,
				"static": true,
				"mult": false,
				"force": 6 * ONE,
				"angle": SGFixed.PI_DIV_4
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 12,
			"adv": - 14,
			"mask": 4, # high
			"knockback": {
				"force": 4 * ONE,
				"angle": 0
			}
		}
	},

	"crouching_light": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 3},
				{"x": 100, "y": -15, "width": 70, "height": 60, "ticks": 3},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 5}
			],
		"cancelable": {
		"jump": false,
			"type": 1,
			"moves": [
				"neutral_light",
				"crouching_light",
				"neutral_medium",
				"crouching_medium",
				"neutral_heavy",
				"crouching_heavy"
			],
		},
		"onHit": {
			"damage": 145,
			"adv": 0,
			"gain": 1000,
			"hitstop": 5,
			"knockdown": 0,
			"knockback": {
				"gain": 3500,
				"static": true,
				"mult": false,
				"force": 2 * ONE,
				"angle": 25735
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 9,
			"adv": - 2,
			"mask": 2, # mid
			"knockback": {
				"force": 1 * ONE,
				"angle": 0
			}
		}
	},

	"crouching_medium": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 7},
				{"x": 80, "y": -100, "width": 120, "height": 50, "ticks": 4},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 10}
			],
		"cancelable": {
			"jump": false,
			"type": 1,
			"moves": [
				"crouching_heavy",
				"crouching_impact"
			],
		},
		"onHit": {
			"damage": 185,
			"adv": - 2,
			"gain": 2000,
			"hitstop": 8,
			"knockdown": 0,
			"knockback": {
				"gain": 4000,
				"static": true,
				"mult": false,
				"force": 2 * ONE,
				"angle": 25735
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 9,
			"adv": - 4,
			"mask": 1, # low
			"knockback": {
				"force": 2 * ONE,
				"angle": 0
			}
		}
	},

	"crouching_heavy": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 8},
				{"x": 150, "y": 30, "width": 200, "height": 320, "ticks": 3},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 20}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"neutral_impact"
			],
		},
		"onHit": {
			"damage": 205,
			"adv": - 10,
			"gain": 3932,
			"hitstop": 10,
			"knockdown": 1,
			"knockback": {
				"gain": 6000,
				"static": false,
				"mult": false,
				"force": 12 * ONE,
				"angle": 93537
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 12,
			"adv": - 8,
			"mask": 2, # mid
			"knockback": {
				"force": 4 * ONE,
				"angle": 0
			}
		}
	},

	"crouching_impact": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 11},
				{"x": 80, "y": -100, "width": 420, "height": 40, "ticks": 6},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 17}
			],
		"cancelable": {
			"jump": false,
			"type": 1,
			"moves": [
			],
		},
		"onHit": {
			"damage": 166,
			"adv": 0,
			"gain": 6000,
			"hitstop": 10,
			"knockdown": 2,
			"knockback": {
				"gain": 3500,
				"static": false,
				"mult": false,
				"force": 2 * ONE,
				"angle": SGFixed.PI_DIV_4
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 12,
			"adv": - 14,
			"mask": 1, # low
			"knockback": {
				"force": 3 * ONE,
				"angle": 0
			}
		}
	},

	"forward_heavy": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 13},
				{"x": 230, "y": -10, "width": 370, "height": 110, "ticks": 4},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 22}
			],
		"cancelable": {
			"jump": false,
			"type": 1,
			"moves": [
			],
		},
		"onHit": {
			"damage": 269,
			"adv": + 1,
			"gain": 6300,
			"hitstop": 11,
			"knockdown": 1,
			"knockback": {
				"gain": 3000,
				"static": false,
				"mult": false,
				"force": 8 * ONE,
				"angle": 25735
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 12,
			"adv": - 8,
			"mask": 2, # mid
			"knockback": {
				"force": 5 * ONE,
				"angle": 0
			}
		}
	},

	"crouching_forward_medium": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 10},
				{"x": 75, "y": -100, "width": 100, "height": 50, "ticks": 20},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 5}
			],
		"cancelable": {
			"jump": false,
			"type": 1,
			"moves": [
			],
		},
		"onHit": {
			"damage": 200,
			"adv": - 12,
			"gain": 4000,
			"hitstop": 8,
			"knockdown": 1,
			"knockback": {
				"gain": 3000,
				"static": false,
				"mult": false,
				"force": 4 * ONE,
				"angle": SGFixed.PI_DIV_2
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 7,
			"adv": - 16,
			"mask": 1, # low
			"knockback": {
				"force": 1 * ONE,
				"angle": 0
			}
		}
	},

	"air_light": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 3},
				{"x": 110, "y": -35, "width": 80, "height": 60, "ticks": 2},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 9}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"air_light",
				"back_air_light",
				"air_medium",
				"back_air_medium",
				"air_heavy",
				"back_air_heavy",
				"air_impact",
				"back_impact"
			],
		},
		"onHit": {
			"damage": 150,
			"adv": - 2,
			"gain": 3500,
			"hitstop": 5,
			"knockdown": 1,
			"knockback": {
				"gain": 3000,
				"static": false,
				"mult": true,
				"force": 2 * ONE,
				"angle": SGFixed.PI_DIV_2
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 5,
			"adv": - 4,
			"mask": 4, # high
			"knockback": {
				"force": 1 * ONE,
				"angle": SGFixed.PI_DIV_2
			}
		}
	},

	"back_air_light": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 4},
				{"x": -90, "y": -20, "width": 95, "height": 40, "ticks": 3},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 9}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"air_light",
				"back_air_light",
				"air_medium",
				"back_air_medium",
				"air_heavy",
				"back_air_heavy",
				"air_impact",
				"back_impact"
			],
		},
		"onHit": {
			"damage": 150,
			"adv": - 2,
			"gain": 3500,
			"hitstop": 5,
			"knockdown": 1,
			"knockback": {
				"gain": 3000,
				"static": false,
				"mult": true,
				"force": 2 * ONE,
				"angle": 180151
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 5,
			"adv": - 4,
			"mask": 4, # high
			"knockback": {
				"force": 1 * ONE,
				"angle": 180151
			}
		}
	},

	"air_medium": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 5},
				{"x": 95, "y": -60, "width": 100, "height": 60,  "ticks": 12},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 18}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"air_heavy",
				"back_air_heavy",
				"air_impact",
				"back_impact"
			],
		},
		"onHit": {
			"damage": 190,
			"adv": - 3,
			"gain": 5000,
			"hitstop": 7,
			"knockdown": 1,
			"knockback": {
				"gain": 4000,
				"static": false,
				"mult": true,
				"force": 4 * ONE,
				"angle": 38603
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 7,
			"adv": - 5,
			"mask": 4, # high
			"knockback": {
				"force": 3 * ONE,
				"angle": 38603
			}
		}
	},

	"back_air_medium": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 6},
				{"x": - 70, "y": 20, "width": 120, "height": 80, "ticks": 3},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 14}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"air_heavy",
				"back_air_heavy",
				"air_impact",
				"back_impact"
			],
		},
		"onHit": {
			"damage": 195,
			"adv": - 3,
			"gain": 5000,
			"hitstop": 7,
			"knockdown": 1,
			"knockback": {
				"gain": 4000,
				"static": false,
				"mult": true,
				"force": 4 * ONE,
				"angle": 167283
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 7,
			"adv": - 6,
			"mask": 4, # high
			"knockback": {
				"force": 4 * ONE,
				"angle": 167283
			}
		}
	},

	"air_heavy": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 14},
				{"x": 120, "y": -20, "width": 220, "height": 240, "ticks": 4},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 10}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"air_impact",
				"back_impact"
			],
		},
		"onHit": {
			"damage": 225,
			"adv": - 5,
			"gain": 8500,
			"hitstop": 7,
			"knockdown": 1,
			"knockback": {
				"gain": 7000,
				"static": false,
				"mult": true,
				"force": 7 * ONE,
				"angle": 59707
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 7,
			"adv": - 5,
			"mask": 4, # high
			"knockback": {
				"force": 6 * ONE,
				"angle": 59707
			}
		}
	},

	"back_air_heavy": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 15},
				{"x": -120, "y": -20, "width": 220, "height": 240, "ticks": 4},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 12}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
				"air_impact",
				"back_impact"
			],
		},
		"onHit": {
			"damage": 235,
			"adv": - 5,
			"gain": 8500,
			"hitstop": 7,
			"knockdown": 1,
			"knockback": {
				"gain": 7000,
				"static": false,
				"mult": true,
				"force": 7 * ONE,
				"angle": 160134
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 7,
			"adv": - 6,
			"mask": 4, # high
			"knockback": {
				"force": 6 * ONE,
				"angle": 160134
			}
		}
	},

	"air_impact": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 18},
				{"x": 160, "y": -60, "width": 170, "height": 60, "ticks": 4},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 20}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
			],
		},
		"onHit": {
			"damage": 240,
			"adv": - 5,
			"gain": 9000,
			"hitstop": 7,
			"knockdown": 2,
			"knockback": {
				"gain": 8000,
				"static": false,
				"mult": true,
				"force": 8 * ONE,
				"angle": - 25735
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 7,
			"adv": - 6,
			"mask": 2, # mid
			"knockback": {
				"force": 7 * ONE,
				"angle": 25735
			}
		}
	},

	"back_air_impact": {
		"projectile": false,
		"hitboxes": [
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 16},
				{"x": -140, "y": -20, "width": 170, "height": 60, "ticks": 4},
				{"x": 0, "y": 0, "width": 0, "height": 0, "ticks": 27}
			],
		"cancelable": {
			"jump": true,
			"type": 1,
			"moves": [
			],
		},
		"onHit": {
			"damage": 245,
			"adv": - 5,
			"gain": 9000,
			"hitstop": 7,
			"knockdown": 2,
			"knockback": {
				"gain": 8000,
				"static": false,
				"mult": true,
				"force": 8 * ONE,
				"angle": - 231623
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 7,
			"adv": - 6,
			"mask": 2, # mid
			"knockback": {
				"force": 3 * ONE,
				"angle": 180151
			}
		}
	},

	"qcf_light": {
		"projectile": true,
		"castTime": 55,
		"width": 105 * ONE,
		"height": 130 * ONE,
		"startPos": [180 * ONE, 0],
		"velocity": [30 * ONE, 0],
		"lifespan": 180,
		"spawnDelay": 14,
		"sprite": preload("res://assets/characters/Robot/Attacks/Normals/QCFSmall.png"),
		"cancelable": { 
			"jump": false,
			"type": 2,
			"moves": [],
		},
		"onHit": {
			"damage": 140, # TODO: onHit and onBlock properties of the LMH varients
			"hitstun": 40,
			"gain": 0,
			"hitstop": 7,
			"knockdown": 2,
			"knockback": {
				"gain": 6000,
				"static": false,
				"mult": true,
				"force": 10 * ONE,
				"angle": 25735
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 7,
			"blockstun": 30,
			"mask": 2, # mid
			"knockback": {
				"force": 10 * ONE,
				"angle": 0
			}
		}
	},

	"qcf_medium": {
		"projectile": true,
		"castTime": 55,
		"width": 105 * ONE,
		"height": 130 * ONE,
		"startPos": [180 * ONE, 0],
		"velocity": [40 * ONE, 0],
		"lifespan": 180,
		"spawnDelay": 14,
		"sprite": preload("res://assets/characters/Robot/Attacks/Normals/QCFSmall.png"),
		"cancelable": {
			"jump": false,
			"type": 2,
			"moves": [],
		},
		"onHit": {
			"damage": 200,
			"hitstun": 40,
			"gain": 7000,
			"hitstop": 7,
			"knockdown": 2,
			"knockback": {
				"gain": 6000,
				"static": false,
				"mult": true,
				"force": 10 * ONE,
				"angle": 25735
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 7,
			"blockstun": 30,
			"mask": 2, # mid
			"knockback": {
				"force": 10 * ONE,
				"angle": 0
			}
		}
	},

	"qcf_heavy": {
		"projectile": true,
		"castTime": 55,
		"width": 110 * ONE,
		"height": 155 * ONE,
		"startPos": [180 * ONE, 0],
		"velocity": [50 * ONE, 0],
		"lifespan": 120,
		"spawnDelay": 14,
		"sprite": preload("res://assets/characters/Robot/Attacks/Normals/QCFBig.png"),
		"cancelable": {
			"jump": false,
			"type": 2,
			"moves": [],
		},
		"onHit": {
			"damage": 280,
			"hitstun": 40,
			"gain": 8000,
			"hitstop": 7,
			"knockdown": 2,
			"knockback": {
				"gain": 6000,
				"static": false,
				"mult": true,
				"force": 10 * ONE,
				"angle": 25735
			},
		},
		"onBlock": {
			"damage": 0,
			"blockstop": 7,
			"blockstun": 40,
			"mask": 2, # mid
			"knockback": {
				"force": 10 * ONE,
				"angle": 0
			}
		}
	}
}
