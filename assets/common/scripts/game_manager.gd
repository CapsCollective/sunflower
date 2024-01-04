extends Node

signal load_completed
signal grid_updated
signal zone_changed

var game_world: GameWorld:
	set(world):
		Utils.log_info("Initialisation", "Game world registered")
		game_world = world

var current_zone: Zone

func _ready():
	Savegame.load_file()
	Utils.log_info("Deserialisation", "Operation completed")
	load_completed.emit()

func register_zone(zone: Zone):
	current_zone = zone
	if not Savegame.player.zones.has(zone.id):
		Savegame.player.zones[zone.id] = init_map()
	zone_changed.emit()

func deregister_zone(zone: Zone):
	if zone == current_zone:
		current_zone = null
		zone_changed.emit()

const GRID_PROPERTIES = [
	'nutrition',
	'hydration',
	'radiation',
]

func get_grid_point(pos: Vector3) -> Dictionary:
	var point = current_zone.grid.get_cell_by_position(pos)
	return Savegame.player.area_map[point]

func update_grid_property(center: Vector2i, property: String, radius: int, change: float):
	if not GRID_PROPERTIES.has(property):
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
	Savegame.save_file()

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
