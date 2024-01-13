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
	
	var handles: PackedVector3Array
	var verts: PackedVector3Array = terrain.get_all_verts()
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
				mesh_verts = terrain.get_verts_at_tri_idx(selected_subgizmo[0])
				mesh_type = Mesh.PRIMITIVE_TRIANGLES
			SelectMode.PLANE:
				mesh_verts = terrain.get_verts_at_plane_idx(selected_subgizmo[0])
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
				var verts: PackedVector3Array = terrain.get_verts_at_tri_idx(i)
				if Geometry3D.ray_intersects_triangle(origin, direction, verts[0]+offset, verts[1]+offset, verts[2]+offset):
					selected_subgizmo = i
		SelectMode.PLANE:
			for i in range(terrain.get_plane_count()):
				var tris: Array[PackedVector3Array] = terrain.get_tris_at_plane_idx(i)
				var intersect1 = Geometry3D.ray_intersects_triangle(origin, direction, tris[0][0]+offset, tris[0][1]+offset, tris[0][2]+offset)
				var intersect2 = Geometry3D.ray_intersects_triangle(origin, direction, tris[1][0]+offset, tris[1][1]+offset, tris[1][2]+offset)
				if intersect1 or intersect2:
					selected_subgizmo = i
	
	if selected_subgizmo != -1:
		var terrain_edited: bool = false
		var edit_mode: EditMode = editor_plugin.terrain_side_bar.get_edit_mode()
		match(edit_mode):
			EditMode.HEIGHT:
				var height: float = editor_plugin.terrain_side_bar.get_height_value()
				match(select_mode):
					SelectMode.TRI:
						for idx in terrain.get_vert_indices_at_tri_idx(selected_subgizmo):
							terrain.set_height_for_vert(idx, height)
					SelectMode.PLANE:
						for idx in terrain.get_vert_indices_at_plane_idx(selected_subgizmo):
							terrain.set_height_for_vert(idx, height)
				gizmo.get_node_3d().update_gizmos()
				terrain.generate_mesh()
			EditMode.COLOUR:
				var uv_id = editor_plugin.terrain_side_bar.get_colour_id()
				match(select_mode):
					SelectMode.TRI:
						terrain.set_uv_id_for_tri(selected_subgizmo, uv_id)
					SelectMode.PLANE:
						var tri1_idx = selected_subgizmo*2
						var tri2_idx = terrain.get_alternate_tri_idx(tri1_idx)
						terrain.set_uv_id_for_tri(tri1_idx, uv_id)
						terrain.set_uv_id_for_tri(tri2_idx, uv_id)
				gizmo.get_node_3d().update_gizmos()
				terrain.generate_mesh()
	
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

	var curr_handle_pos: Vector3 = terrain.get_vert_at_vert_idx(handle_id)
	var handle_cam_dist: float = camera.position.distance_to(curr_handle_pos)
	var new_handle_pos: Vector3 = camera.project_position(screen_pos, handle_cam_dist)
	set_terrain_handle(gizmo, terrain, handle_id, new_handle_pos.y)

func set_terrain_handle(gizmo: Node3DGizmo, terrain: Terrain, handle_id: int, height: float):
	terrain.set_height_for_vert(handle_id, height)
	gizmo.get_node_3d().update_gizmos()
	terrain.generate_mesh()
