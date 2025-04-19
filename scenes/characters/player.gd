class_name Player
extends Node2D

@export var tile_map: TileMap
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var rock: Item = preload("res://resources/items/rock.tres")
var placeable_item_scene: PackedScene = preload("res://scenes/entities/placeable_item.tscn")

var facing: Vector2
var item: Item

var is_moving = false

signal item_picked_up(item: Item)
signal item_used()

func _process(delta: float) -> void:
	if (is_moving):
		return
	
	if Input.is_action_pressed("up"):
		move(Vector2.UP)
	elif Input.is_action_pressed("down"):
		move(Vector2.DOWN)
	elif Input.is_action_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_pressed("right"):
		move(Vector2.RIGHT)
	elif Input.is_action_pressed("use"):
		place_item()

func _physics_process(delta: float) -> void:
	if is_moving == false:
		return
	
	if global_position == sprite_2d.global_position:
		is_moving = false
		return
	
	sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 1)	

func recieve_item(new_item: Item) -> void:
	item = new_item
	item_picked_up.emit(item)
	
func place_item() -> void:
	if item == null || !item.placeable:
		return
	
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	var target_tile = Vector2i(
		current_tile.x + facing.x,
		current_tile.y + facing.y
	)
	
	var placeable_item: PlaceableItem = placeable_item_scene.instantiate()
	placeable_item.item = item
	placeable_item.global_position = tile_map.map_to_local(target_tile)
	
	get_parent().add_child(placeable_item)
	item = null
	item_used.emit()
	
	
func move(direction: Vector2):
	facing = direction
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	var target_tile = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	
	ray_cast_2d.target_position = direction * 16
	ray_cast_2d.force_raycast_update()
	
	if ray_cast_2d.is_colliding():
		return
	
	is_moving = true
	global_position = tile_map.map_to_local(target_tile)
	sprite_2d.global_position = tile_map.map_to_local(current_tile)
	recieve_item(rock)
