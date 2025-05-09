class_name LevelCoordinator
extends Node2D

var placed_items: Dictionary = {}
@export var hud: Hud
@export var player: Player
@export var game: Game
#@export var current_level: Level

func _ready() -> void:
	change_level(GameManager.current_level)

	if player:
		player.item_placed.connect(handle_item_placed)
		player.item_received.connect(handle_item_received)
	if game:
		game.goal_reached.connect(handle_goal_reached)

func change_level(level: Level):
	game.change_level(level)
	hud.remove_item()
	player.reset()

func handle_goal_reached():
	if !GameManager.current_level.next_level:
		print("run out of levels")
		return
	
	GameManager.current_level = GameManager.current_level.next_level
	change_level(GameManager.current_level)

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
	if hud:
		hud.remove_item()
	
func handle_item_received(item: Item, gifter: Gifter ):
	_remove_gifter_item(gifter)
	if hud:
		hud.change_item(item)
