class_name Crop extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var grid_cell: Vector2i

func _ready():
	GameManager.day_incremented.connect(on_day_incremented)
	mesh_instance.set_surface_override_material(0, StandardMaterial3D.new())

func initialise(cell: Vector2i, from_save: bool = true, crop_type: StringName = "none"):
	grid_cell = cell
	global_position = GameManager.current_zone.grid.get_position_by_cell(cell)
	
	if not from_save:
		var crop_zone = Savegame.player.crops.get(GameManager.current_zone.id)
		if not crop_zone:
			Savegame.player.crops[GameManager.current_zone.id] = {}
			crop_zone = Savegame.player.crops[GameManager.current_zone.id]
		crop_zone[grid_cell] = {"type": crop_type, "growth_score": 0, "days_planted": 0}
		Savegame.save_file()
	update_display()

func on_day_incremented():
	update_display()

func update_display():
	var crop_entry = Savegame.player.crops[GameManager.current_zone.id][grid_cell]
	if crop_entry.growth_score >= 100:
		var material = mesh_instance.get_surface_override_material(0)
		if material:
			material.albedo_color = Color(0.0, 1.0, 0.1, 1.0)
