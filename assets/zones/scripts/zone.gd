class_name Zone extends Node3D

const player_character_scene = preload("res://assets/character/scenes/character.tscn")

@export var id: StringName

var game_cam: GameCamera
var grid: Grid3D

func _shortcut_input(event):
	if event.is_action_pressed("next_turn"):
		GameManager.next_turn()
		get_viewport().set_input_as_handled()

func _ready():
	game_cam = Utils.get_first_node_with_script(self, GameCamera)
	grid = Utils.get_first_node_with_script(self, Grid3D)
	GameManager.register_zone(self)
	
	var crops = Savegame.player.crops.get(id)
	
	if crops:
		for cell in crops:
			var crop = preload("res://assets/crops/scenes/crop.tscn").instantiate()
			add_child(crop)
			crop.crop_name = crops[cell].name
			crop.global_position = grid.get_position_by_cell(cell)
	
	var spawn_location: StringName = GameManager.game_world.level_args.get("spawn_location", "default")
	var spawn = find_spawn_location(spawn_location)
	if not spawn:
		Utils.log_error("Zones", "Failed to find spawner for location ", spawn_location)
		return
	var player = player_character_scene.instantiate()
	add_child(player)
	player.global_position = spawn.global_position

func find_spawn_location(spawn_location: StringName) -> ZoneSpawn:
	var spawns = Utils.get_all_nodes_with_script(self, ZoneSpawn)
	for spawn in spawns:
		if spawn.id == spawn_location:
			return spawn
	return null

func _exit_tree():
	GameManager.deregister_zone(self)
