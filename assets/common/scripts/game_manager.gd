extends Node

signal time_incremented
signal grid_updated
signal current_zone_updated
signal inventory_updated(item_id: String, value: int)
signal hotbar_updated
signal item_selected(item_id: String)
signal scanner_attr_updated(attr: SoilAttr)
signal cell_hovered(cell: Vector2i)
signal stat_updated(stat: String)
signal dialogue_initiated(script: String)

const items_dt: Datatable = preload("res://assets/datatables/tables/items_dt.tres")
const crops_dt: Datatable = preload("res://assets/datatables/tables/crops_dt.tres")

const crop_scn = preload("res://assets/crops/scenes/crop.tscn")

const soil_attr_labels = {
	SoilAttr.NITROGEN: "Nitrogen",
	SoilAttr.RADIATION: "Radiation",
	SoilAttr.HYDRATION: "Hydration",
	SoilAttr.ACIDITY: "Acidity"
}

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

func _shortcut_input(event):
	if event.is_action_pressed("increment_day"):
		increment_time()
		get_viewport().set_input_as_handled()

#region Zones
var current_zone: Zone

func register_zone(zone: Zone):
	current_zone = zone
	if not Savegame.zones.soil_attrs.has(zone.zone_id):
		Savegame.zones.soil_attrs[zone.zone_id] = ZoneLayouts.initial_zones.soil_attrs.get(zone.zone_id, init_grid_attributes())
	if not Savegame.zones.crops.has(zone.zone_id):
		Savegame.zones.crops[zone.zone_id] = ZoneLayouts.initial_zones.crops.get(zone.zone_id, {})
	update_grid_texture()
	current_zone_updated.emit()

func deregister_zone(zone: Zone):
	if zone == current_zone:
		current_zone = null
		current_zone_updated.emit()

func save_initial_zone_layout():
	ZoneLayouts.initial_zones.soil_attrs[current_zone.zone_id] = Savegame.zones.soil_attrs[current_zone.zone_id]
	ZoneLayouts.initial_zones.crops[current_zone.zone_id] = Savegame.zones.crops[current_zone.zone_id]
	ZoneLayouts.save_file()
#endregion

#region Grid
enum SoilAttr {
	NITROGEN,
	RADIATION,
	HYDRATION,
	ACIDITY
}

func notify_cell_hovered(cell: Vector2i):
	cell_hovered.emit(cell)

func get_soil_attrs_for_zone(zone_id: String):
	var grid = Savegame.zones.soil_attrs.get(zone_id)
	if not grid:
		Savegame.zones.soil_attrs[zone_id] = {}
		grid = Savegame.zones.soil_attrs[zone_id]
	return grid

func get_soil_attrs_for_current_zone():
	return get_soil_attrs_for_zone(current_zone.zone_id)

func update_grid_attribute(center: Vector2i, attr: SoilAttr, change: float, radius: float = 5, falloff: float = 0.2, zone_id: String = current_zone.zone_id):
	var fade_distance = radius * falloff
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var point = Vector2i(x,y)
			var dist = Vector2(point).distance_to(center)
			var zone = get_soil_attrs_for_zone(zone_id)
			if dist <= radius and zone.has(point):
				var scaled_change = change * clampf(1 - ((dist - fade_distance) / (radius - fade_distance)), 0, 1) # scale down over distance
				zone[point][attr] = clampf(zone[point][attr] + scaled_change, 0, 1)
	if zone_id == current_zone.zone_id:
		update_grid_texture()
	grid_updated.emit()

func update_grid_texture():
	var border = 10
	var grid = GameManager.current_zone.grid
	var soil_attrs = GameManager.get_soil_attrs_for_zone(current_zone.zone_id)
	var lower_bounds: Vector2i = grid.get_lower_cell_bounds()
	var upper_bounds: Vector2i = grid.get_upper_cell_bounds()
	var grid_attr_image: Image = Image.create(grid.width + border*2, grid.height + border*2, true, Image.FORMAT_RGBA8)
	for x in range(lower_bounds.x, upper_bounds.x):
		for y in range(lower_bounds.y, upper_bounds.y):
			var color = Color(1,0,1, 1)
			var point = Vector2i(x,y)
			if not grid.disabled_cells.has(point) and soil_attrs.has(point):
				var val = soil_attrs.get(point)
				color = Color(val[SoilAttr.NITROGEN], val[SoilAttr.RADIATION], val[SoilAttr.HYDRATION], val[SoilAttr.ACIDITY])
			grid_attr_image.set_pixel(x - lower_bounds.x + border, y - lower_bounds.y + border, color)
	var grid_image_texture = ImageTexture.create_from_image(grid_attr_image)
	RenderingServer.global_shader_parameter_set("grid_attributes", grid_image_texture)

func init_grid_attributes() -> Dictionary:
	var map = {}
	var lower_bounds: Vector2i = current_zone.grid.get_lower_cell_bounds()
	var upper_bounds: Vector2i = current_zone.grid.get_upper_cell_bounds()
	for x in range(lower_bounds.x, upper_bounds.x):
		for y in range(lower_bounds.y, upper_bounds.y):
			map[Vector2i(x,y)] = {
				SoilAttr.NITROGEN: 0.8,
				SoilAttr.RADIATION: 0.3,
				SoilAttr.HYDRATION: 0.6,
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
	return get_crops_in_zone(current_zone.zone_id)

func get_crop_in_current_zone(cell: Vector2i):
	return get_crops_in_current_zone().get(cell)

func rest():
	change_stat("radiation", Consts.REST_RADIATION)
	change_energy(Consts.REST_ENERGY)
	increment_time()
	Savegame.save_file()

func increment_time():
	Savegame.player.time += 1
	update_crops()
	plant_weeds()
	time_incremented.emit()

func get_hour_of_day() -> int:
	return Savegame.player.time % 24

func update_crops():
	for zone_id in Savegame.zones.crops:
		for crop_cell in Savegame.zones.crops[zone_id]:
			var crop_entry = get_crops_in_zone(zone_id)[crop_cell]
			var crop_details: CropConfigRow = crops_dt.get_row(crop_entry.seed_id)
			if crop_entry.health == 0:
				var can_decay = crop_entry.seed_id == "weed" or GameManager.get_item_count(crop_entry.seed_id) > 2
				if can_decay && RandomNumberGenerator.new().randf() < Consts.DECAY_CHANCE:
					remove_crop(crop_cell, zone_id)
					update_grid_attribute(crop_cell, SoilAttr.NITROGEN, Consts.DECAY_NITROGEN, 5, 0.2, zone_id)
			else:
				var health = get_crop_health(zone_id, crop_cell, crop_entry.seed_id)
				crop_entry.days_planted += 1
				if health <= Consts.CROP_MIN_HEALTH:
					crop_entry.health = 0
					crop_entry.growth = 0
				else:
					crop_entry.health = lerpf(crop_entry.health, health, 0.5)
					crop_entry.growth += health
					for attr in crop_details.attributes:
						if attr.change != 0:
							update_grid_attribute(
								crop_cell,
								attr.attribute,
								attr.change,
								crop_details.effect_radius,
								crop_details.planting_radius / crop_details.effect_radius,
								zone_id
							)

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
				if valid and RandomNumberGenerator.new().randf() < Consts.WEED_SPAWN_CHANCE:
					plant_crop("weed", grid_cell)

func get_crop_health(zone_id: String, cell: Vector2i, seed_id: String) -> float:
	var cell_attrs = get_soil_attrs_for_zone(zone_id).get(cell, {})
	var crop: CropConfigRow = crops_dt.get_row(seed_id)
	return crop.attributes.reduce(
		func(acc, attr):
			return acc + attr.requirement.sample(cell_attrs.get(attr.attribute,0))
	,0) / len(crop.attributes)

func plant_crop(seed_id: String, cell: Vector2i, zone_id: String = current_zone.zone_id):
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

func remove_crop(cell: Vector2i, zone_id: String = current_zone.zone_id):
	get_crops_in_zone(zone_id).erase(cell)
	current_zone.crops[cell].queue_free()
	grid_updated.emit()

func spawn_crop_at_cell(cell: Vector2i):
	var crop: Crop = crop_scn.instantiate()
	current_zone.add_child(crop)
	current_zone.crops[cell] = crop
	crop.place(cell)

func is_crop_harvestable(zone_id: String, cell: Vector2i):
	return is_crop_ripe(zone_id, cell) or is_crop_dead(zone_id, cell)

func is_crop_ripe(zone_id: String, cell: Vector2i):
	var crop_entry = get_crops_in_zone(zone_id).get(cell, null)
	if not crop_entry:
		return false
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
func get_player() -> PlayerCharacter:
	return current_zone.player_character

func get_speed():
	var energy = get_stat("energy")
	if energy <= 0:
		return 1.5
	if energy < 0.2:
		return 2.5
	return 5

func get_stat(stat: String):
	return Savegame.player.stats.get(stat, 0)

func set_stat(stat: String, value: float):
	Savegame.player.stats[stat] = value
	stat_updated.emit(stat)

func change_stat(stat: String, change: float, min_val: float = 0, max_val: float = 1):
	var value = clamp(get_stat(stat) + change, min_val, max_val)
	set_stat(stat, value)

func change_energy(change: float):
	change_stat("energy", change, 0, 1 - get_stat("radiation"))
#endregion

#region Dialogue
func initiate_dialogue(script: String):
	dialogue_initiated.emit(script)
#endregion
