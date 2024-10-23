extends DebugSection

const quality_gradient: Gradient = preload("res://assets/content/crops/data/quality_gradient.tres")
const levels_dt: Datatable = preload("res://assets/datatables/tables/levels_dt.tres")

@onready var level_options: OptionButton = %LevelOptions
@onready var load_button: Button = %LoadButton
@onready var grid_texture: TextureRect = %GridTexture
@onready var x_slider: Range = %XPos
@onready var y_slider: Range = %YPos
@onready var radius_input: Range = %Radius
@onready var change_input: Range = %Change
@onready var grid_attribute_options: OptionButton = %GridAttributeOptions
@onready var update_button: Button = %UpdateButton
@onready var save_zone_button: Button = %SaveZoneButton
@onready var next_day_button: Button = %NextDayButton

var selected_attribute: GameManager.SoilAttr = GameManager.SoilAttr.HYDRATION
var selected_point: Vector2i:
	get:
		return Vector2i(int(x_slider.value), -int(y_slider.value))

func _ready():
	for attr in GameManager.soil_attr_labels:
		grid_attribute_options.add_item(GameManager.soil_attr_labels[attr], attr)
	grid_attribute_options.select(0)
	selected_attribute = GameManager.SoilAttr.HYDRATION
	load_button.button_up.connect(on_load_button_up)
	update_button.button_up.connect(on_update_button_up)
	save_zone_button.button_up.connect(on_save_zone_button_up)
	next_day_button.button_up.connect(on_next_day_button_up)
	GameManager.grid_updated.connect(refresh_grid)
	GameManager.current_zone_updated.connect(refresh_grid)
	x_slider.value_changed.connect(on_slider_updated)
	y_slider.value_changed.connect(on_slider_updated)
	grid_attribute_options.item_selected.connect(on_attribute_selected)

func on_opened():
	refresh_content()

func on_load_button_up():
	var row = levels_dt.get_row(level_options.get_selected_id())
	GameManager.game_world.load_level(row.path)

func on_update_button_up():
	GameManager.update_grid_attribute_for_current_zone(selected_point, selected_attribute, change_input.value, int(radius_input.value))
	
func on_save_zone_button_up():
	GameManager.save_initial_zone_layout()

func on_next_day_button_up():
	GameManager.increment_time()

func on_attribute_selected(attr: GameManager.SoilAttr):
	selected_attribute = attr
	refresh_grid()
	
func on_slider_updated(_value: float):
	refresh_grid()

func refresh_content():
	refresh_grid()
	level_options.clear()
	for entry in levels_dt:
		level_options.add_item(entry.value.name, entry.key)

func refresh_grid():
	if not GameManager.current_zone or not GameManager.current_zone.grid:
		return
	var grid = GameManager.current_zone.grid
	var soil_attrs = GameManager.get_soil_attrs_for_current_zone()
	var image: Image = Image.create(grid.width, grid.height, true, Image.FORMAT_RGBA8)
	var lower_bounds: Vector2i = grid.get_lower_cell_bounds()
	var upper_bounds: Vector2i = grid.get_upper_cell_bounds()
	x_slider.min_value = lower_bounds.x
	x_slider.max_value = upper_bounds.x - 1
	y_slider.min_value = lower_bounds.y + 1
	y_slider.max_value = upper_bounds.y
	for x in range(lower_bounds.x, upper_bounds.x):
		for y in range(lower_bounds.y, upper_bounds.y):
			var color = Color.TRANSPARENT
			var point = Vector2i(x,y)
			if point == selected_point:
				color = Color.WHITE
			elif not grid.disabled_cells.has(point):
				var val = soil_attrs[point]
				color = quality_gradient.sample(val[selected_attribute])
			image.set_pixel(x - lower_bounds.x, y - lower_bounds.y, color)
	grid_texture.texture.set_image(image)
