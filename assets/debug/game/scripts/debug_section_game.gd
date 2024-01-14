extends DebugSection

const levels_dt_path: String = "res://assets/content/levels_dt.tres"

const grid_properties: Array[String] = [
	'hydration',
	'nutrition',
	'radiation'
]

@onready var level_options: OptionButton = %LevelOptions
@onready var load_button: Button = %LoadButton
@onready var grid_texture: TextureRect = %GridTexture
@onready var x_slider: Range = %XPos
@onready var y_slider: Range = %YPos
@onready var radius_input: Range = %Radius
@onready var change_input: Range = %Change
@onready var update_button: Button = %UpdateButton
@onready var grid_property: OptionButton = %GridProperty
@onready var next_day_button: Button = %NextDayButton

var selected_property = null
var selected_point: Vector2i:
	get:
		return Vector2i(int(x_slider.value), int(y_slider.max_value - y_slider.value))

func _ready():
	grid_property.select(0)
	selected_property = grid_properties[0]
	load_button.button_up.connect(on_load_button_up)
	update_button.button_up.connect(on_update_button_up)
	next_day_button.button_up.connect(on_next_day_button_up)
	GameManager.grid_updated.connect(refresh_grid)
	GameManager.current_zone_updated.connect(refresh_grid)
	x_slider.value_changed.connect(on_slider_updated)
	y_slider.value_changed.connect(on_slider_updated)
	grid_property.item_selected.connect(on_property_selected)

func on_opened():
	refresh_content()

func on_load_button_up():
	var levels_dt: Datatable = load(levels_dt_path)
	var row = levels_dt.get_row(level_options.get_selected_id())
	GameManager.game_world.load_level(row.path)

func on_update_button_up():
	GameManager.update_grid_property_for_current_zone(selected_point, selected_property, int(radius_input.value), change_input.value)
	
func on_next_day_button_up():
	GameManager.increment_day()

func on_property_selected(value: int):
	selected_property = grid_properties[value]
	refresh_grid()
	
func on_slider_updated(_value: float):
	refresh_grid()

func refresh_content():
	refresh_grid()
	level_options.clear()
	var levels_dt: Datatable = load(levels_dt_path)
	
	for entry in levels_dt:
		level_options.add_item(entry.value.name, entry.key)

func refresh_grid():
	if not GameManager.current_zone or not GameManager.current_zone.grid:
		return
	var grid = GameManager.current_zone.grid
	var zone = GameManager.get_grid_for_current_zone()
	var image: Image = Image.create(grid.width, grid.height, true, Image.FORMAT_RGBA8)
	var lower_bounds: Vector2i = grid.get_lower_cell_bounds()
	var upper_bounds: Vector2i = grid.get_upper_cell_bounds()
	
	for x in range(lower_bounds.x, upper_bounds.x):
		for y in range(lower_bounds.y, upper_bounds.y):
			var color = Color.TRANSPARENT
			var point = Vector2i(x,y)
			if point == selected_point:
				color = Color.DARK_GREEN
			elif not grid.disabled_cells.has(point):
				color = Color.BLACK.lerp(Color.WHITE, zone[point][selected_property])
			image.set_pixel(x - lower_bounds.x, y - lower_bounds.y, color)
	grid_texture.texture.set_image(image)
