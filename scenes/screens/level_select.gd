class_name LevelSelect
extends Control

@onready var level_list: VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/LevelList
const FONT = preload("res://resources/themes/font.tres")
const WORLD = preload("res://scenes/world.tscn")

@export var levels: Array[Level] = []

func _ready() -> void:
	generate_level_buttons()
	
func generate_level_buttons():
	for level in levels:
		var level_button = Button.new()
		level_button.text = level.level_name
		level_button.theme = FONT
		level_button.pressed.connect(load_game_with_level.bind(level))
		level_list.add_child(level_button)#
		
func load_game_with_level(level: Level):
	GameManager.current_level = level
	get_tree().change_scene_to_packed(WORLD)
