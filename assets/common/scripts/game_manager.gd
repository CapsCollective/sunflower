extends Node

signal load_completed
signal day_incremented
signal grid_updated
signal current_zone_updated
signal inventory_updated(item_id: String, value: int)
signal hotbar_updated
signal item_selected(item_id: String)
signal scanner_prop_updated(prop: String)

const items_dt: Datatable = preload("res://assets/content/items_dt.tres")
const crops_dt: Datatable = preload("res://assets/content/crops_dt.tres")
const grid_props_dt: Datatable = preload("res://assets/content/grid_props_dt.tres")

const crop_scn = preload("res://assets/crops/scenes/crop.tscn")

var game_world: GameWorld:
	set(world):
		Utils.log_info("Initialisation", "Game world registered")
		game_world = world

func _ready():
	Savegame.load_file()
	Utils.log_info("Deserialisation", "Operation completed")
	load_completed.emit()

func _shortcut_input(event):
	if event.is_action_pressed("increment_day"):
		increment_day()
		get_viewport().set_input_as_handled()

#region Zones
var current_zone: Zone

func register_zone(zone: Zone):
	current_zone = zone
	if not Savegame.player.grid.has(zone.id):
		Savegame.player.grid[zone.id] = init_map()
	current_zone_updated.emit()

func deregister_zone(zone: Zone):
	if zone == current_zone:
		current_zone = null
		current_zone_updated.emit()
#endregion

#region Grid
func get_grid():
	var grid = Savegame.player.grid.get(current_zone.id)
	if not grid:
		Savegame.player.grid[current_zone.id] = {}
		grid = Savegame.player.grid[current_zone.id]
	return grid
	
var scanner_prop: String:
	set(prop):
		scanner_prop = prop
		scanner_prop_updated.emit(prop)

func get_grid_point(pos: Vector3) -> Dictionary:
	var point = current_zone.grid.get_cell_by_position(pos)
	return Savegame.player.area_map[point]

func update_grid_property(center: Vector2i, property: String, radius: int, change: float):
	if not grid_props_dt.has(property):
		Utils.log_error("Grid", "Grid does not have property ", property)
		return
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var point = Vector2i(x,y)
			var dist = Vector2(point).distance_to(center)
			var scaled_change = change * (radius - dist) / radius # scale down over distance
			var zone = GameManager.get_grid()
			if dist <= radius and zone.has(point):
				zone[point][property] = clampf(zone[point][property] + scaled_change, 0, 1)
	grid_updated.emit()

func init_map() -> Dictionary:
	#TODO: Load the layout of each zone from a static init file
	var map = {}
	var lower_bounds: Vector2i = current_zone.grid.get_lower_cell_bounds()
	var upper_bounds: Vector2i = current_zone.grid.get_upper_cell_bounds()
	for x in range(lower_bounds.x, upper_bounds.x):
		for y in range(lower_bounds.y, upper_bounds.y):
			map[Vector2i(x,y)] = {
				'acidity': 0.2,
				'hydration': 0.6,
				'radiation': 0.5
			}
	return map
#endregion

#region Crops
func get_crops():
	var crops = Savegame.player.crops.get(GameManager.current_zone.id)
	if not crops:
		Savegame.player.crops[GameManager.current_zone.id] = {}
		crops = Savegame.player.crops[GameManager.current_zone.id]
	return crops

func increment_day():
	Savegame.player.day += 1
	for zone_id in Savegame.player.crops:
		for crop_cell in Savegame.player.crops[zone_id]:
			var crop_entry = Savegame.player.crops[zone_id][crop_cell]
			var crop_details: CropConfig = GameManager.crops_dt.get_row(crop_entry.seed_id)
			crop_entry.days_planted += 1
			crop_entry.growth += 20
			GameManager.update_grid_property(crop_cell, 'hydration', crop_details.effect_radius, -0.2)
	Savegame.save_file()
	day_incremented.emit()

func plant_crop(seed_id: String, cell: Vector2i, zone_id: String = current_zone.id):
	if not GameManager.crops_dt.has(seed_id):
		Utils.log_error("Crops", seed_id, " is an invalid item id to plant")
		return
	Savegame.player.crops[zone_id][cell] = {
		"seed_id": seed_id,
		"days_planted": 0,
		"growth": 0,
		"health": 0.5,
	}
	if zone_id == current_zone.id:
		var crop: Crop = crop_scn.instantiate()
		current_zone.add_child(crop)
		crop.place(cell)

#endregion

#region Items
var selected_item: String:
	set(item_id):
		selected_item = item_id
		item_selected.emit(selected_item)

func deselect_item():
	selected_item = String()

func valid_item(item_id: String) -> bool:
	return items_dt.has(item_id)

func get_item_details(item_id: String) -> ItemConfig:
	if not valid_item(item_id):
		Utils.log_warn("Item", item_id, " is not a valid item type")
		return null
	return items_dt.get_row(item_id) as ItemConfig

func get_item_count(item_id: String):
	if not valid_item(item_id):
		Utils.log_warn("Item", item_id, " is not a valid item type")
		return
	if not Savegame.player.inventory.has(item_id):
		Savegame.player.inventory[item_id] = 0
		return 0
	return Savegame.player.inventory[item_id]

func change_item_count(item_id: String, change: int):
	set_item_count(item_id, get_item_count(item_id) + change)

func set_item_count(item_id: String, value: int): 
	if not valid_item(item_id):
		Utils.log_warn("Item", item_id, " is not a valid item type")
		return
	if value < 0: 
		Utils.log_warn("Item", "Cannot have fewer than 0 of any ", item_id)
		return
	
	if get_item_count(item_id) == 0 and value > 0 and not Savegame.player.hotbar.has(item_id):
		Savegame.player.hotbar.append(item_id)
		hotbar_updated.emit()
	if get_item_count(item_id) > 0 and value == 0 and Savegame.player.hotbar.has(item_id):
		Savegame.player.hotbar.erase(item_id)
		hotbar_updated.emit()
	
	Utils.log_info("Item", "Setting ", item_id, " count to ", value)
	Savegame.player.inventory[item_id] = value
	inventory_updated.emit(item_id, value)
#endregion
