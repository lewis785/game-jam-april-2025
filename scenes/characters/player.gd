class_name Player
extends StaticBody2D

#@export var tile_map: TileMapLayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var object_ray_cast: RayCast2D = $ObjectRayCast

var placeable_item_scene: PackedScene = preload("res://scenes/entities/placeable_item.tscn")

var facing: Vector2
var last_gifter: Gifter
var item: Item
var tile_map: TileMapLayer

enum STATES { IDLE, MOVING, WAITING }
@export var state: STATES = STATES.IDLE
@export var sprite_front: Texture2D
@export var sprite_back: Texture2D

signal item_received(item: Item, gifter: Gifter)
signal item_removed(item: Item, gifter: Gifter)
signal item_placed(placed_item: PlaceableItem, gifter: Gifter)

func _ready() -> void:
	sprite_2d.texture = sprite_front

func _process(_delta: float) -> void:
	tile_map = get_tree().get_first_node_in_group("tile_map")
	
	if (state != STATES.IDLE):
		return
	
	if Input.is_action_pressed("up"):
		move_animation(facing, Vector2.UP)
		move(Vector2.UP)
	elif Input.is_action_pressed("down"):
		move_animation(facing, Vector2.DOWN)
		move(Vector2.DOWN)
	elif Input.is_action_pressed("left"):
		move_animation(facing, Vector2.LEFT)
		move(Vector2.LEFT)
	elif Input.is_action_pressed("right"):
		move_animation(facing, Vector2.RIGHT)
		move(Vector2.RIGHT)
	elif Input.is_action_pressed("use"):
		place_item()

func _update_state(new_state: STATES) -> void:
	if state == new_state:
		return
	state = new_state

func _physics_process(_delta: float) -> void:
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
	item_received.emit(item, gifter)
	_update_state(STATES.IDLE)
	
func place_item() -> void:
	if item == null || !item.placeable:
		return
	
	if object_ray_cast.is_colliding():
		return
	
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	var target_tile = Vector2i(
		floori(current_tile.x + facing.x),
		floori(current_tile.y + facing.y)
	)

	var tile_data:TileData = tile_map.get_cell_tile_data(target_tile)
	
	if !tile_data || tile_data.get_custom_data("placeable") == false:
		return
	
	var placeable_item: PlaceableItem = placeable_item_scene.instantiate()
	placeable_item.setup(item, last_gifter)
	placeable_item.global_position = tile_map.map_to_local(target_tile)
	
	if facing == Vector2.RIGHT || facing == Vector2.LEFT:
		placeable_item.rotate(deg_to_rad(90))
		
	get_tree().get_first_node_in_group("game_world").add_child(placeable_item)
		
	item_placed.emit(placeable_item, last_gifter)
	item = null
	item_removed.emit(item, last_gifter)
	await get_tree().create_timer(0.5).timeout
	last_gifter = null

func move_animation(existing_direction: Vector2, new_direction: Vector2) -> void:
	if existing_direction == new_direction:
		return
	
	if new_direction == Vector2.RIGHT || new_direction == Vector2.DOWN:
		sprite_2d.texture = sprite_front
		sprite_2d.flip_h = false
	
	if new_direction == Vector2.LEFT:
		sprite_2d.texture = sprite_front
		sprite_2d.flip_h = true
	
	if new_direction == Vector2.UP:
		sprite_2d.texture = sprite_back
		sprite_2d.flip_h = false
	
func move(direction: Vector2):
	facing = direction
	var current_tile: Vector2 = global_position
	var target_tile = Vector2(
		global_position.x + (direction.x * 16),
		global_position.y + (direction.y * 16)
	)
	
	ray_cast_2d.target_position = direction * 16
	object_ray_cast.target_position = direction * 16
	ray_cast_2d.force_raycast_update()
	object_ray_cast.force_raycast_update()
	
	open_door()
	if !can_walk_on():
		return
	
	_update_state(STATES.MOVING)
	global_position = target_tile
	sprite_2d.global_position = current_tile

func can_walk_on():
	if !ray_cast_2d.is_colliding():
		return true
		
	if !object_ray_cast.is_colliding():
		return false
		
	var object = object_ray_cast.get_collider()

	if object is not PlaceableItem:
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
	item_removed.emit(item, last_gifter)
	item = null
	last_gifter = null
	
func reset() -> void:
	item_removed.emit(item, last_gifter)
	item = null
	last_gifter = null
	tile_map = get_tree().get_first_node_in_group("tile_map")
	facing = Vector2.DOWN
	if sprite_2d:
		move_animation(Vector2.UP, Vector2.DOWN)
	_update_state(STATES.IDLE)
	
