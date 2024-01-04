class_name PlayerCharacter extends Character

var crop_cursor = null

func _ready():
	super._ready()
	await get_tree().create_timer(0.01).timeout
	GameManager.current_zone.game_cam.subject = self

func _unhandled_input(event):
	if event.is_action("lmb_down") and event.is_action_pressed("lmb_down"):
		var pos = Utils.get_perspective_collision_ray_point(self)
		if pos:
			navigate_to(pos)
	elif event.is_action("rmb_down") and event.is_action_pressed("rmb_down"):
		var pos = Utils.get_perspective_collision_ray_point(self)
		if pos:
			var cell = GameManager.current_zone.grid.get_cell_by_position(pos)
			run_action(CharacterActionPlantCrop.new(self, cell))
			if crop_cursor:
				crop_cursor.queue_free()
				crop_cursor = null
	elif event.is_action("ui_accept") and event.is_action_released("ui_accept"):
		crop_cursor = preload("res://assets/crops/scenes/crop_cursor.tscn").instantiate()
		add_sibling(crop_cursor)

func _process(_delta):
	var mouse_pos = Utils.get_perspective_collision_ray_point(self, false, 2)
	if mouse_pos and crop_cursor and crop_cursor.is_inside_tree():
		var grid: Grid3D = GameManager.current_zone.grid
		var quantised_pos = grid.get_quantised_position(mouse_pos)
		if grid.is_cell_at_position_valid(quantised_pos):
			crop_cursor.global_position = quantised_pos

func _physics_process(delta):
	var keyboard_movement = get_keyboard_movement()
	if keyboard_movement != Vector3.ZERO and current_action:
		current_action.abort()
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
