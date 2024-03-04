extends Node2D


onready var map_holder = preload("res://scenes/maps/MapHolder.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_connecting_signals()


func _handle_connecting_signals() -> void:
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "start_match", "_start_match")
	MenuSignalBus._connect_Signals(MenuSignalBus, self, "leave_match", "_leave_match")


func _start_match() -> void:
	var new_match = map_holder.instance()
	add_child(new_match)


func _leave_match() -> void:
	SyncManager.stop()
	for child in get_children():
		child.queue_free()
