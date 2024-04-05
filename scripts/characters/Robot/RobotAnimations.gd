extends FixedAnimator

@onready var ANIMATIONS = {
	"Idle": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"framerate": 4,
			"frameCount": 42,
			"loop": true,
			"simple": true
		}
	},
	"Walk": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"framerate": 4,
			"loop": true,
			"frameCount": 10,
			"simple": true
		}
	},
	"Sprint": {
		"animation": {
			"framerate": 4,
			"loop": true,
			"frameCount": 8,
			"simple": true
		}
	},
	"Crouch": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 3,
			"simple": true
		}
	},
	"Crouching": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	"Crawl": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"framerate": 4,
			"loop": true,
			"frameCount": 16,
			"simple": true
		}
	},
	"Stand": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 3,
			"simple": true
		}
	},
	"Jumpsquat": {
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	"Jump": {
		"animation": {
			"framerate": 4,
			"loop": false,
			"frameCount": 3,
			"simple": true
		}
	},
	"Airborne": {
		"animation": {
			"framerate": 4,
			"loop": false,
			"frameCount": 3,
			"simple": true
		}
	},
	"AirJumpsquat": {
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	"AirJump": {
		"animation": {
			"framerate": 4,
			"loop": false,
			"frameCount": 2,
			"simple": true
		}
	},
	"DashR": {
		"animation": {
			"framerate": 4,
			"loop": false,
			"frameCount": 5,
			"simple": true
		}
	},
	"DashUR": {
		"animation": {
			"framerate": 4,
			"loop": false,
			"frameCount": 5,
			"simple": true
		}
	},
	"DashDR": {
		"animation": {
			"framerate": 4,
			"loop": false,
			"frameCount": 5,
			"simple": true
		}
	},
	"DashU": {
		"animation": {
			"framerate": 4,
			"loop": false,
			"frameCount": 5,
			"simple": true
		}
	},
	"DashD": {
		"animation": {
			"framerate": 4,
			"loop": false,
			"frameCount": 5,
			"simple": true
		}
	},
	"Block": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 2,
			"simple": true
		}
	},
	"Unblock": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 2,
			"simple": true
		}
	},
	"Blocking": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	"Blockstun": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	"BlockstunEnd": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 3,
			"simple": true
		}
	},
	"Parry": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 4,
			"simple": true
		}
	},
	"BlockCrouch": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 3,
			"simple": true
		}
	},
	"BlockStand": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 2,
			"simple": true
		}
	},
	"LowBlock": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 2,
			"simple": true
		}
	},
	"LowUnblock": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 2,
			"simple": true
		}
	},
	"LowBlocking": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	"LowBlockstun": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	"LowBlockstunEnd": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 3,
			"simple": true
		}
	},
	"LowParry": {
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 3, # TODO: normal parry has 4 frames, the others do not
			"simple": true
		}
	},
	"AirBlock": {
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 2,
			"simple": true
		}
	},
	"AirUnblock": {
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 2,
			"simple": true
		}
	},
	"AirBlocking": {
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	"AirBlockstun": {
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	"AirBlockstunEnd": {
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 3,
			"simple": true
		}
	},
	"AirParry": {
		"animation": {
			"framerate": 2,
			"loop": false,
			"frameCount": 3,
			"simple": true
		}
	},
	"Hitstun": {
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	# "HitstunEnd": { # TODO: Add a hitstun end animation
	# 	"animation": {
	# 		"framerate": 2,
	# 		"loop": false,
	# 		"frameCount": 3,
	# 		"simple": true
	# 	}
	# },
	"AirHitstun": {
		"animation": {
			"framerate": 1,
			"loop": false,
			"frameCount": 1,
			"simple": true
		}
	},
	# "AirHitstunEnd": {
	# 	"animation": {
	# 		"framerate": 2,
	# 		"loop": false,
	# 		"frameCount": 3,
	# 		"simple": true
	# 	}
	# },
	"NeutralLight": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [4, 3, 5]
	},
	"NeutralMedium":{
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [6, 5, 6]
	},
	"NeutralHeavy":{
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [9, 6, 15]
	},
	"NeutralImpact": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [14, 5, 4, 24] # 2 startup frames, totaling to 20 but after 19 the hitsotp does not line up, strange
	},
	"CrouchingLight": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [3, 3, 5]
	},
	"CrouchingMedium": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [7, 4, 10]
	},
	"CrouchingHeavy": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [8, 3, 20]
	},
	"CrouchingImpact": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [6, 4, 6, 17]
	},
	"ForwardHeavy": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [13, 4, 22]
	},
	"CrouchingForwardMedium": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [10, 20, 5]
	},
	"AirLight": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [3, 2, 9]
	},
	"BackAirLight": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [4, 3, 9]
	},
	"AirMedium": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [5, 12, 18]
	},
	# back_air_medium
	"AirHeavy": {
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": [14, 4, 10]
	},
	# back_air_heavy
	# air_impact
	# back_air_impact
	# qcf_light
}

func _ready():
	animations = ANIMATIONS
