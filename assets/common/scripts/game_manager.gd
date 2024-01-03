extends Node

signal load_completed

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

var GRID_PROPERTIES = [
	'nutrition',
	'hydration',
	'radiation',
]

func get_grid_point(pos: Vector3) -> Dictionary:
	var point = current_zone.grid.get_point(pos)
	return Savegame.player.area_map[point]

func update_grid(center: Vector2i, property: String, radius: int, change: float):
	if not GRID_PROPERTIES.has(property):
		push_error("Grid does not have property " + property)
		return
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var point = Vector2(x,y)
			var dist = point.distance_to(center)
			var scaled_change = change * (radius - dist) / radius # scale down over distance
			if dist < radius:
				Savegame.player.area_map[Vector2(x,y)][property] = clampf(Savegame.player.area_map[point][property] + scaled_change, 0, 1)

