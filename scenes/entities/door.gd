class_name Door
extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

enum STATES { OPEN, CLOSED, LOCKED }

@export var state: STATES = STATES.LOCKED

signal state_changed(new_state: STATES)

func unlock() -> void:
	_update_state(STATES.OPEN)

func lock() -> void:
	_update_state(STATES.LOCKED)

func _update_state(new_state: STATES) -> void:
	if state == new_state:
		return
	
	if state == STATES.LOCKED:
		self.collision_layer = 4
	
	match new_state:
		STATES.LOCKED:
			sprite_2d.visible = true
			self.collision_layer = 12
		STATES.OPEN:
			sprite_2d.visible = false
		STATES.CLOSED:
			sprite_2d.visible = true
		
	state_changed.emit(new_state)
	state = new_state
