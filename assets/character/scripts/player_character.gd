class_name PlayerCharacter extends Character

const player_ui_scn = preload("res://assets/items/scenes/hotbar.tscn")
const selection_cursor_scn = preload("res://assets/character/scenes/selection_cursor.tscn")
const items_dt: Datatable = preload("res://assets/content/items_dt.tres")

var selection_cursor: SelectionCursor = null
var mouse_down: bool

func _ready():
	super._ready()
	$AnimationPlayer.play("idle")
	GameManager.game_world.ui.add_child(player_ui_scn.instantiate())
	await get_tree().create_timer(0.01).timeout
	GameManager.current_zone.game_cam.subject = self
	selection_cursor = selection_cursor_scn.instantiate()
	selection_cursor.visible = false
	add_sibling(selection_cursor)
	GameManager.item_selected.connect(on_item_selected)

func _process(_delta):
	if mouse_down and current_action.active:
		var pos = Utils.get_perspective_collision_ray_point(self)
		if pos and current_action is CharacterActionNavigateTo:
			current_action.target_pos = pos
		elif current_action is CharacterActionWaterSoil and current_action.water_cell != selection_cursor.hovered_cell:
			current_action.water_cell = selection_cursor.hovered_cell

func _unhandled_input(event):
	if event.is_action("lmb_down"):
		if event.is_action_pressed("lmb_down"):
			mouse_down = true
			if selection_cursor and selection_cursor.visible:
				var cell = selection_cursor.get_hovered_cell()
				if cell and GameManager.current_zone.grid.is_cell_valid(cell):
					if selection_cursor.cell_select_predicate.call(cell):
						selection_cursor.run_action_callback.call(cell)
			else: # Move to position
				var pos = Utils.get_perspective_collision_ray_point(self)
				if pos:
					navigate_to(pos)
			get_viewport().set_input_as_handled()
		if event.is_action_released("lmb_down"):
			mouse_down = false
			if current_action is CharacterActionWaterSoil:
				current_action.abort()
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

func on_item_selected(item: String):
	if item.is_empty():
		selection_cursor.visible = false
		return
	var item_row: ItemRow = items_dt.get_row(item)
	match(item_row.action_type):
		ItemRow.ActionType.PLANT:
			var crop_details = GameManager.crops_dt.get_row(GameManager.selected_item)
			selection_cursor.cell_select_predicate = plant_action_predicate
			selection_cursor.run_action_callback = func(cell: Vector2i):
				run_action(CharacterActionPlantCrop.new(self, cell, GameManager.selected_item))
			selection_cursor.visible = true
			selection_cursor.mesh = load(crop_details.mesh) if crop_details.mesh else SphereMesh.new()
			selection_cursor.radius = crop_details.effect_radius
			return
		ItemRow.ActionType.WATER:
			selection_cursor.cell_select_predicate = water_action_predicate
			selection_cursor.run_action_callback = func(cell: Vector2i):
				run_action(CharacterActionWaterSoil.new(self, cell))
			selection_cursor.visible = true
			selection_cursor.mesh = null
			selection_cursor.radius = 5 # TODO: Make tied to equipped watering can details
			return

func plant_action_predicate(cell: Vector2i):
	var crop_details = GameManager.crops_dt.get_row(GameManager.selected_item)	
	var crop_zone = Savegame.player.crops.get(GameManager.current_zone.id)
	if not crop_zone:
		return true
	elif crop_zone.has(cell):
		return false
	for other_crop in crop_zone:
		var other_crop_details = GameManager.crops_dt.get_row(crop_zone[other_crop].seed_id)
		var min_dist = crop_details.planting_radius + other_crop_details.planting_radius
		if Vector2(cell).distance_to(other_crop) < min_dist:
			return false
	return true

func water_action_predicate(_cell: Vector2i):
	return true

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
