extends Node2D

signal goal_reached()

@export var goal: Door

func _ready() -> void:
	if goal:
		goal.connect("state_changed", reached_goal)

func reached_goal(new_state: Door.STATES):
	goal_reached.emit()
