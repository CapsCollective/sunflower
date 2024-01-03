extends EditorNode3DGizmoPlugin

func _get_gizmo_name():
	return "Grid3D"

func _has_gizmo(node):
	return node is Grid3D

func _init():
	create_material("grid_cell_enabled", Color(1, 1, 1))
	create_material("grid_cell_disabled", Color(1, 0, 0))
	create_material("grid_cell_text", Color(0, 0, 0), true, true)

func _redraw(gizmo):
	gizmo.clear()
	var grid: Grid3D = gizmo.get_node_3d() as Grid3D
	
	var enabled_material = get_material("grid_cell_enabled", gizmo)
	var disabled_material = get_material("grid_cell_disabled", gizmo)
	var text_material = get_material("grid_cell_text", gizmo)
	
	for i in range(grid.height):
		for j in range(grid.width):
			var plane = PlaneMesh.new()
			plane.size = Vector2(grid.size, grid.size) * 0.9
			var xform: Transform3D
			xform.origin = Vector3(i, 0, j) * grid.size
			var disabled: bool = grid.disabled_cells.has(Vector2i(i, j))
			gizmo.add_mesh(plane, disabled_material if disabled else enabled_material, xform)
			var text = TextMesh.new()
			text.depth = 0.01
			text.text = "%d, %d" % [i, j]
			var rotated_xform = xform.rotated_local(Vector3.LEFT, PI/2).rotated_local(Vector3.FORWARD, -PI/2)
			gizmo.add_mesh(text, text_material, rotated_xform)
