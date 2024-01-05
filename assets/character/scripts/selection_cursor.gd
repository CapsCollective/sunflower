class_name SelectionCursor extends MeshInstance3D

var enabled: bool:
	set(v):
		enabled = v
		var material = get_surface_override_material(0)
		if material:
			material.albedo_color = Color(1.0, 1.0, 1.0, 0.15) if enabled else Color(1.0, 0.0, 0.0, 0.15)

var cell_select_predicate: Callable
var run_action_callback: Callable

func _process(_delta):
	if visible:
		var pos = Utils.get_perspective_collision_ray_point(self, false, 2)
		if pos:
			var grid: Grid3D = GameManager.current_zone.grid
			var quantised_pos = grid.get_quantised_position(pos)
			global_position = quantised_pos
			var cell = grid.get_cell_by_position(quantised_pos)
			enabled = grid.is_cell_valid(cell) \
				and (not cell_select_predicate or cell_select_predicate.call(cell))
		else:
			enabled = false

func get_hovered_cell():
	var pos = Utils.get_perspective_collision_ray_point(self)
	if pos:
		return GameManager.current_zone.grid.get_cell_by_position(pos)
	return null
