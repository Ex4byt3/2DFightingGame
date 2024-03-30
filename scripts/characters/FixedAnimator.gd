extends Node
class_name FixedAnimator

# nodes to animate
@onready var sprite = get_parent().get_node("Sprite")
@onready var hurtBox = get_parent().get_node("HurtBox").get_node("SGCollisionShape2D")

# animation data
var frame : int = 0
var animations : Dictionary = {}
var current : Dictionary = {}
var playing : bool = false
var counter : int = 0 # for complex animations
var animationsQueue : Array = []

func _game_process() -> void:
	if playing:
		if current["animation"]["simple"]:
			if frame >= current["animation"]["frameRate"]:
				if current["animation"]["reverse"] and sprite.frame > current["animation"]["endFrame"]:
						sprite.frame -= 1
				elif sprite.frame < current["animation"]["endFrame"]:
						sprite.frame += 1
				frame = 0
				if sprite.frame == current["animation"]["endFrame"]:
					if current["animation"]["loop"]:
						sprite.frame = current["animation"]["startFrame"]
					else:
						playing = false
						if animationsQueue:
							play(animationsQueue.pop_front())
				# TODO: hurtbox updates			
			else:
				frame += 1
		elif frame >= current["frames"][counter]["frames"]:
			if counter > len(current["frames"]) - 1:
				if current["animation"]["loop"]:
					counter = 0
				else:
					playing = false
					if animationsQueue:
						play(animationsQueue.pop_front())
			else:
				for property in current["frames"][counter]["sprite"]:
					sprite.set(property, current["frames"][counter]["sprite"][property])
				counter += 1
			frame = 0
		else:
			frame += 1
	
		update_hurtbox()

func update_hurtbox() -> void:
	if current.has("hurtbox"):
		hurtBox.shape.extents.x = current["hurtbox"]["shape"]["extents_x"]
		hurtBox.shape.extents.y = current["hurtbox"]["shape"]["extents_y"]
		hurtBox.fixed_position.x = current["hurtbox"]["fixed_position_x"]
		hurtBox.fixed_position.y = current["hurtbox"]["fixed_position_y"]

func stop() -> void:
	playing = false	

func play(animationName: String) -> void:
	animationsQueue = []
	if animationName in animations:
		if current != animations[animationName]:
			current = animations[animationName]
			counter = 0
			frame = 0
			for property in current["sprite"]:
				sprite.set(property, current["sprite"][property])
		playing = true
	else:
		print("[ERROR] Animation not found: " + animationName)

func queue(animationName: String) -> void:
	if animationName in animations:
		animationsQueue.append(animationName)
	else:
		print("[ERROR] Animation not found: " + animationName)

func _save_state() -> Dictionary:
	var animations_queue : Array = []
	for animation in animationsQueue:
		animations_queue.append(animation)
	return {
		"playing": playing,
		"frame": frame,
		"current": current,
		"counter": counter,
		"animationsQueue": animations_queue,

		"sprite": {
			"texture": sprite.texture,
			"frame": sprite.frame,
			"hframes": sprite.hframes
		},

		"hurtbox": {
			"shape": {
				"extents_x": hurtBox.shape.extents.x,
				"extents_y": hurtBox.shape.extents.y
			},
				"fixed_position_x": hurtBox.fixed_position.x,
				"fixed_position_y": hurtBox.fixed_position.y
		},
	}

func _load_state(loadState: Dictionary) -> void:
	playing = loadState["playing"]
	frame = loadState["frame"]
	current = loadState["current"]
	counter = loadState["counter"]
	animationsQueue = []
	for animation in loadState["animationsQueue"]:
		animationsQueue.append(animation)

	sprite.texture = loadState["sprite"]["texture"]
	sprite.frame = loadState["sprite"]["frame"]
	sprite.hframes = loadState["sprite"]["hframes"]

	hurtBox.shape.extents.x = loadState["hurtbox"]["shape"]["extents_x"]
	hurtBox.shape.extents.y = loadState["hurtbox"]["shape"]["extents_y"]
	hurtBox.fixed_position.x = loadState["hurtbox"]["fixed_position_x"]
	hurtBox.fixed_position.y = loadState["hurtbox"]["fixed_position_y"]

