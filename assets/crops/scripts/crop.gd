class_name Crop extends StaticBody3D

const RADIUS: int = 1

var crop_name: String
var grid_position: Vector2i

var growth_score: int
var days_planted: int

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready():
	GameManager.day_incremented.connect(on_day_incremented)
	mesh_instance.set_surface_override_material(0, StandardMaterial3D.new())
	growth_score = 0
	days_planted = 0

func initialise(target_crop_name: String, global_pos: Vector3, target_grid_position: Vector2i, target_growth_score: int, target_days_planted: int):
	crop_name = target_crop_name
	grid_position = target_grid_position
	growth_score = target_growth_score
	days_planted = target_days_planted
	global_position = global_pos
	set_crop_color()
	serialise()

func on_day_incremented():
	days_planted += 1
	growth_score = clamp(days_planted * 20, 0, 100)
	set_crop_color()
	serialise()

func set_crop_color():
	if growth_score >= 100:
		var material = mesh_instance.get_surface_override_material(0)
		if material:
			print("MATERIAL")
			material.albedo_color = Color(0.0, 1.0, 0.1, 1.0)

func serialise():
	var zone_crops = Savegame.player.crops.get(GameManager.current_zone.id, null)
	
	if not zone_crops:
		Savegame.player.crops[GameManager.current_zone.id] = {}
		zone_crops = Savegame.player.crops[GameManager.current_zone.id]
	
	zone_crops[grid_position] = {"name": crop_name, "growth_score": growth_score, "days_planted": days_planted}
	Savegame.save_file()
