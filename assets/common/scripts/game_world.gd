class_name GameWorld extends Node

@export_file("*.scn", "*.tscn") var default_transition_scene: String
@export_file("*.scn", "*.tscn") var entrypoint_scene: String

var level_args: Dictionary

@onready var ui = $CurrentUI

func _ready():
	GameManager.game_world = self
	load_level(entrypoint_scene)

func load_level(scene_path: String, args: Dictionary = {}, _transition_scene: String = default_transition_scene):
	Utils.log_info("Levels", "Began loading level at ", scene_path)
	var new_scene = ResourceLoader.load(scene_path).instantiate()
	Utils.queue_free_children($CurrentScene)
	Utils.queue_free_children(ui)
	level_args = args
	$CurrentScene.add_child(new_scene)
	Utils.log_info("Levels", "Finished loading level \"", new_scene.name, "\"", " with args ", args)
