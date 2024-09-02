class_name Crop extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var grid_cell: Vector2i
var mouse_over: bool:
	set(over):
		mouse_over = over
		$Outline.visible = mouse_over and GameManager.is_crop_harvestable(GameManager.current_zone.id, grid_cell)

func _ready():
	GameManager.day_incremented.connect(update_display)

func _input(event):
	if (
		mouse_over and
		event.is_action("lmb_down") and
		event.is_action_pressed("lmb_down") and
		GameManager.is_crop_harvestable(GameManager.current_zone.id, grid_cell)
	):
		var player = GameManager.current_zone.player_character
		player.run_action(CharacterActionHarvestCrop.new(player, self))
		get_viewport().set_input_as_handled()

func place(cell: Vector2i):
	grid_cell = cell
	global_position = GameManager.current_zone.grid.get_position_by_cell(cell)
	update_display()

func update_display():
	var crop_entry = GameManager.get_crop_in_current_zone(grid_cell)
	var crop_details: CropConfigRow = GameManager.crops_dt.get_row(crop_entry.seed_id)
	if crop_details.mesh_grown:
		mesh_instance.mesh = load(crop_details.mesh_grown)
	
	var material: BaseMaterial3D = mesh_instance.get_active_material(0)
	if material:
		var emission_enabled = false
		var color = Color.WHITE
		if GameManager.is_crop_dead(GameManager.current_zone.id, grid_cell):
			emission_enabled = true
			color = Color.DARK_RED
		elif GameManager.is_crop_ripe(GameManager.current_zone.id, grid_cell):
			emission_enabled = true
			color = Color.GREEN
		material.emission_enabled = emission_enabled
		material.emission = color

func _mouse_enter():
	mouse_over = true

func _mouse_exit():
	mouse_over = false
