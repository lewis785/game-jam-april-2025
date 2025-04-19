class_name LevelCoordinator
extends Node2D

var placed_items: Dictionary = {}

func _add_placed_item(gifter: Gifter, placeable_item: PlaceableItem): 
	placed_items.set(str(gifter.get_instance_id()), placeable_item)
	
func _remove_gifter_item(gifter: Gifter) -> void:
	var gifter_id = str(gifter.get_instance_id())
	
	if !placed_items.has(gifter_id):
		return
	
	var placed_item: PlaceableItem = placed_items.get(gifter_id)
	placed_item.queue_free()
	placed_items.erase(gifter_id)

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.connect("item_placed", handle_item_placed)
	player.connect("item_received", handle_item_received)
	
func handle_item_placed(placed_item: PlaceableItem, gifter: Gifter):
	_add_placed_item(gifter, placed_item)
	
func handle_item_received(gifter: Gifter, item: Item):
	print("Received Item")
	_remove_gifter_item(gifter)
