class_name DebugDraw

static func line(context: Node, pos1: Vector3, pos2: Vector3, color: Color = Color.RED, lifetime: float = 0):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await _handle_cleanup(context, mesh_instance, lifetime)

static func point(context: Node, pos: Vector3, radius = 0.05, color: Color = Color.RED, lifetime: float = 0):
	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = sphere_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = pos

	sphere_mesh.radius = radius
	sphere_mesh.height = radius*2
	sphere_mesh.material = material

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await _handle_cleanup(context, mesh_instance, lifetime)

static func box(context: Node, pos: Vector3, size: Vector2, color: Color = Color.RED, lifetime: float = 0):
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = box_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = pos

	box_mesh.size = Vector3(size.x, size.y, 1)
	box_mesh.material = material

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await _handle_cleanup(context, mesh_instance, lifetime)

static func _handle_cleanup(context: Node, mesh_instance: MeshInstance3D, lifetime: float):
	context.get_tree().get_root().add_child(mesh_instance)
	if lifetime == 0:
		await context.get_tree().physics_frame
		mesh_instance.queue_free()
	elif lifetime > 0:
		await context.get_tree().create_timer(lifetime).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance
