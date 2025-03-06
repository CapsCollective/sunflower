extends EditorNode3DGizmoPlugin

var editor_plugin: EditorPlugin

func _get_gizmo_name():
	return "Grid3D"

func _has_gizmo(node):
	return node is Grid3D

func _init(plugin: EditorPlugin):
	editor_plugin = plugin
	create_material("grid_cell_enabled", Color(1, 1, 1))
	create_material("grid_cell_disabled", Color(1, 0, 0))
	create_material("grid_cell_text", Color(0, 0, 0), true, true)

func _redraw(gizmo):
	gizmo.clear()
	var grid: Grid3D = gizmo.get_node_3d() as Grid3D
	
	var enabled_material = get_material("grid_cell_enabled", gizmo)
	var disabled_material = get_material("grid_cell_disabled", gizmo)
	var text_material = get_material("grid_cell_text", gizmo)
	
	var lower_bounds: Vector2i = grid.get_lower_cell_bounds()
	var upper_bounds: Vector2i = grid.get_upper_cell_bounds()
	for i in range(lower_bounds.x, upper_bounds.x):
		for j in range(lower_bounds.y, upper_bounds.y):
			var plane = PlaneMesh.new()
			plane.size = Vector2(grid.size, grid.size) * 0.9
			var xform: Transform3D
			xform.origin = Vector3(i, 0, j) * grid.size
			var disabled: bool = grid.is_cell_disabled(Vector2i(i, j))
			gizmo.add_mesh(plane, disabled_material if disabled else enabled_material, xform)
			var text = TextMesh.new()
			text.depth = 0.01
			text.text = "%d, %d" % [i, j]
			var rotated_xform = xform.rotated_local(Vector3.LEFT, PI/2).rotated_local(Vector3.FORWARD, -PI/2)
			gizmo.add_mesh(text, text_material, rotated_xform)

func _subgizmos_intersect_ray(gizmo: EditorNode3DGizmo, camera: Camera3D, screen_pos: Vector2):
	var grid: Grid3D = gizmo.get_node_3d() as Grid3D
	var selected_subgizmo: int = -1
	var selected_cell: Vector2i
	
	var origin: Vector3 = camera.project_ray_origin(screen_pos)
	var direction: Vector3 = camera.project_ray_normal(screen_pos)
	
	var lower_bounds: Vector2i = grid.get_lower_cell_bounds()
	var upper_bounds: Vector2i = grid.get_upper_cell_bounds()
	
	var current_id: int = -1
	var half_size: float = grid.size / 2.0
	for i in range(lower_bounds.x, upper_bounds.x):
		for j in range(lower_bounds.y, upper_bounds.y):
			current_id += 1
			var centre: Vector3 = Vector3(i, 0, j) * grid.size + grid.position
			var tris: PackedVector3Array = [
				(centre + Vector3(-half_size, 0.0, -half_size)),
				(centre + Vector3(half_size, 0.0, -half_size)),
				(centre + Vector3(-half_size, 0.0, half_size)),
				(centre + Vector3(half_size, 0.0, half_size)),
			]
			var intersect1 = Geometry3D.ray_intersects_triangle(origin, direction, tris[0], tris[1], tris[2])
			var intersect2 = Geometry3D.ray_intersects_triangle(origin, direction, tris[2], tris[1], tris[3])
			if intersect1 or intersect2:
				selected_subgizmo = current_id
				selected_cell = Vector2i(i, j)
	
	if selected_subgizmo != -1:
		var idx: int = grid.disabled_cells.find(selected_cell)
		if idx != -1:
			grid.disabled_cells.remove_at(idx)
		else:
			grid.disabled_cells.append(selected_cell)
		var undo_redo: EditorUndoRedoManager = editor_plugin.get_undo_redo()
		undo_redo.create_action("Toggle disabled state for grid cell", UndoRedo.MERGE_DISABLE, null, false)
		undo_redo.add_do_method(self, "set_disabled_state_for_grid_cell", gizmo, grid, selected_cell, idx != -1)
		undo_redo.add_undo_method(self, "set_disabled_state_for_grid_cell", gizmo, grid, selected_cell, idx == -1)
		undo_redo.commit_action()
	return selected_subgizmo

func set_disabled_state_for_grid_cell(gizmo: Node3DGizmo, grid: Grid3D, grid_cell: Vector2i, disable: bool):
	var idx: int = grid.disabled_cells.find(grid_cell)
	if disable and idx != -1:
		grid.disabled_cells.remove_at(idx)
	elif not disable and idx == -1:
		grid.disabled_cells.append(grid_cell)
	gizmo.get_node_3d().update_gizmos()
