@tool
class_name Terrain extends StaticBody3D

@export var size: float = 1.0
@export_range(1, 1000) var rows: int = 1
@export_range(1, 1000) var cols: int = 1

@export var material: BaseMaterial3D

@export var uv_ids: Dictionary = {}
@export var default_uv: Vector2
@export var default_uv_id: StringName
@export var uv_mappings: Dictionary = {}

@export var height_mappings: Dictionary = {}

func get_vert_count() -> int:
	return (rows+1)*(cols+1)

func get_tri_count() -> int:
	return get_plane_count()*2

func get_plane_count() -> int:
	return rows*cols

func get_plane_idx_from_tri_idx(idx: int) -> int:
	return idx/2

func get_tri_indices_from_plane_idx(idx: int) -> Array[int]:
	return [idx*2, idx*2+1]

func get_row_col_by_plane_idx(idx: int) -> Array[int]:
	return [idx/rows, idx%rows]

func get_plane_idx_by_row_col(row: int, col: int) -> int:
	return row*rows + col

func is_left_tri_idx(idx: int) -> bool:
	return idx % 2 == 0

func get_vert_indices_at_tri_idx(idx: int) -> Array[int]:
	var plane_idx: int = get_plane_idx_from_tri_idx(idx)
	var vert_indices: Array[int] = get_vert_indices_at_plane_idx(plane_idx)
	if is_left_tri_idx(idx):
		return [vert_indices[2], vert_indices[1], vert_indices[0]]
	else:
		return [vert_indices[3], vert_indices[1], vert_indices[2]]

func get_vert_indices_at_plane_idx(idx: int) -> Array[int]:
	var rc: Array[int] = get_row_col_by_plane_idx(idx)
	return get_vert_indices_at_row_col(rc[0], rc[1])

func get_vert_indices_at_row_col(row: int, col: int) -> Array[int]:
	var curr_row: int = row*rows
	var nxt_row: int = (row+1)*rows
	var rc_sum: int = col + row
	return [
		curr_row + rc_sum,
		nxt_row + rc_sum + 1,
		curr_row + rc_sum + 1,
		nxt_row + rc_sum + 2
	]

func get_vert_at_vert_idx(idx: int) -> Vector3:
	return Vector3()

func get_verts_at_tri_idx(idx: int) -> PackedVector3Array:
	var plane_idx: int = get_plane_idx_from_tri_idx(idx)
	var plane_verts: PackedVector3Array = get_verts_at_plane_idx(plane_idx)
	if is_left_tri_idx(idx):
		return [plane_verts[2], plane_verts[1], plane_verts[0]]
	else:
		return [plane_verts[3], plane_verts[1], plane_verts[2]]

func get_verts_at_plane_idx(idx: int) -> PackedVector3Array:
	var rc: Array[int] = get_row_col_by_plane_idx(idx)
	return get_verts_at_row_col(rc[0], rc[1])

func get_tris_at_plane_idx(idx: int) -> Array[PackedVector3Array]:
	var rc: Array[int] = get_row_col_by_plane_idx(idx)
	var plane_verts: PackedVector3Array = get_verts_at_row_col(rc[0], rc[1])
	var tri1: PackedVector3Array = [
		plane_verts[2],
		plane_verts[1],
		plane_verts[0]
	]
	var tri2: PackedVector3Array = [
		plane_verts[3],
		plane_verts[1],
		plane_verts[2]
	]
	return [tri1, tri2]

func get_verts_at_row_col(row: int, col: int) -> PackedVector3Array:
	var heights: Array[float] = get_heights_at_row_col(row, col)
	return [
		Vector3(col*size, heights[0], row*size),
		Vector3(col*size, heights[1], (row+1)*size),
		Vector3((col+1)*size, heights[2], row*size),
		Vector3((col+1)*size, heights[3], (row+1)*size)
	]

func get_all_verts() -> PackedVector3Array:
	var verts: PackedVector3Array
	var idx: int = 0
	for row in range(rows+1):
		for col in range(cols+1):
			verts.append(Vector3(col*size, get_height_for_vert(idx), row*size))
			idx += 1
	return verts

func get_heights_at_row_col(row: int, col: int) -> Array[float]:
	var vert_indices: Array[int] = get_vert_indices_at_row_col(row, col)
	return [
		get_height_for_vert(vert_indices[0]),
		get_height_for_vert(vert_indices[1]),
		get_height_for_vert(vert_indices[2]),
		get_height_for_vert(vert_indices[3])
	]

func get_height_for_vert(idx: int) -> float:
	return height_mappings.get(idx, 0.0)

func get_heights_for_vert_indices(indices: Array[int]) -> Array[float]:
	var heights: Array[float]
	for idx in indices:
		heights.append(get_height_for_vert(idx))
	return heights

func set_height_for_vert(idx: int, height: float):
	height_mappings[idx] = height

func get_uv_id_for_tri(idx: int) -> StringName:
	return uv_mappings.get(idx, default_uv_id)

func get_uv_ids_for_tris(indices: Array[int]) -> Array[StringName]:
	var uv_ids: Array[StringName]
	for idx in indices:
		uv_ids.append(get_uv_id_for_tri(idx))
	return uv_ids

func set_uv_id_for_tri(idx: int, id: StringName):
	if id:
		uv_mappings[idx] = id
	else:
		uv_mappings.erase(idx)

func get_uv_for_tri(idx: int):
	uv_ids.get(get_uv_id_for_tri(idx), default_uv)

func get_uvs_at_row_col(row: int, col: int) -> PackedVector2Array:
	var plane_idx: int = get_plane_idx_by_row_col(row, col)
	var tri_indices: Array[int] = get_tri_indices_from_plane_idx(plane_idx)
	return [
		get_uv_for_tri(tri_indices[0]),
		get_uv_for_tri(tri_indices[1])
	]

func clean():
	for tri_idx in uv_mappings.keys():
		if tri_idx >= get_tri_count():
			uv_mappings.erase(tri_idx)
	
	for vert_idx in height_mappings.keys():
		if vert_idx >= get_vert_count():
			height_mappings.erase(vert_idx)

func generate_mesh():
	var mesh_instance: MeshInstance3D = find_or_create_mesh_instance()
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for row in range(rows):
		for col in range(cols):
			var verts: PackedVector3Array = get_verts_at_row_col(row, col)
			var uvs: PackedVector2Array = get_uvs_at_row_col(row, col)
			st.set_uv(uvs[0])
			st.add_vertex(verts[2])
			st.add_vertex(verts[1])
			st.add_vertex(verts[0])
			
			st.set_uv(uvs[1])
			st.add_vertex(verts[3])
			st.add_vertex(verts[1])
			st.add_vertex(verts[2])
	
	st.generate_normals()
	var mesh = st.commit()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position = get_centre_offset()

func get_centre_offset() -> Vector3:
	return -((Vector3(cols, 0, rows)*size) / 2.0)

func reset():
	for child in get_children():
		child.queue_free()

func generate_collision():
	var mesh_instance: MeshInstance3D = find_mesh_instance()
	if not mesh_instance:
		return
	var collision_shape: CollisionShape3D = find_or_create_collision_shape()
	collision_shape.shape = mesh_instance.mesh.create_trimesh_shape()
	collision_shape.position = get_centre_offset()

func find_mesh_instance() -> MeshInstance3D:
	var mesh_instance: MeshInstance3D
	for child in get_children():
		if child is MeshInstance3D:
			mesh_instance = child
	return mesh_instance

func find_or_create_mesh_instance() -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = find_mesh_instance()
	if not mesh_instance:
		mesh_instance = MeshInstance3D.new()
		add_child(mesh_instance)
		mesh_instance.owner = get_tree().edited_scene_root
		mesh_instance.name = "TerrainMesh"
	return mesh_instance

func find_or_create_collision_shape() -> CollisionShape3D:
	var collision_shape: CollisionShape3D
	for child in get_children():
		if child is CollisionShape3D:
			collision_shape = child
	if not collision_shape:
		collision_shape = CollisionShape3D.new()
		add_child(collision_shape)
		collision_shape.owner = get_tree().edited_scene_root
		collision_shape.name = "TerrainCollision"
	return collision_shape
