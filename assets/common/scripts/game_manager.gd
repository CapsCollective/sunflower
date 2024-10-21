extends Node

signal load_completed
signal day_incremented
signal grid_updated
signal current_zone_updated
signal inventory_updated(item_id: String, value: int)
signal hotbar_updated
signal item_selected(item_id: String)
signal scanner_attr_updated(attr: GameManager.SoilAttr)
signal cell_hovered(cell: Vector2i)
signal water_changed
signal health_changed
signal energy_changed

const items_dt: Datatable = preload("res://assets/datatables/tables/items_dt.tres")
const crops_dt: Datatable = preload("res://assets/datatables/tables/crops_dt.tres")

const crop_scn = preload("res://assets/crops/scenes/crop.tscn")

const soil_attr_labels = {
	SoilAttr.HYDRATION: "Hydration",
	SoilAttr.NITROGEN: "Nitrogen",
	SoilAttr.RADIATION: "Radiation",
	SoilAttr.ACIDITY: "Acidity"
}

const crop_planting_min_health = 0.75
const crop_min_health = 0.66

var scanner_attr: SoilAttr:
	set(attr):
		scanner_attr = attr
		scanner_attr_updated.emit(attr)

var game_world: GameWorld:
	set(world):
		Utils.log_info("Initialisation", "Game world registered")
		game_world = world

func _ready():
	ZoneLayouts.load_file()
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
	if not Savegame.zones.soil_attrs.has(zone.id):
		Savegame.zones.soil_attrs[zone.id] = ZoneLayouts.initial_zones.soil_attrs.get(zone.id, init_grid_attributes())
	if not Savegame.zones.crops.has(zone.id):
		Savegame.zones.crops[zone.id] = ZoneLayouts.initial_zones.crops.get(zone.id, {})
	current_zone_updated.emit()
	update_grid_attribute_texture_for_zone(current_zone.id)

func deregister_zone(zone: Zone):
	if zone == current_zone:
		current_zone = null
		current_zone_updated.emit()

func save_initial_zone_layout():
	ZoneLayouts.initial_zones.soil_attrs[current_zone.id] = Savegame.zones.soil_attrs[current_zone.id]
	ZoneLayouts.initial_zones.crops[current_zone.id] = Savegame.zones.crops[current_zone.id]
	ZoneLayouts.save_file()
#endregion

#region Grid
enum SoilAttr {
	HYDRATION,
	NITROGEN,
	RADIATION,
	ACIDITY
}

func get_soil_attrs_for_zone(zone_id: String):
	var grid = Savegame.zones.soil_attrs.get(zone_id)
	if not grid:
		Savegame.zones.soil_attrs[zone_id] = {}
		grid = Savegame.zones.soil_attrs[zone_id]
	return grid

func get_soil_attrs_for_current_zone():
	return get_soil_attrs_for_zone(current_zone.id)

func update_grid_attribute(zone_id: String, center: Vector2i, attr: SoilAttr, change: float, radius: float, falloff: float = 0.2):
	var fade_distance = radius * falloff
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var point = Vector2i(x,y)
			var dist = Vector2(point).distance_to(center)
			var zone = get_soil_attrs_for_zone(zone_id)
			if dist <= radius and zone.has(point):
				var scaled_change = change * clampf(1 - ((dist - fade_distance) / (radius - fade_distance)), 0, 1) # scale down over distance
				zone[point][attr] = clampf(zone[point][attr] + scaled_change, 0, 1)
	update_grid_attribute_texture_for_zone(zone_id)
	grid_updated.emit()

func update_grid_attribute_texture_for_zone(zone_id: String):
	var grid = GameManager.current_zone.grid
	var soil_attrs = GameManager.get_soil_attrs_for_zone(zone_id)
	var lower_bounds: Vector2i = grid.get_lower_cell_bounds()
	var upper_bounds: Vector2i = grid.get_upper_cell_bounds()
	var grid_attr_image: Image = Image.create(grid.width, grid.height, true, Image.FORMAT_RGBA8)
	for x in range(lower_bounds.x, upper_bounds.x):
		for y in range(lower_bounds.y, upper_bounds.y):
			var color = Color(1,1,0)
			var point = Vector2i(x,y)
			if not grid.disabled_cells.has(point):
				var val = soil_attrs[point]
				color = Color(val[SoilAttr.HYDRATION], val[SoilAttr.NITROGEN], val[SoilAttr.RADIATION])
			grid_attr_image.set_pixel(x - lower_bounds.x, y - lower_bounds.y, color)
	var grid_image_texture = ImageTexture.create_from_image(grid_attr_image)
	RenderingServer.global_shader_parameter_set("grid_attributes", grid_image_texture)

func update_grid_attribute_for_current_zone(center: Vector2i, attr: SoilAttr, change: float, radius: int, falloff: float = 0.2):
	update_grid_attribute(current_zone.id, center, attr, change, radius, falloff)

func init_grid_attributes() -> Dictionary:
	var map = {}
	var lower_bounds: Vector2i = current_zone.grid.get_lower_cell_bounds()
	var upper_bounds: Vector2i = current_zone.grid.get_upper_cell_bounds()
	for x in range(lower_bounds.x, upper_bounds.x):
		for y in range(lower_bounds.y, upper_bounds.y):
			map[Vector2i(x,y)] = {
				SoilAttr.HYDRATION: 0.6,
				SoilAttr.NITROGEN: 0.8,
				SoilAttr.RADIATION: 0.3,
				SoilAttr.ACIDITY: 0.5,
			}
	return map
#endregion

#region Crops
func get_crops_in_zone(zone_id: String):
	var crops = Savegame.zones.crops.get(zone_id)
	if not crops:
		Savegame.zones.crops[zone_id] = {}
		crops = Savegame.zones.crops[zone_id]
	return crops

func get_crops_in_current_zone():
	return get_crops_in_zone(current_zone.id)

func get_crop_in_current_zone(cell: Vector2i):
	return get_crops_in_current_zone().get(cell)

func increment_day():
	Savegame.player.day += 1
	if Savegame.player.energy < 30:
		set_energy(30)
	else:
		change_energy(10)
		change_health(5)
	update_crops()
	plant_weeds()
	Savegame.save_file()
	day_incremented.emit()

func update_crops():
	for zone_id in Savegame.zones.crops:
		for crop_cell in Savegame.zones.crops[zone_id]:
			var crop_entry = get_crops_in_zone(zone_id)[crop_cell]
			var crop_details: CropConfigRow = crops_dt.get_row(crop_entry.seed_id)
			if crop_entry.health == 0:
				continue
			var health = get_crop_health(zone_id, crop_cell, crop_entry.seed_id)
			crop_entry.days_planted += 1
			if health <= crop_min_health:
				crop_entry.health = 0
				crop_entry.growth = 0
			else:
				crop_entry.health = lerpf(crop_entry.health, health, 0.5)
				crop_entry.growth += health
				for attr in crop_details.attributes:
					if attr.change != 0:
						update_grid_attribute(zone_id, crop_cell, attr.attribute, attr.change, crop_details.effect_radius, crop_details.planting_radius / crop_details.effect_radius)

func plant_weeds():
	for zone_id in Savegame.zones.soil_attrs:
		for grid_cell in Savegame.zones.soil_attrs[zone_id]:
			if get_crop_health(zone_id, grid_cell, "weed") > 0.75:
				#TODO: Optimise proximity check
				var valid = true
				for other_crop in Savegame.zones.crops[zone_id]:
					var other_crop_details = GameManager.crops_dt.get_row(Savegame.zones.crops[zone_id][other_crop].seed_id)
					var min_dist = 1 + other_crop_details.planting_radius
					if Vector2(grid_cell).distance_to(other_crop) < min_dist:
						valid = false
						continue
				if valid and RandomNumberGenerator.new().randf() < 0.2:
					plant_crop("weed", grid_cell)

func get_crop_health(zone_id: String, cell: Vector2i, seed_id: String) -> float:
	var cell_attrs = get_soil_attrs_for_zone(zone_id).get(cell, {})
	var crop: CropConfigRow = crops_dt.get_row(seed_id)
	return crop.attributes.reduce(
		func(acc, attr):
			return acc + attr.requirement.sample(cell_attrs.get(attr.attribute,0))
	,0) / len(crop.attributes)

func plant_crop(seed_id: String, cell: Vector2i, zone_id: String = current_zone.id):
	if not crops_dt.has(seed_id):
		Utils.log_error("Crops", seed_id, " is an invalid item id to plant")
		return
	Savegame.zones.crops[zone_id][cell] = {
		"seed_id": seed_id,
		"days_planted": 0,
		"growth": 0,
		"health": get_crop_health(zone_id, cell, seed_id)
	}
	spawn_crop_at_cell(cell)

func spawn_crop_at_cell(cell: Vector2i):
	var crop: Crop = crop_scn.instantiate()
	current_zone.add_child(crop)
	crop.place(cell)

func is_crop_harvestable(zone_id: String, cell: Vector2i):
	return is_crop_ripe(zone_id, cell) or is_crop_dead(zone_id, cell)

func is_crop_ripe(zone_id: String, cell: Vector2i):
	var crop_entry = get_crops_in_zone(zone_id)[cell]
	var crop_details: CropConfigRow = crops_dt.get_row(crop_entry.seed_id)
	return crop_entry.growth >= crop_details.growth_required

func is_crop_just_planted(zone_id: String, cell: Vector2i):
	var crop_entry = get_crops_in_zone(zone_id)[cell]
	return crop_entry.growth == 0

func is_crop_dead(zone_id: String, cell: Vector2i):
	var crop_entry = get_crops_in_zone(zone_id)[cell]
	return crop_entry.health == 0
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

func get_item_details(item_id: String) -> ItemConfigRow:
	if not valid_item(item_id):
		Utils.log_warn("Item", item_id, " is not a valid item type")
		return null
	return items_dt.get_row(item_id) as ItemConfigRow

func get_item_count(item_id: String):
	if not valid_item(item_id):
		Utils.log_warn("Item", item_id, " is not a valid item type")
		return 0
	if not Savegame.player.inventory.has(item_id):
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
	if value == 0:
		Savegame.player.inventory.erase(item_id)
	else:
		Savegame.player.inventory[item_id] = value
	inventory_updated.emit(item_id, value)
#endregion

#region Player
func change_water(change: int) -> bool:
	if Savegame.player.water < -change:
		return false
	Savegame.player.water += change
	water_changed.emit()
	return true

func change_health(change: int):
	Savegame.player.health += change
	if Savegame.player.health > 100:
		Savegame.player.health = 100
	health_changed.emit()
	
func change_energy(change: int):
	Savegame.player.energy += change
	if Savegame.player.energy > 100:
		Savegame.player.energy = 100
	if Savegame.player.energy < 0:
		change_health(Savegame.player.energy)
		Savegame.player.energy = 0
	energy_changed.emit()

func set_water(value: int):
	Savegame.player.water = value
	water_changed.emit()

func set_health(value: int):
	Savegame.player.health = value
	health_changed.emit()
	
func set_energy(value: int):
	Savegame.player.energy = value
	energy_changed.emit()
#endregion
