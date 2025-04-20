class_name Hud
extends Control

@onready var item_texture: TextureRect = $ColorRect/ItemTexture
@onready var item_lable: Label = $ColorRect/ItemTexture/ItemLabel

var item: Item

func change_item(new_item: Item) -> void:
	item = new_item
	item_texture.texture = item.texture
	item_lable.text = item.name
	
func remove_item() -> void:
	item = null
	if item_texture:
		item_texture.texture = null
	if item_lable:
		item_lable.text = ""
