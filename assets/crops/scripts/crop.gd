class_name Crop extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var grid_cell: Vector2i
var mouse_over: bool = false

func _ready():
	GameManager.day_incremented.connect(on_day_incremented)
	mesh_instance.set_surface_override_material(0, StandardMaterial3D.new())

func _process(_delta):
	if mouse_over:
		var crop_entry = Savegame.player.crops[GameManager.current_zone.id][grid_cell]
		if crop_entry.growth_score >= 100:
			$Outline.visible = true
			return
	$Outline.visible = false

func _input(event):
	if event.is_action("lmb_down") and event.is_action_pressed("lmb_down"):
		if mouse_over:
			var crop_entry = Savegame.player.crops[GameManager.current_zone.id][grid_cell]
			if crop_entry.growth_score >= 100:
				var player = GameManager.current_zone.player_character
				player.run_action(CharacterActionHarvestCrop.new(player, self))
				get_viewport().set_input_as_handled()

func initialise(cell: Vector2i, from_save: bool = true, seed_id: StringName = "none"):
	grid_cell = cell
	global_position = GameManager.current_zone.grid.get_position_by_cell(cell)
	
	if not from_save:
		var crop_zone = Savegame.player.crops.get(GameManager.current_zone.id)
		if not crop_zone:
			Savegame.player.crops[GameManager.current_zone.id] = {}
			crop_zone = Savegame.player.crops[GameManager.current_zone.id]
		const seed_table = {"sunflower_seed": "sunflower"}
		var crop_id = seed_table.get(seed_id)
		if not crop_id:
			Utils.log_error("Crops", "Unknown seed conversion for ID \"", seed_id, "\"")
			return
		crop_zone[grid_cell] = {"type": crop_id, "growth_score": 0, "days_planted": 0}
	update_display()

func on_day_incremented():
	update_display()

func update_display():
	var crop_entry = Savegame.player.crops[GameManager.current_zone.id][grid_cell]
	var material = mesh_instance.get_surface_override_material(0)
	var is_ripe = crop_entry.growth_score >= 100
	if material:
		material.albedo_color = Color(0.0, 1.0, 0.1, 1.0) if is_ripe else Color(0.7, 0.2, 0.1, 1.0)

func _mouse_enter():
	mouse_over = true

func _mouse_exit():
	mouse_over = false
