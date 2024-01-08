class_name SelectionCursor extends MeshInstance3D

@onready var grid_overlay: Sprite3D = %GridOverlay

var enabled: bool:
	set(v):
		enabled = v
		var material = get_surface_override_material(0)
		if material:
			material.albedo_color = Color(1.0, 1.0, 1.0, 0.15) if enabled else Color(1.0, 0.0, 0.0, 0.15)

var cell_select_predicate: Callable
var run_action_callback: Callable

var hovered_cell: Vector2i

func _process(_delta):
	if visible:
		var pos = Utils.get_perspective_collision_ray_point(self, false, 2)
		if not pos:
			enabled = false
		else:
			var grid: Grid3D = GameManager.current_zone.grid
			var quantised_pos = grid.get_quantised_position(pos)
			global_position = quantised_pos
			var cell = grid.get_cell_by_position(quantised_pos)
			if hovered_cell != cell:
				hovered_cell = cell
				enabled = grid.is_cell_valid(cell) \
					and (not cell_select_predicate or cell_select_predicate.call(cell))
				update_grid_overlay()
				
const radius = 5 #TODO tie this to selected items radius
const fade_distance = radius - 2 # Fade out over last 2 rings
func update_grid_overlay():
	var diameter = radius * 2 + 1
	var grid = GameManager.current_zone.grid
	var zone = Savegame.player.zones[GameManager.current_zone.id]
	var image: Image = Image.create(diameter, diameter, true, Image.FORMAT_RGBA8)
	for x in range(diameter):
		for y in range(diameter):
			var color = Color.TRANSPARENT
			var point = Vector2i(hovered_cell.x + x - radius, hovered_cell.y + y - radius)
			if zone.has(point) and not grid.disabled_cells.has(point):
				var dist = Vector2(point).distance_to(hovered_cell)
				color = Color.RED.lerp(Color.GREEN, zone[point]['hydration'])
				color.a = 0.2 * clampf(1 - ((dist - fade_distance) / (radius - fade_distance)), 0,1)
			image.set_pixel(x, y, color)
	(grid_overlay.texture as ImageTexture).set_image(image)

func get_hovered_cell():
	var pos = Utils.get_perspective_collision_ray_point(self)
	if pos:
		return GameManager.current_zone.grid.get_cell_by_position(pos)
	return null
