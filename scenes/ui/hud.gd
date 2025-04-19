class_name Hud
extends Control

@onready var item_texture: TextureRect = $ColorRect/ItemTexture
@onready var item_lable: Label = $ColorRect/ItemTexture/ItemLabel

var item: Item

func _ready() -> void:
	if item == null:
		visible = false

func change_item(new_item: Item) -> void:
	visible = true
	item = new_item
	item_texture.texture = item.texture
	item_lable.text = item.name
	
func remove_item() -> void:
	visible = false
	item = null

func _on_player_item_picked_up(item: Item) -> void:
	change_item(item)


func _on_player_item_used() -> void:
	remove_item()
