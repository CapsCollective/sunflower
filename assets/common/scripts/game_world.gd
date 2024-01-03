class_name GameWorld extends Node

@export_file("*.scn", "*.tscn") var default_transition_scene: String
@export_file("*.scn", "*.tscn") var entrypoint_scene: String

func _ready():
	GameManager.game_world = self
	load_level(entrypoint_scene)

func load_level(scene_path: String, _transition_scene: String = default_transition_scene):
	Utils.log_info("Levels", "Began loading level at ", scene_path)
	var new_scene = ResourceLoader.load(scene_path).instantiate()
	for child in $CurrentScene.get_children():
		child.queue_free()
	$CurrentScene.add_child(new_scene)
	Utils.log_info("Levels", "Finished loading level \"", new_scene.name, "\"")
