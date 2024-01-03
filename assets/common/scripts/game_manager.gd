extends Node

signal load_completed
signal grid_updated

var game_world: GameWorld:
	set(world):
		Utils.log_info("Initialisation", "Game world registered")
		game_world = world

var current_zone: Zone

func _ready():
	Savegame.load_file()
	Utils.log_info("Deserialisation", Savegame.get_dump())
	load_completed.emit()

func register_zone(zone: Zone):
	current_zone = zone

func deregister_zone(zone: Zone):
	if zone == current_zone:
		current_zone = null

const GRID_PROPERTIES = [
	'nutrition',
	'hydration',
	'radiation',
]
const GRID_WIDTH = 20
const GRID_HEIGHT = 20

func get_grid_point(pos: Vector3) -> Dictionary:
	var point = current_zone.grid.get_point(pos)
	return Savegame.player.area_map[point]

func update_grid_property(center: Vector2i, property: String, radius: int, change: float):
	if not GRID_PROPERTIES.has(property):
		push_error("Grid does not have property " + property)
		return
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var point = Vector2i(x,y)
			var dist = Vector2(point).distance_to(center)
			var scaled_change = change * (radius - dist) / radius # scale down over distance
			if dist <= radius and Savegame.player.area.has(Vector2i(x,y)):
				print("%s,%s: %s" % [x, y, Savegame.player.area[Vector2i(x,y)]])
				Savegame.player.area[Vector2i(x,y)][property] = clampf(Savegame.player.area[point][property] + scaled_change, 0, 1)
	grid_updated.emit()

func init_map() -> Dictionary:
	var map = {}
	for x in range(40):
		for y in range(40):
			map[Vector2i(x,y)] = {
				'nutrition': 0,
				'hydration': 0,
				'radiation': 0.5
			}
	return map
