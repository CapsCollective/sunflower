extends Node

signal load_completed
signal day_incremented
signal grid_updated
signal current_zone_updated
signal inventory_updated(item_id: String, value: int)
signal hotbar_updated
signal item_selected(item_id: String)

const items_dt = preload("res://assets/content/items_dt.tres")
const crops_dt = preload("res://assets/content/items_dt.tres")

const CELL_PROPERTIES = [
	'nutrition',
	'hydration',
	'radiation',
]

const ITEM_IDS = [
	'sunflower_seed',
	'sunflower_crop',
	'potato_seed',
	'potato_crop',
]

var game_world: GameWorld:
	set(world):
		Utils.log_info("Initialisation", "Game world registered")
		game_world = world

var current_zone: Zone

var selected_item: String:
	set(item_id):
		selected_item = item_id
		item_selected.emit(selected_item)

func deselect_item():
	selected_item = String()

func _ready():
	Savegame.load_file()
	Utils.log_info("Deserialisation", "Operation completed")
	load_completed.emit()

func _shortcut_input(event):
	if event.is_action_pressed("increment_day"):
		increment_day()
		get_viewport().set_input_as_handled()

func register_zone(zone: Zone):
	current_zone = zone
	if not Savegame.player.zones.has(zone.id):
		Savegame.player.zones[zone.id] = init_map()
	current_zone_updated.emit()

func deregister_zone(zone: Zone):
	if zone == current_zone:
		current_zone = null
		current_zone_updated.emit()

func get_grid_point(pos: Vector3) -> Dictionary:
	var point = current_zone.grid.get_cell_by_position(pos)
	return Savegame.player.area_map[point]

func update_grid_property(center: Vector2i, property: String, radius: int, change: float):
	if not CELL_PROPERTIES.has(property):
		Utils.log_error("Grid", "Grid does not have property ", property)
		return
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var point = Vector2i(x,y)
			var dist = Vector2(point).distance_to(center)
			var scaled_change = change * (radius - dist) / radius # scale down over distance
			var zone = Savegame.player.zones[current_zone.id]
			if dist <= radius and zone.has(point):
				zone[point][property] = clampf(zone[point][property] + scaled_change, 0, 1)
	grid_updated.emit()

func increment_day():
	Savegame.player.day += 1
	for zone_id in Savegame.player.crops:
		for crop_cell in Savegame.player.crops[zone_id]:
			var crop_entry = Savegame.player.crops[zone_id][crop_cell]
			crop_entry.days_planted += 1
			crop_entry.growth_score = clamp(crop_entry.days_planted * 20, 0, 100)
	Savegame.save_file()
	day_incremented.emit()

func init_map() -> Dictionary:
	#TODO: Load the layout of each zone from a static init file
	var map = {}
	var lower_bounds: Vector2i = current_zone.grid.get_lower_cell_bounds()
	var upper_bounds: Vector2i = current_zone.grid.get_upper_cell_bounds()
	for x in range(lower_bounds.x, upper_bounds.x):
		for y in range(lower_bounds.y, upper_bounds.y):
			map[Vector2i(x,y)] = {
				'nutrition': 0,
				'hydration': 0,
				'radiation': 0.5
			}
	return map

func valid_item(item_id: String) -> bool:
	return ITEM_IDS.has(item_id)

func get_item_details(item_id: String) -> ItemRow:
	if not valid_item(item_id):
		Utils.log_warn("Item", item_id, " is not a valid item type")
		return null
	return items_dt.get_row(item_id) as ItemRow

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
