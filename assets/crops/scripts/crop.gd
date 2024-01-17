class_name Crop extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

const GROWTH_REQUIRED = 1

var grid_cell: Vector2i
var mouse_over: bool:
	set(over):
		mouse_over = over
		$Outline.visible = mouse_over and (is_ripe() or is_dead())

func _ready():
	GameManager.day_incremented.connect(update_display)
	mesh_instance.set_surface_override_material(0, StandardMaterial3D.new())

func _input(event):
	if mouse_over and event.is_action("lmb_down") and event.is_action_pressed("lmb_down") and (is_dead() or is_ripe()):
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
		if is_dead():
			color = Color.DARK_RED
		elif is_ripe():
			color = Color.GREEN
		material.albedo_color = color

func is_ripe():
	var crop_entry = GameManager.get_crops_in_current_zone()[grid_cell]
	return crop_entry.growth >= GROWTH_REQUIRED

func is_dead():
	var crop_entry = GameManager.get_crops_in_current_zone()[grid_cell]
	return crop_entry.health == 0

func _mouse_enter():
	mouse_over = true

func _mouse_exit():
	mouse_over = false
