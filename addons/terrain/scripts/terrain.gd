@tool
class_name Terrain extends StaticBody3D

const tris = [
	Vector3(-1, 0, 1),
	Vector3(-1, 0, -1),
	Vector3(1, 0, 1),
	
	Vector3(1, 0, 1),
	Vector3(-1, 0, -1),
	Vector3(1, 0, -1),
]

@export var tri_uvs = [
	Vector2(0.1, 0.1),
	Vector2(0.8, 0.8),
]

@export var material: BaseMaterial3D

@export var vert_mods = [
	0.5,
	0,
	0,
	0.5,
]

func get_tri(idx: int) -> Array[Vector3]:
	var tri_idx = idx*3
	return [
		tris[tri_idx],
		tris[tri_idx+1],
		tris[tri_idx+2]
	]

func get_tri_count() -> int:
	return tri_uvs.size()

func reset():
	for child in get_children():
		child.queue_free()

func generate_mesh():
	var mesh_instance: MeshInstance3D = find_or_create_mesh_instance()
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(get_tri_count()):
		st.set_uv(tri_uvs[i])
		var tri = get_tri(i)
		st.add_vertex(tri[0] + Vector3(0, vert_mods[i], 0))
		st.add_vertex(tri[1] + Vector3(0, vert_mods[i+1], 0))
		st.add_vertex(tri[2] + Vector3(0, vert_mods[i+2], 0))
	
	st.generate_normals()
	var mesh = st.commit()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material

func generate_collision():
	var mesh_instance: MeshInstance3D = find_mesh_instance()
	if not mesh_instance:
		return
	
	var collision_shape: CollisionShape3D = find_or_create_collision_shape()
	collision_shape.shape = mesh_instance.mesh.create_trimesh_shape()

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
