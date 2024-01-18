class_name Crop extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var grid_cell: Vector2i
var mouse_over: bool:
	set(over):
		mouse_over = over
		$Outline.visible = mouse_over and GameManager.is_crop_harvestable(GameManager.current_zone.id, grid_cell)

func _ready():
	GameManager.day_incremented.connect(update_display)
	mesh_instance.set_surface_override_material(0, StandardMaterial3D.new())

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
	var material = mesh_instance.get_surface_override_material(0)
	if material:
		var color = Color.WHITE
		if GameManager.is_crop_dead(GameManager.current_zone.id, grid_cell):
			color = Color.DARK_RED
		elif GameManager.is_crop_ripe(GameManager.current_zone.id, grid_cell):
			color = Color.GREEN
		material.albedo_color = color

func _mouse_enter():
	mouse_over = true

func _mouse_exit():
	mouse_over = false
