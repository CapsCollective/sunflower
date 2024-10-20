class_name SelectionCursor extends MeshInstance3D

const quality_gradient: Gradient = preload("res://assets/content/quality_gradient.tres")
const health_gradient: Gradient = preload("res://assets/content/health_gradient.tres")
const radius_marker_scn = preload("res://assets/character/scenes/radius_marker.tscn")
const PIXEL_SIZE = 0.01

@onready var grid_overlay: Sprite3D = %GridOverlay
@onready var markers_container: Node3D = %RadiusMarkers

var enabled: bool:
	set(v):
		enabled = v
		var material = get_surface_override_material(0)
		if material:
			material.albedo_color = Color(1.0, 1.0, 1.0, 0.15) if enabled else Color(1.0, 0.0, 0.0, 0.3)

var radius: int:
	set(r):
		radius = r
		update_grid_overlay()

var selected_grid_attr: GameManager.SoilAttr:
	set(attr):
		selected_grid_attr = attr
		update_grid_overlay()

var cell_select_predicate: Callable
var hovered_cell: Vector2i

func _ready():
	GameManager.grid_updated.connect(update_grid_overlay)
	selected_grid_attr = GameManager.SoilAttr.HYDRATION

func _process(_delta):
	var cursor_pos = Utils.get_perspective_collision_ray_point(self, false, 2)
	if not cursor_pos:
		enabled = false
	else:
		var grid: Grid3D = GameManager.current_zone.grid
		var quantised_pos = grid.get_quantised_position(cursor_pos)
		global_position = quantised_pos
		var cell = grid.get_cell_by_position(quantised_pos)
		if hovered_cell != cell:
			hovered_cell = cell
			GameManager.cell_hovered.emit(cell)
			enabled = grid.is_cell_valid(cell) \
				and (not cell_select_predicate.is_valid() or cell_select_predicate.call(cell))
			update_grid_overlay()

func update_grid_overlay():
	var fade_distance = radius - 2 # Fade out over last 2 rings
	var diameter = radius * 2 + 1
	var grid = GameManager.current_zone.grid
	var soil_attrs = GameManager.get_soil_attrs_for_current_zone()
	var image: Image = Image.create(diameter, diameter, true, Image.FORMAT_RGBA8)
	for x in range(diameter):
		for y in range(diameter):
			var color = Color.TRANSPARENT
			var point = Vector2i(hovered_cell.x + x - radius, hovered_cell.y + y - radius)
			if soil_attrs.has(point) and not grid.disabled_cells.has(point):
				var dist = Vector2(point).distance_to(hovered_cell)
				var score = 0
				if GameManager.crops_dt.has(GameManager.selected_item):
					score = GameManager.get_crop_health(GameManager.current_zone.id, point, GameManager.selected_item)
					color = health_gradient.sample(score)
				else:
					score = soil_attrs[point][selected_grid_attr]
					color = quality_gradient.sample(score)
				color.a = 0.2 * clampf(1 - ((dist - fade_distance) / (radius - fade_distance)), 0,1)
			image.set_pixel(x, y, color)
	(grid_overlay.texture as ImageTexture).set_image(image)

func clear_radius_markers():
	Utils.queue_free_children(markers_container)

func add_radius_markers(markers: Array):
	for marker in markers:
		var instance: Sprite3D = radius_marker_scn.instantiate()
		markers_container.add_child(instance)
		instance.pixel_size = PIXEL_SIZE * marker.radius
		instance.global_position = GameManager.current_zone.grid.get_position_by_cell(marker.cell) + Vector3(0, 0.01, 0)
