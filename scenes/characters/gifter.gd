class_name Gifter
extends Node2D

@onready var object_ray_cast: RayCast2D = $ObjectRayCast
@onready var player_ray_cast: RayCast2D = $PlayerRayCast
@onready var sprite_2d: Sprite2D = $Sprite2D

enum STATES { IDLE , WAIT_FOR_PLAYER, MOVE_TO_PLAYER, GIVE_ITEM,  MOVE_TO_HOME }
var state: STATES = STATES.IDLE

@export var tile_map: TileMapLayer
@export var npc: Npc
@export_enum("UP", "DOWN", "LEFT", "RIGHT" ) var facing: String = "DOWN"
@export_range(0, 16, 1.0, "Block range gifter can see too") var block_range: int = 8

var starting_position: Vector2
var target_position: Vector2
var facing_vector: Vector2
var item: Item

func _ready() -> void:
	sprite_2d.texture = npc.texture
	item = npc.item
	starting_position = global_position
	target_position = global_position
	setup_direction()
	
func _physics_process(delta: float) -> void:
	if state != STATES.MOVE_TO_PLAYER && state != STATES.MOVE_TO_HOME:
		return
	
	if target_position == global_position:
		return
			
	global_position = global_position.move_toward(target_position, 1)
	
func _process(delta: float) -> void:
	match(state):
		STATES.IDLE:
			check_vision()
		STATES.WAIT_FOR_PLAYER:
			check_player_stopped()
		STATES.MOVE_TO_PLAYER:
			move_to_player()
		STATES.GIVE_ITEM:
			give_item()
		STATES.MOVE_TO_HOME:
			move_to_home()

func setup_direction():
	match(facing):
		"UP": facing_vector = Vector2.UP
		"DOWN": facing_vector = Vector2.DOWN
		"LEFT": facing_vector = Vector2.LEFT
		"RIGHT": facing_vector = Vector2.RIGHT
	
	player_ray_cast.target_position = facing_vector * block_range * 16
	object_ray_cast.target_position = facing_vector * block_range * 16

func check_vision():
	
	if !player_ray_cast.is_colliding():
		return

	if object_ray_cast.is_colliding():		
		var player_distance: float = player_ray_cast.global_transform.origin.distance_to(player_ray_cast.get_collision_point())
		var object_distance: float = object_ray_cast.global_transform.origin.distance_to(object_ray_cast.get_collision_point())
		if player_distance - object_distance > 0 :
			return
			
	var player: Player = player_ray_cast.get_collider()	
	if player is not Player || player.last_gifter == self:
		return
	
	var player_grid_position = tile_map.local_to_map(player.global_position)
	var target_grid_position = player_grid_position + (Vector2i(facing_vector) * -1)
	
	target_position = tile_map.map_to_local(target_grid_position)
	player.start_interaction()
	state = STATES.WAIT_FOR_PLAYER

func check_player_stopped():
	var player: Player = player_ray_cast.get_collider()
	if player.state == player.STATES.WAITING:
		state = STATES.MOVE_TO_PLAYER
	

func move_to_player():
	if global_position == target_position:
		state = STATES.GIVE_ITEM

func give_item():	
	var player: Player = get_tree().get_first_node_in_group("player")
	player.receive_item(item, self)
	target_position = starting_position
	state = STATES.MOVE_TO_HOME
	
func move_to_home():
	if global_position == target_position:
		state = STATES.IDLE
