extends FixedAnimator

@onready var ANIMATIONS = {
	"Idle": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Idle.png"),
			"hframes": 42,
			"frame": 0,
		},
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 6750123
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 589799
		},
		"animation": {
			"frameRate": 4,
			"loop": true,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 41,
			"simple": true
		}
	},
	"Walk": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Walk.png"),
			"hframes": 10,
			"frame": 0,
		},
		"animation": {
			"frameRate": 4,
			"loop": true,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 9,
			"simple": true
		}
	},
	"Sprint": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Sprint.png"),
			"hframes": 8,
			"frame": 0,
		},
		"animation": {
			"frameRate": 4,
			"loop": true,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 7,
			"simple": true
		}
	},
	"Crouch": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Crouch.png"),
			"hframes": 3,
			"frame": 0,
		},
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"frameRate": 4,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 2,
			"simple": true
		}
	},
	"Crouching": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Crouch.png"),
			"hframes": 3,
			"frame": 2,
		},
		"hurtbox": {
			"shape": {
				"extents_x": 4487098,
				"extents_y": 4379738
			},
				"fixed_position_x": -131072,
				"fixed_position_y": 2949095
		},
		"animation": {
			"frameRate": 0,
			"loop": false,
			"reverse": false,
			"startFrame": 2,
			"endFrame": 2,
			"simple": true
		}
	},
	"Crawl": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Crawl.png"),
			"hframes": 16,
			"frame": 0,
		},
		"animation": {
			"frameRate": 4,
			"loop": true,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 15,
			"simple": true
		}
	},
	"Stand": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Crouch.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 4,
			"loop": false,
			"reverse": true,
			"startFrame": 2,
			"endFrame": 0,
			"simple": true
		}
	},
	"Jumpsquat": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Jump.png"),
			"hframes": 4,
			"frame": 0,
		},
		"animation": {
			"frameRate": 0,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 0,
			"simple": true
		}
	},
	"Jump": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Jump.png"),
			"hframes": 4,
			"frame": 1,
		},
		"animation": {
			"frameRate": 4,
			"loop": false,
			"reverse": false,
			"startFrame": 1,
			"endFrame": 3,
			"simple": true
		}
	},
	"Airborne": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Airborne.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 4,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 2,
			"simple": true
		}
	},
	"AirJumpsquat": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/AirJump.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 0,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 0,
			"simple": true
		}
	},
	"AirJump": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/AirJump.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 4,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 2,
			"simple": true
		}
	},
	"DashR": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Dash/DashR.png"),
			"hframes": 5,
			"frame": 0,
		},
		"animation": {
			"frameRate": 4,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 4,
			"simple": true
		}
	},
	"DashUR": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Dash/DashR.png"),
			"hframes": 5,
			"frame": 0,
		},
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": {
			0: {
				"frames": 4,
				"sprite":{
					"frame": 0
				}
			},
			1: {
				"frames": 4,
				"sprite": {
					"texture": load("res://assets/characters/Robot/Movement/Dash/DashUR.png"),
					"hframes": 3
				}
			},
			2: {
				"frames": 4,
				"sprite": {
					"frame": 1
				}
			},
			3: {
				"frames": 4,
				"sprite": {
					"frame": 2
				}
			},
			4: {
				"frames": 4,
				"sprite": {
					"frame": 0
				}
			},
			5: {
				"frames": 4,
				"sprite": {
					"frame": 1
				}
			},
			6: {
				"frames": 4,
				"sprite": {
					"frame": 2
				}
			},
		},
	},
	"DashDR": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Dash/DashR.png"),
			"hframes": 5,
			"frame": 0,
		},
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": {
			0: {
				"frames": 4,
				"sprite":{
					"frame": 0
				}
			},
			1: {
				"frames": 4,
				"sprite": {
					"texture": load("res://assets/characters/Robot/Movement/Dash/DashDR.png"),
					"hframes": 3
				}
			},
			2: {
				"frames": 4,
				"sprite": {
					"frame": 1
				}
			},
			3: {
				"frames": 4,
				"sprite": {
					"frame": 2
				}
			},
			4: {
				"frames": 4,
				"sprite": {
					"frame": 0
				}
			},
			5: {
				"frames": 4,
				"sprite": {
					"frame": 1
				}
			},
			6: {
				"frames": 4,
				"sprite": {
					"frame": 2
				}
			},
		},
	},
	"DashU": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Dash/DashR.png"),
			"hframes": 5,
			"frame": 0,
		},
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": {
			0: {
				"frames": 4,
				"sprite":{
					"frame": 0
				}
			},
			1: {
				"frames": 4,
				"sprite": {
					"texture": load("res://assets/characters/Robot/Movement/Dash/DashU.png"),
					"hframes": 3
				}
			},
			2: {
				"frames": 4,
				"sprite": {
					"frame": 1
				}
			},
			3: {
				"frames": 4,
				"sprite": {
					"frame": 2
				}
			},
			4: {
				"frames": 4,
				"sprite": {
					"frame": 0
				}
			},
			5: {
				"frames": 4,
				"sprite": {
					"frame": 1
				}
			},
			6: {
				"frames": 4,
				"sprite": {
					"frame": 2
				}
			}
		}
	},
	"DashD": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Movement/Dash/DashR.png"),
			"hframes": 5,
			"frame": 0,
		},
		"animation": {
			"loop": false,
			"simple": false
		},
		"frames": {
			0: {
				"frames": 4,
				"sprite":{
					"frame": 0
				}
			},
			1: {
				"frames": 4,
				"sprite": {
					"texture": load("res://assets/characters/Robot/Movement/Dash/DashD.png"),
					"hframes": 3
				}
			},
			2: {
				"frames": 4,
				"sprite": {
					"frame": 1
				}
			},
			3: {
				"frames": 4,
				"sprite": {
					"frame": 2
				}
			},
			4: {
				"frames": 4,
				"sprite": {
					"frame": 0
				}
			},
			5: {
				"frames": 4,
				"sprite": {
					"frame": 1
				}
			},
			6: {
				"frames": 4,
				"sprite": {
					"frame": 2
				}
			}
		}
	},
	"Block": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/Block.png"),
			"hframes": 2,
			"frame": 0,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 1,
			"simple": true
		}
	},
	"Unblock": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/Block.png"),
			"hframes": 2,
			"frame": 1,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": true,
			"startFrame": 1,
			"endFrame": 0,
			"simple": true
		}
	},
	"Blocking": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/Block.png"),
			"hframes": 2,
			"frame": 1,
		},
		"animation": {
			"frameRate": 0,
			"loop": false,
			"reverse": false,
			"startFrame": 1,
			"endFrame": 1,
			"simple": true
		}
	},
	"Blockstun": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/Blockstun.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 0,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 0,
			"simple": true
		}
	},
	"BlockstunEnd": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/Blockstun.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 1,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 2,
			"simple": true
		}
	},
	"Parry": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/Parry.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 2,
			"simple": true
		}
	},
	"BlockCrouch": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/BlockCrouch.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 2,
			"simple": true
		}
	},
	"BlockStand": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/BlockCrouch.png"),
			"hframes": 3,
			"frame": 2,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": true,
			"startFrame": 2,
			"endFrame": 0,
			"simple": true
		}
	},
	"LowBlock": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/LowBlock.png"),
			"hframes": 2,
			"frame": 0,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 1,
			"simple": true
		}
	},
	"LowUnblock": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/LowBlock.png"),
			"hframes": 2,
			"frame": 1,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": true,
			"startFrame": 1,
			"endFrame": 0,
			"simple": true
		}
	},
	"LowBlocking": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/LowBlock.png"),
			"hframes": 2,
			"frame": 1,
		},
		"animation": {
			"frameRate": 0,
			"loop": false,
			"reverse": false,
			"startFrame": 1,
			"endFrame": 1,
			"simple": true
		}
	},
	"LowBlockstun": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/LowBlockstun.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 0,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 0,
			"simple": true
		}
	},
	"LowBlockstunEnd": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/LowBlockstun.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 1,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 2,
			"simple": true
		}
	},
	"LowParry": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/LowParry.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 2,
			"simple": true
		}
	},
	"AirBlock": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/AirBlock.png"),
			"hframes": 2,
			"frame": 0,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 1,
			"simple": true
		}
	},
	"AirUnblock": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/AirBlock.png"),
			"hframes": 2,
			"frame": 1,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": true,
			"startFrame": 1,
			"endFrame": 0,
			"simple": true
		}
	},
	"AirBlocking": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/AirBlock.png"),
			"hframes": 2,
			"frame": 1,
		},
		"animation": {
			"frameRate": 0,
			"loop": false,
			"reverse": false,
			"startFrame": 1,
			"endFrame": 1,
			"simple": true
		}
	},
	"AirBlockstun": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/AirBlockstun.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 0,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 0,
			"simple": true
		}
	},
	"AirBlockstunEnd": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/AirBlockstun.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 1,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 2,
			"simple": true
		}
	},
	"AirParry": {
		"sprite": {
			"texture": load("res://assets/characters/Robot/Block/AirParry.png"),
			"hframes": 3,
			"frame": 0,
		},
		"animation": {
			"frameRate": 2,
			"loop": false,
			"reverse": false,
			"startFrame": 0,
			"endFrame": 2,
			"simple": true
		}
	},
}

func _ready():
	animations = ANIMATIONS
