extends EditorNode3DGizmoPlugin

const SideBar = preload("res://addons/terrain/scripts/terrain_editor_side_bar.gd")
const EditMode = SideBar.TerrainEditorEditMode
const SelectMode = SideBar.TerrainEditorSelectMode

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
	var verts: PackedVector3Array = terrain.get_unique_verts()
	var offset: Vector3 = terrain.get_centre_offset()
	for i in range(verts.size()):
		handles.push_back(verts[i] + offset)
	gizmo.add_handles(handles, get_material("handles", gizmo), range(verts.size()))
	
	var selected_subgizmo = gizmo.get_subgizmo_selection()
	if not selected_subgizmo.is_empty():
		var mat = get_material("face_selection", gizmo)
		var mesh: Mesh = ArrayMesh.new()
		var mesh_verts: PackedVector3Array
		var mesh_type: Mesh.PrimitiveType
		
		var mode: SelectMode = editor_plugin.terrain_side_bar.get_select_mode()
		match(mode):
			SelectMode.TRI:
				mesh_verts = terrain.get_tri_by_idx(selected_subgizmo[0])
				mesh_type = Mesh.PRIMITIVE_TRIANGLES
			SelectMode.PLANE:
				var row_col: Array[int] = terrain.get_plane_row_col_by_idx(selected_subgizmo[0])
				mesh_verts = terrain.get_verts_at_row_col(row_col[0], row_col[1])
				mesh_type = Mesh.PRIMITIVE_TRIANGLE_STRIP
		
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = mesh_verts
		mesh.add_surface_from_arrays(mesh_type, arrays)
		
		var xform: Transform3D
		xform.origin = offset
		gizmo.add_mesh(mesh, mat, xform)

func _get_subgizmo_transform(gizmo: EditorNode3DGizmo, subgizmo_id: int):
	var xform = Transform3D()
	xform.origin = Vector3(0, 1, 0)
	return Transform3D()

func _subgizmos_intersect_ray(gizmo: EditorNode3DGizmo, camera: Camera3D, screen_pos: Vector2):
	var terrain: Terrain = gizmo.get_node_3d() as Terrain
	var selected_subgizmo: int = -1
	
	var origin: Vector3 = camera.project_ray_origin(screen_pos)
	var direction: Vector3 = camera.project_ray_normal(screen_pos)
	var offset = terrain.get_centre_offset()
	
	var select_mode: SelectMode = editor_plugin.terrain_side_bar.get_select_mode()
	match(select_mode):
		SelectMode.TRI:
			for i in range(terrain.get_tri_count()):
				var tri: PackedVector3Array = terrain.get_tri_by_idx(i)
				if Geometry3D.ray_intersects_triangle(origin, direction, tri[0] + offset, tri[1] + offset, tri[2] + offset):
					selected_subgizmo = i
		SelectMode.PLANE:
			for i in range(terrain.get_plane_count()):
				var row_col: Array[int] = terrain.get_plane_row_col_by_idx(i)
				var verts: PackedVector3Array = terrain.get_verts_at_row_col(row_col[0], row_col[1])
				var tri1: PackedVector3Array = terrain.get_tri_from_plane_verts(verts, 0)
				var tri2: PackedVector3Array = terrain.get_tri_from_plane_verts(verts, 1)
				var tri1_intersect = Geometry3D.ray_intersects_triangle(origin, direction, tri1[0] + offset, tri1[1] + offset, tri1[2] + offset)
				var tri2_intersect = Geometry3D.ray_intersects_triangle(origin, direction, tri2[0] + offset, tri2[1] + offset, tri2[2] + offset)
				if tri1_intersect or tri2_intersect:
					selected_subgizmo = i
	
	var edit_mode: EditMode = editor_plugin.terrain_side_bar.get_edit_mode()
	match(edit_mode):
		EditMode.HEIGHT:
			pass
		EditMode.COLOUR:
			pass
	
	return selected_subgizmo

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
	
	var verts: PackedVector3Array = terrain.get_unique_verts()
	var curr_handle_pos: Vector3 = verts[handle_id]
	var handle_cam_dist: float = camera.position.distance_to(curr_handle_pos)
	var new_handle_pos: Vector3 = camera.project_position(screen_pos, handle_cam_dist)
	set_terrain_handle(gizmo, terrain, handle_id, new_handle_pos.y)

func set_terrain_handle(gizmo: Node3DGizmo, terrain: Terrain, handle_id: int, height: float):
	terrain.set_height_at(handle_id, height)
	gizmo.get_node_3d().update_gizmos()
	terrain.generate_mesh()
