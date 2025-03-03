class_name GameWorld extends Node

@export_file("*.scn", "*.tscn") var default_transition_scene: String
@export_file("*.scn", "*.tscn") var entrypoint_scene: String
@export_file("*.scn", "*.tscn") var entrypoint_transition_scene: String

var level_args: Dictionary

@onready var scene = $CurrentScene
@onready var transition = $TransitionScene
@onready var ui = $CurrentUI

func _ready():
	GameManager.game_world = self
	load_level(entrypoint_scene, {}, entrypoint_transition_scene)

func load_level(scene_path: String, args: Dictionary = {}, transition_scene_path: String = default_transition_scene):
	Utils.log_info("Levels", "Began loading level at ", scene_path)
	var error: Error = ResourceLoader.load_threaded_request(scene_path)
	if error != OK:
		Utils.log_error("Levels", "Failed to request load of level at ", scene_path)
		return
	
	var transition_scene: TransitionScreen = ResourceLoader.load(transition_scene_path).instantiate()
	transition.add_child(transition_scene)
	transition_scene.begin_transition()
	if not transition_scene.began():
		await transition_scene.transition_began
	
	Utils.queue_free_children(scene)
	Utils.queue_free_children(ui)
	
	var timer = Timer.new()
	add_child(timer)
	
	var complete_load = func(): 
		var new_scene = ResourceLoader.load_threaded_get(scene_path).instantiate()
		level_args = args
		scene.add_child(new_scene)
		Utils.log_info("Levels", "Finished loading level \"", new_scene.name, "\"", " with args ", args)
		
		transition_scene.end_transition()
		if not transition_scene.ended():
			await transition_scene.transition_ended
		Utils.queue_free_children(transition)
	
	var check_status = func(): 
		var status = ResourceLoader.load_threaded_get_status(scene_path)
		match status:
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
				Utils.log_error("Levels", "Failed to load level at ", scene_path)
				timer.stop()
				timer.queue_free()
			ResourceLoader.THREAD_LOAD_LOADED:
				complete_load.call()
				timer.stop()
				timer.queue_free()
	
	timer.timeout.connect(check_status)
	timer.start(1.0)
