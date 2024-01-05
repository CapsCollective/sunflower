class_name PlayerCharacter extends Character

const player_ui_scn = preload("res://assets/items/scenes/hotbar.tscn")
const selection_cursor_scn = preload("res://assets/character/scenes/selection_cursor.tscn")
const items_dt: Datatable = preload("res://assets/content/items_dt.tres")

var selection_cursor: SelectionCursor = null

func _ready():
	super._ready()
	GameManager.game_world.ui.add_child(player_ui_scn.instantiate())
	await get_tree().create_timer(0.01).timeout
	GameManager.current_zone.game_cam.subject = self
	selection_cursor = selection_cursor_scn.instantiate()
	selection_cursor.visible = false
	add_sibling(selection_cursor)
	GameManager.item_selected.connect(on_item_selected)

func on_item_selected(item: String):
	if not item.is_empty():
		var item_row: ItemRow = items_dt.get_row(item)
		match(item_row.action_type):
			ItemRow.ActionType.PLANT:
				selection_cursor.cell_select_predicate = func(cell: Vector2i):
					var crop_zone = Savegame.player.crops.get(GameManager.current_zone.id)
					return not crop_zone or crop_zone.get(cell) == null
				selection_cursor.run_action_callback = func(cell: Vector2i):
					run_action(CharacterActionPlantCrop.new(self, cell, GameManager.selected_item))
				selection_cursor.visible = true
				return
			ItemRow.ActionType.WATER:
				selection_cursor.cell_select_predicate = func(_cell: Vector2i):
					return true
				selection_cursor.run_action_callback = func(cell: Vector2i):
					run_action(CharacterActionWaterSoil.new(self, cell))
				selection_cursor.visible = true
				return
	selection_cursor.visible = false

func _unhandled_input(event):
	if event.is_action("lmb_down") and event.is_action_pressed("lmb_down"):
		if selection_cursor.visible:
			var cell = selection_cursor.get_hovered_cell()
			if cell and GameManager.current_zone.grid.is_cell_valid(cell):
				if selection_cursor.cell_select_predicate.call(cell):
					selection_cursor.run_action_callback.call(cell)
					selection_cursor.visible = false
		else:
			var pos = Utils.get_perspective_collision_ray_point(self)
			if pos:
				navigate_to(pos)
		get_viewport().set_input_as_handled()
	elif event.is_action("ui_accept") and event.is_action_released("ui_accept"):
		get_viewport().set_input_as_handled()

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
