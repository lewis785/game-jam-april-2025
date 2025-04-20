class_name PlayerSpawn
extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.visible = false
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = self.global_position
