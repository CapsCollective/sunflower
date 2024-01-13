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
				var vert_indices: Array[int]
				match(select_mode):
					SelectMode.TRI:
						vert_indices = terrain.get_vert_indices_at_tri_idx(selected_subgizmo)
					SelectMode.PLANE:
						vert_indices = terrain.get_vert_indices_at_plane_idx(selected_subgizmo)
				
				var old_vert_heights: Array[float] = terrain.get_heights_for_vert_indices(vert_indices)
				var new_vert_heights: Array[float] = []
				new_vert_heights.resize(vert_indices.size())
				new_vert_heights.fill(height)
				
				var undo_redo: EditorUndoRedoManager = editor_plugin.get_undo_redo()
				undo_redo.create_action("Set terrain heights for verts", UndoRedo.MERGE_DISABLE, null, false)
				undo_redo.add_do_method(self, "set_terrain_heights_for_verts", gizmo, terrain, vert_indices, new_vert_heights)
				undo_redo.add_undo_method(self, "set_terrain_heights_for_verts", gizmo, terrain, vert_indices, old_vert_heights)
				undo_redo.commit_action()
			EditMode.COLOUR:
				var uv_id = editor_plugin.terrain_side_bar.get_colour_id()
				var tri_indices: Array[int]
				match(select_mode):
					SelectMode.TRI:
						tri_indices = [selected_subgizmo]
					SelectMode.PLANE:
						var tri1_idx = selected_subgizmo*2
						var tri2_idx = terrain.get_alternate_tri_idx(tri1_idx)
						tri_indices = [tri1_idx, tri2_idx]
				
				var old_uv_ids: Array[StringName] = terrain.get_uv_ids_for_tris(tri_indices)
				var new_uv_ids: Array[StringName] = []
				new_uv_ids.resize(tri_indices.size())
				new_uv_ids.fill(uv_id)
				
				var undo_redo: EditorUndoRedoManager = editor_plugin.get_undo_redo()
				undo_redo.create_action("Set UV IDs for tris", UndoRedo.MERGE_DISABLE, null, false)
				undo_redo.add_do_method(self, "set_terrain_uv_ids_for_tris", gizmo, terrain, tri_indices, new_uv_ids)
				undo_redo.add_undo_method(self, "set_terrain_uv_ids_for_tris", gizmo, terrain, tri_indices, old_uv_ids)
				undo_redo.commit_action()
	return selected_subgizmo

func _get_handle_name(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool):
	return "vert %s" % handle_id

func _get_handle_value(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool):
	var terrain: Terrain = gizmo.get_node_3d() as Terrain
	return terrain.get_height_for_vert(handle_id)

func _commit_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, restore: Variant, cancel: bool):
	var terrain: Terrain = gizmo.get_node_3d() as Terrain
	
	var vert_indices: Array[int] = [handle_id]
	var old_heights: Array[float] = [restore]
	if cancel:
		set_terrain_heights_for_verts(gizmo, terrain, vert_indices, old_heights)
	else:
		var new_heights: Array[float] = [terrain.get_height_for_vert(handle_id)]
		var undo_redo: EditorUndoRedoManager = editor_plugin.get_undo_redo()
		undo_redo.create_action("Move terrain vert handle", UndoRedo.MERGE_DISABLE, null, false)
		undo_redo.add_do_method(self, "set_terrain_heights_for_verts", gizmo, terrain, vert_indices, new_heights)
		undo_redo.add_undo_method(self, "set_terrain_heights_for_verts", gizmo, terrain, vert_indices, old_heights)
		undo_redo.commit_action()

func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2):
	var terrain: Terrain = gizmo.get_node_3d() as Terrain
	var curr_handle_pos: Vector3 = terrain.get_vert_at_vert_idx(handle_id)
	var handle_cam_dist: float = camera.position.distance_to(curr_handle_pos)
	var new_handle_pos: Vector3 = camera.project_position(screen_pos, handle_cam_dist)
	set_terrain_heights_for_verts(gizmo, terrain, [handle_id], [new_handle_pos.y])

func set_terrain_heights_for_verts(gizmo: Node3DGizmo, terrain: Terrain, vert_indices: Array[int], heights: Array[float]):
	for i in range(vert_indices.size()):
		terrain.set_height_for_vert(vert_indices[i], heights[i])
	gizmo.get_node_3d().update_gizmos()
	terrain.generate_mesh()

func set_terrain_uv_ids_for_tris(gizmo: Node3DGizmo, terrain: Terrain, tri_indices: Array[int], uv_ids: Array[StringName]):
	for i in range(tri_indices.size()):
		terrain.set_uv_id_for_tri(tri_indices[i], uv_ids[i])
	gizmo.get_node_3d().update_gizmos()
	terrain.generate_mesh()
