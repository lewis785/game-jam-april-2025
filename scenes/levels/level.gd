extends Node2D

signal goal_reached()

@export var goal: Door

func _ready() -> void:
	if goal:
		goal.state_changed.connect(reached_goal)

func reached_goal(_new_state: Door.STATES):
	goal_reached.emit()
