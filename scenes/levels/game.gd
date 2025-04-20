class_name Game
extends Node2D

signal goal_reached()

func change_level(level: Level) -> void:
	for child in self.get_children():
		child.queue_free()
		await child.tree_exited
	var new_level = level.level_scene.instantiate()
	self.add_child(new_level)
	new_level.goal_reached.connect(handle_goal_reached)
	#new_level.connect("goal_reached", handle_goal_reached)

func handle_goal_reached():
	goal_reached.emit()
	
