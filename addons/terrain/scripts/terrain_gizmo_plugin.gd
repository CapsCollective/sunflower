extends EditorNode3DGizmoPlugin

var editor_plugin: EditorPlugin

func _get_gizmo_name():
	return "Terrain"

func _has_gizmo(node):
	return node is Terrain

func _init(plugin: EditorPlugin):
	editor_plugin = plugin
	create_material("face_selection", Color(1, 1, 1, 0.2))
	create_handle_material("handles")

func _redraw(gizmo: EditorNode3DGizmo):
	gizmo.clear()
	var terrain: Terrain = gizmo.get_node_3d() as Terrain
	
	var handles: PackedVector3Array = PackedVector3Array()
	var verts: Array[Vector3] = terrain.get_unique_verts()
	var offset: Vector3 = terrain.get_centre_offset()
	for i in range(verts.size()):
		handles.push_back(verts[i] + offset)
	gizmo.add_handles(handles, get_material("handles", gizmo), range(verts.size()))
	
	var selected_subgizmo = gizmo.get_subgizmo_selection()
	if not selected_subgizmo.is_empty():
		var mat = get_material("face_selection", gizmo)
		var tri = terrain.get_tri_by_idx(selected_subgizmo[0])
		var x = (tri[0].x + tri[1].x + tri[2].x) / 3
		var y = (tri[0].y + tri[1].y + tri[2].y) / 3
		var z = (tri[0].z + tri[1].z + tri[2].z) / 3
		var xform: Transform3D
		xform.origin = Vector3(x, y, z) + offset
		var mesh = SphereMesh.new()
		mesh.radius = 0.25
		mesh.height = 0.5
		gizmo.add_mesh(mesh, mat, xform)

func _get_subgizmo_transform(gizmo: EditorNode3DGizmo, subgizmo_id: int):
	var xform = Transform3D()
	xform.origin = Vector3(0, 1, 0)
	return Transform3D()

func _subgizmos_intersect_ray(gizmo: EditorNode3DGizmo, camera: Camera3D, screen_pos: Vector2):
	var terrain: Terrain = gizmo.get_node_3d() as Terrain
	for i in range(terrain.get_tri_count()):
		var tri = terrain.get_tri_by_idx(i)
		var origin: Vector3 = camera.project_ray_origin(screen_pos)
		var direction: Vector3 = camera.project_ray_normal(screen_pos)
		var offset = terrain.get_centre_offset()
		if Geometry3D.ray_intersects_triangle(origin, direction, tri[0] + offset, tri[1] + offset, tri[2] + offset):
			return i
	return -1

func _get_handle_name(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool):
	return str(handle_id)

func _get_handle_value(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool):
	var terrain: Terrain = gizmo.get_node_3d() as Terrain
	return terrain.height_mappings.get(handle_id, 0.0)

func _commit_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, restore: Variant, cancel: bool):
	var terrain: Terrain = gizmo.get_node_3d() as Terrain
	
	var undo_redo: EditorUndoRedoManager = editor_plugin.get_undo_redo()
	undo_redo.create_action("Move terrain vert handle", UndoRedo.MERGE_DISABLE, null, false)
	undo_redo.add_do_method(self, "set_terrain_handle", gizmo, terrain, handle_id, terrain.height_mappings[handle_id])
	undo_redo.add_undo_method(self, "set_terrain_handle", gizmo, terrain, handle_id, restore)
	undo_redo.commit_action()
	
	gizmo.get_node_3d().update_gizmos()
	terrain.generate_mesh()

func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2):
	var terrain: Terrain = gizmo.get_node_3d() as Terrain
	
	var verts: Array[Vector3] = terrain.get_unique_verts()
	var curr_handle_pos: Vector3 = verts[handle_id]
	var handle_cam_dist: float = camera.position.distance_to(curr_handle_pos)
	var new_handle_pos: Vector3 = camera.project_position(screen_pos, handle_cam_dist)
	set_terrain_handle(gizmo, terrain, handle_id, new_handle_pos.y)

func set_terrain_handle(gizmo: Node3DGizmo, terrain: Terrain, handle_id: int, height: float):
	terrain.set_height_at(handle_id, height)
	gizmo.get_node_3d().update_gizmos()
	terrain.generate_mesh()
