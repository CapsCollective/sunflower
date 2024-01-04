class_name PlayerCharacter extends Character

var crop = null

func preview_crop():
	crop = preload("res://assets/crops/scenes/crop.tscn").instantiate()
	crop.crop_name = "Sunflower"
	add_sibling(crop)

func place_crop():
	crop.grid_position = GameManager.current_zone.grid.get_cell_by_position(crop.global_position)
	crop.serialise()
	crop = null

func _unhandled_input(event):
	if event.is_action("lmb_down") and event.is_action_pressed("lmb_down"):
		var pos = get_perspective_collision_ray_point()
		if pos:
			navigate_to(pos)
	elif event.is_action("rmb_down") and event.is_action_pressed("rmb_down"):
		place_crop()
	elif event.is_action("ui_accept") and event.is_action_released("ui_accept"):
		preview_crop()

func _process(_delta):
	var mouse_pos = get_perspective_collision_ray_point(false, 2)
	if mouse_pos and crop and crop.is_inside_tree():
		var grid: Grid3D = GameManager.current_zone.grid
		var quantised_pos = grid.get_quantised_position(mouse_pos)
		if grid.is_cell_at_position_valid(quantised_pos):
			crop.global_position = quantised_pos

func _physics_process(delta):
	var keyboard_movement = get_keyboard_movement()
	if keyboard_movement != Vector3.ZERO and not navigation_agent.is_navigation_finished():
		navigation_agent.target_position = global_position
	if navigation_agent.is_navigation_finished():
		target_velocity.x = keyboard_movement.x * speed
		target_velocity.z = keyboard_movement.z * speed
		velocity = target_velocity
	super._physics_process(delta)

func get_keyboard_movement() -> Vector3:
	var direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	direction = direction.normalized()
	return direction

func get_perspective_collision_ray_point(collide_with_areas: bool = false, mask: int = 1):
	var viewport: Viewport = get_viewport()
	var mouse_position: Vector2 = viewport.get_mouse_position()
	var camera: Camera3D = viewport.get_camera_3d()
	var origin: Vector3 = camera.project_ray_origin(mouse_position)
	var direction: Vector3 = camera.project_ray_normal(mouse_position)
	var end: Vector3 = origin + direction * camera.far
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = collide_with_areas
	query.collision_mask = mask
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	return result.get("position", null)
