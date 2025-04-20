class_name LevelCoordinator
extends Node2D

var placed_items: Dictionary = {}
#@export var level_node: Node
@export var current_level: Level
@export var game: Game

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("item_placed", handle_item_placed)
		player.connect("item_received", handle_item_received)
	if current_level:
		change_level(current_level)
	if game:
		game.connect("goal_reached", handle_goal_reached)

func change_level(level: Level):
	game.change_level(level)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("item_placed", handle_item_placed)
		player.connect("item_received", handle_item_received)

func handle_goal_reached():
	if !current_level.next_level:
		print("run out of levels")
		return
	
	current_level = current_level.next_level
	change_level(current_level)

func _add_placed_item(gifter: Gifter, placeable_item: PlaceableItem): 
	placed_items.set(str(gifter.get_instance_id()), placeable_item)
	
func _remove_gifter_item(gifter: Gifter) -> void:
	var gifter_id = str(gifter.get_instance_id())
	
	if !placed_items.has(gifter_id):
		return
	
	var placed_item: PlaceableItem = placed_items.get(gifter_id)
	placed_item.queue_free()
	placed_items.erase(gifter_id)
	
func handle_item_placed(placed_item: PlaceableItem, gifter: Gifter):
	_add_placed_item(gifter, placed_item)
	
func handle_item_received(gifter: Gifter, item: Item):
	_remove_gifter_item(gifter)
