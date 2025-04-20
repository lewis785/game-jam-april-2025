class_name PlaceableItem
extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var item_sprite: Sprite2D = $ItemSprite

@export var item: Item
var gifter: Gifter
var walkable: bool

func _ready() -> void:
	if item.block_line_of_sight:
		self.collision_layer = 12
	item_sprite.texture = item.texture
	walkable = item.walkable

func setup(new_item: Item, new_gifter: Gifter) -> void:
	item = new_item
	gifter = new_gifter
