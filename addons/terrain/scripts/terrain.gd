@tool
class_name Terrain extends StaticBody3D

@export var size: float = 1.0
@export_range(1, 1000) var rows: int = 1
@export_range(1, 1000) var cols: int = 1

@export var material: BaseMaterial3D

@export var uv_ids: Dictionary = {}

@export var default_uv: Vector2

@export var height_mappings: Dictionary = {}

@export var uv_mappings: Dictionary = {}

func get_tri_by_idx(idx: int) -> Array:
	var row: int = idx/(rows*2)
	var col: int = (idx/2)%rows
	var verts := get_verts_at_row_col(row, col)
	return [verts[2], verts[1], verts[0]] if idx % 2 == 0 else [verts[3], verts[1], verts[2]]

func get_verts_at_row_col(row: int, col: int) -> Array[Vector3]:
	return [
		Vector3(col*size, get_height_at(row, col, 0), row*size),
		Vector3(col*size, get_height_at(row, col, 1), (row+1)*size),
		Vector3((col+1)*size, get_height_at(row, col, 2), row*size),
		Vector3((col+1)*size, get_height_at(row, col, 3), (row+1)*size),
	]

func get_height_at(row: int, col: int, idx: int) -> float:
	var curr_row: int = row*rows
	var nxt_row: int = (row+1)*rows
	var rc_sum: int = col + row
	match(idx):
		0:
			return height_mappings.get(curr_row + rc_sum, 0.0)
		1:
			return height_mappings.get(nxt_row + rc_sum + 1, 0.0)
		2:
			return height_mappings.get(curr_row + rc_sum + 1, 0.0)
		3:
			return height_mappings.get(nxt_row + rc_sum + 2, 0.0)
	return 0

func set_height_at(idx: int, height: float):
	height_mappings[idx] = height

func get_unique_verts() -> Array[Vector3]:
	var verts: Array[Vector3]
	var idx: int = 0
	for row in range(rows+1):
		for col in range(cols+1):
			verts.append(Vector3(col*size, height_mappings.get(idx, 0.0), row*size))
			idx += 1
	return verts

func get_tri_count() -> int:
	return rows*cols*2

func reset():
	for child in get_children():
		child.queue_free()

func generate_mesh():
	var mesh_instance: MeshInstance3D = find_or_create_mesh_instance()
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for row in range(rows):
		for col in range(cols):
			var verts := get_verts_at_row_col(row, col)
			var uvs := get_uvs_for_row_col(row, col)
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

func get_uvs_for_row_col(row: int, col: int) -> Array[Vector2]:
	var plane_idx: int = row*rows + row*2 + col*2
	return [
		uv_ids.get(uv_mappings.get(plane_idx, default_uv), default_uv),
		uv_ids.get(uv_mappings.get(plane_idx + 1, default_uv), default_uv)
	]

func get_centre_offset() -> Vector3:
	return -(Vector3(rows, 0, cols) * size / 2)

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
