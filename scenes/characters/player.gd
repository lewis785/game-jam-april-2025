class_name Player
extends StaticBody2D

@export var tile_map: TileMapLayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var object_ray_cast: RayCast2D = $ObjectRayCast

var rock: Item = preload("res://resources/items/rock.tres")
var placeable_item_scene: PackedScene = preload("res://scenes/entities/placeable_item.tscn")

var facing: Vector2
var last_gifter: Gifter
var item: Item

enum STATES { IDLE, MOVING, WAITING }
@export var state: STATES = STATES.IDLE

signal item_received(gifter: Gifter, item: Item)
signal item_used()
signal item_placed(placed_item: PlaceableItem, gifter: Gifter)

func _process(delta: float) -> void:
	if (state != STATES.IDLE):
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

func _update_state(new_state: STATES) -> void:
	if state == new_state:
		return
	state = new_state

func _physics_process(delta: float) -> void:
	if state == STATES.IDLE:
		return
	
	if state == STATES.MOVING && global_position == sprite_2d.global_position:
		_update_state(STATES.IDLE)
		return
	
	sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 1)	

func start_interaction():
	_update_state(STATES.WAITING)

func receive_item(new_item: Item, gifter: Gifter) -> void:
	item = new_item
	last_gifter = gifter
	item_received.emit(gifter, item)
	_update_state(STATES.IDLE)
	
func place_item() -> void:
	if item == null || !item.placeable:
		return
	
	if object_ray_cast.is_colliding():
		return
	
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	var target_tile = Vector2i(
		current_tile.x + facing.x,
		current_tile.y + facing.y
	)
	
	var placeable_item: PlaceableItem = placeable_item_scene.instantiate()
	placeable_item.setup(item, last_gifter)
	placeable_item.global_position = tile_map.map_to_local(target_tile)
	
	if facing == Vector2.RIGHT || facing == Vector2.LEFT:
		placeable_item.rotate(deg_to_rad(90))
		
	get_parent().add_child(placeable_item)
		
	item_placed.emit(placeable_item, last_gifter)
	item = null
	last_gifter = null
	item_used.emit()
	
	
func move(direction: Vector2):
	
	facing = direction
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	var target_tile = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	
	ray_cast_2d.target_position = direction * 16
	object_ray_cast.target_position = direction * 16
	ray_cast_2d.force_raycast_update()
	ray_cast_2d.force_raycast_update()
	
	open_door()
	if !can_walk_on():
		return
	
	_update_state(STATES.MOVING)
	global_position = tile_map.map_to_local(target_tile)
	sprite_2d.global_position = tile_map.map_to_local(current_tile)

func can_walk_on():
	if !ray_cast_2d.is_colliding():
		return true
		
	if !object_ray_cast.is_colliding():
		return false
		
	var object = object_ray_cast.get_collider()

	print(object)
	if object is not PlaceableItem:
		print("Not object")
		return false
		
	return object.walkable
		
	
func open_door():
	if !item || item.name != "Key":
		return
	
	if !object_ray_cast.is_colliding():
		return
		
	var object = object_ray_cast.get_collider()
	
	if object is not Door:
		return
		
	object.unlock()
	item = null
	last_gifter = null
	item_used.emit()
	
