extends Node
class_name FixedAnimator

# nodes to animate
@onready var sprite = get_parent().get_node("AnimatedSprite2D")
@onready var hurtBox = get_parent().get_node("HurtBox").get_node("SGCollisionShape2D")

# animation data
var tick : int = 0
var animations : Dictionary = {}
var current : String = ""
var playing : bool = false
var counter : int = 0 # for complex animations
var animationsQueue : Array = []

func _game_process() -> void:
	if playing:
		if animations[current]["animation"]["simple"]:
			sprite.frame = tick / animations[current]["animation"]["framerate"] % animations[current]["animation"]["frameCount"]
			tick += 1
			if tick >= animations[current]["animation"]["frameCount"] * animations[current]["animation"]["framerate"]:
				if animations[current]["animation"]["loop"]:
					tick = 0
				else:
					playing = false
					if animationsQueue:
						play(animationsQueue.pop_front())
		else:
			if tick > animations[current]["frames"][counter]["ticks"]:
				tick = 0
				counter += 1
				sprite.frame = counter
				print("frame: " + str(counter))
				# TODO: animate other advnaced properties
			else:
				tick += 1

			if counter > animations[current]["frames"].size() - 1:
				if animations[current]["animation"]["loop"]:
					counter = 0
					tick = 0
				else:
					playing = false
					if animationsQueue:
						play(animationsQueue.pop_front())


		# if current["animation"]["simple"]:
		# 	if tick >= current["animation"]["frameRate"]:
		# 		if current["animation"]["reverse"] and sprite.frame > current["animation"]["endFrame"]:
		# 				sprite.frame -= 1
		# 		elif sprite.frame < current["animation"]["endFrame"]:
		# 				sprite.frame += 1
		# 		tick = 0
		# 		
		# 		# TODO: hurtbox updates			
		# 	else:
		# 		tick += 1
		# elif tick >= current["frames"][counter]["frames"]:
		# 	if counter > len(current["frames"]) - 1:
		# 		if current["animation"]["loop"]:
		# 			counter = 0
		# 		else:
		# 			playing = false
		# 			if animationsQueue:
		# 				play(animationsQueue.pop_front())
		# 	else:
		# 		for property in current["frames"][counter]["sprite"]:
		# 			sprite.set(property, current["frames"][counter]["sprite"][property])
		# 		counter += 1
		# 	tick = 0
		# else:
		# 	tick += 1
	
		# sprite.frame = frame
		update_hurtbox()

func update_hurtbox() -> void:
	if animations[current].has("hurtbox"):
		hurtBox.shape.extents.x = animations[current]["hurtbox"]["shape"]["extents_x"]
		hurtBox.shape.extents.y = animations[current]["hurtbox"]["shape"]["extents_y"]
		hurtBox.fixed_position.x = animations[current]["hurtbox"]["fixed_position_x"]
		hurtBox.fixed_position.y = animations[current]["hurtbox"]["fixed_position_y"]

func stop() -> void:
	playing = false	

func play(animationName: String) -> void:
	animationsQueue = []
	if animationName in animations:
		if current != animationName:
			current = animationName
			counter = 0
			tick = 0
			sprite.play(animationName)
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
		"tick": tick,
		"current": current,
		"counter": counter,
		"animationsQueue": animations_queue,

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
	tick = loadState["tick"]
	current = loadState["current"]
	sprite.play(current)
	counter = loadState["counter"]
	animationsQueue = []
	for animation in loadState["animationsQueue"]:
		animationsQueue.append(animation)

	hurtBox.shape.extents.x = loadState["hurtbox"]["shape"]["extents_x"]
	hurtBox.shape.extents.y = loadState["hurtbox"]["shape"]["extents_y"]
	hurtBox.fixed_position.x = loadState["hurtbox"]["fixed_position_x"]
	hurtBox.fixed_position.y = loadState["hurtbox"]["fixed_position_y"]

	#sprite.set_frame(tick / animations[current]["animation"]["framerate"] % animations[current]["animation"]["frameCount"])

