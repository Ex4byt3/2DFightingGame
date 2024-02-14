extends StateMachine
var parent = get_parent()
var character_node := get_parent()

var ONE = SGFixed.ONE

var direction_mapping = {
	[1, 1]: "UP RIGHT", # 9
	[1, 0]: "RIGHT", # 6
	[0, 1]: "UP", # 8
	[0, -1]: "DOWN", # 2
	[1, -1]: "DOWN RIGHT", # 3
	[-1, -1]: "DOWN LEFT", # 1
	[-1, 0]: "LEFT", # 4
	[-1, 1]: "UP LEFT" # 7
}

func _ready():
	add_state('IDLE')
	add_state('AIR')
	add_state('CROUCHING')
	add_state('WALKING')
	add_state('SPRINTING')
	add_state('DASHING')
	add_state('JUMPSQUAT')
	add_state('JUMPING')
	add_state('FALLING')
	add_state('ATTACKING')
	add_state('BLOCKING')
	add_state('HITSTUN')
	add_state('DEAD')
	add_state('NEUTRAL_L')
	add_state('NEUTRAL_M')
	add_state('NEUTRAL_H')
	add_state('FORWARD_L')
	add_state('FORWARD_M')
	add_state('FORWARD_H')
	add_state('DOWN_L')
	add_state('DOWN_M')
	add_state('DOWN_H')
	set_state('IDLE')

func transition_state(input: Dictionary):
	# Get input vector
	var input_vector = SGFixed.vector2(input.get("input_vector_x", 0), input.get("input_vector_y", 0))
	
	# Updating debug label
	update_debug_label(input_vector)
	
	# Updating input buffer
	update_input_buffer(input_vector)
	
	match state:
		states.IDLE:
			pass
		states.AIR:
			pass
		states.CROUCHING:
			pass
		states.WALKING:
			pass
		states.SPRINTING:
			pass
		states.DASHING:
			pass
		states.JUMPSQUAT:
			pass
		states.JUMPING:
			pass
		states.FALLING:
			pass
		states.ATTACKING:
			pass
		states.BLOCKING:
			pass
		states.HITSTUN:
			pass
		states.DEAD:
			pass
		states.NEUTRAL_L:
			pass
		states.NEUTRAL_M:
			pass
		states.NEUTRAL_H:
			pass
		states.FORWARD_L:
			pass
		states.FORWARD_M:
			pass
		states.FORWARD_H:
			pass
		states.DOWN_L:
			pass
		states.DOWN_M:
			pass
		states.DOWN_H:
			pass

func enter_state(new_state, old_state):
	match new_state:
		states.IDLE:
			parent.states.text = str('IDLE')
		states.AIR:
			parent.states.text = str('AIR')
		states.CROUCHING:
			parent.states.text = str('CROUCHING')
		states.WALKING:
			parent.states.text = str('WALKING')
		states.SPRINTING:
			parent.states.text = str('SPRINTING')
		states.DASHING:
			parent.states.text = str('DASHING')
		states.JUMPSQUAT:
			parent.states.text = str('JUMPSQUAT')
		states.JUMPING:
			parent.states.text = str('JUMPING')
		states.FALLING:
			parent.states.text = str('FALLING')
		states.ATTACKING:
			parent.states.text = str('ATTACKING')
		states.BLOCKING:
			parent.states.text = str('BLOCKING')
		states.HITSTUN:
			parent.states.text = str('HITSTUN')
		states.DEAD:
			parent.states.text = str('DEAD')
		states.NEUTRAL_L:
			parent.states.text = str('NEUTRAL_L')
		states.NEUTRAL_M:
			parent.states.text = str('NEUTRAL_M')
		states.NEUTRAL_H:
			parent.states.text = str('NEUTRAL_H')
		states.FORWARD_L:
			parent.states.text = str('FORWARD_L')
		states.FORWARD_M:
			parent.states.text = str('FORWARD_M')
		states.FORWARD_H:
			parent.states.text = str('FORWARD_H')
		states.DOWN_L:
			parent.states.text = str('DOWN_L')
		states.DOWN_M:
			parent.states.text = str('DOWN_M')
		states.DOWN_H:
			parent.states.text = str('DOWN_H')

func update_debug_label(input_vector):
	var debugLabel = character_node.get_parent().get_node("DebugOverlay").get_node(character_node.name + "DebugLabel")
	if self.name == "ServerPlayer":
		debugLabel.text = "PLAYER ONE DEBUG:\nPOSITION: " + str(character_node.fixed_position.x / ONE) + ", " + str(character_node.fixed_position.y / ONE) + "\nVELOCITY: " + str(character_node.velocity.x / ONE) + ", " + str(character_node.velocity.y / ONE) + "\nINPUT VECTOR: " + str(input_vector.x / ONE) + ", " + str(input_vector.y / ONE) + "\nSTATE: " + str(state)
	else:
		debugLabel.text = "PLAYER TWO DEBUG:\nPOSITION: " + str(character_node.fixed_position.x / ONE) + ", " + str(character_node.fixed_position.y / ONE) + "\nVELOCITY: " + str(character_node.velocity.x / ONE) + ", " + str(character_node.velocity.y / ONE) + "\nINPUT VECTOR: " + str(input_vector.x / ONE) + ", " + str(input_vector.y / ONE) + "\nSTATE: " + str(state)
	
func update_input_buffer(input_vector):
	var inputBuffer = character_node.get_parent().get_node("DebugOverlay").get_node(character_node.name + "InputBuffer")
	if character_node.controlBuffer.size() > 20:
		character_node.controlBuffer.pop_back()
	
	if character_node.controlBuffer.front()[0] == input_vector.x/ONE and character_node.controlBuffer.front()[1] == input_vector.y/ONE:
		var ticks = character_node.controlBuffer.front()[2]
		character_node.controlBuffer.pop_front()
		character_node.controlBuffer.push_front([input_vector.x/ONE, input_vector.y/ONE, ticks+1])
	else:
		character_node.controlBuffer.push_front([input_vector.x/ONE, input_vector.y/ONE, 1])
	
	if self.name == "ServerPlayer":
		inputBuffer.text = "PLAYER ONE INPUT BUFFER:\n"
	else:
		inputBuffer.text = "PLAYER TWO INPUT BUFFER:\n"
	
	for item in character_node.controlBuffer:
		var direction = direction_mapping.get([item[0], item[1]], "NEUTRAL")
		inputBuffer.text += str(direction) + " " + str(item[2]) + " TICKS\n"
