class_name PlaceableItem
extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var item_sprite: Sprite2D = $ItemSprite

@export var item: Item

func _ready() -> void:
	if item.block_line_of_sight:
		area_2d.collision_layer = 6
	item_sprite.texture = item.texture
