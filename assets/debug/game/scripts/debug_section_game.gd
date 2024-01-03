extends DebugSection

const levels_dt_path: String = "res://assets/content/levels_dt.tres"

@onready var level_options: OptionButton = %LevelOptions
@onready var load_button: Button = %LoadButton
@onready var grid_texture: TextureRect = %GridTexture
@onready var x_pos: Range = %XPos
@onready var y_pos: Range = %YPos
@onready var radius_input: Range = %Radius
@onready var change_input: Range = %Change
@onready var update_button: Button = %UpdateButton
@onready var grid_property: OptionButton = %GridProperty

var selected_property = 'nutrition'

func _ready():
	load_button.button_up.connect(on_load_button_up)
	update_button.button_up.connect(on_update_button_up)
	GameManager.grid_updated.connect(refresh_grid)
	x_pos.value_changed.connect(on_slider_updated)
	y_pos.value_changed.connect(on_slider_updated)
	grid_property.item_selected.connect(on_property_selected)

func on_opened():
	refresh_content()

func on_load_button_up():
	var levels_dt: Datatable = load(levels_dt_path)
	var row = levels_dt.get_row(level_options.get_selected_id())
	GameManager.game_world.load_level(row.path)

func on_update_button_up():
	GameManager.update_grid_property(Vector2i(int(x_pos.value), int(y_pos.max_value - y_pos.value)), selected_property, int(radius_input.value), change_input.value)

func on_property_selected(value: int):
	selected_property = ['hydration', 'nutrition', 'radiation'][value]
	refresh_grid()
	
func on_slider_updated(value: float):
	refresh_grid()

func refresh_content():
	refresh_grid()
	level_options.clear()
	var levels_dt: Datatable = load(levels_dt_path)
	
	for entry in levels_dt:
		level_options.add_item(entry.value.name, entry.key)

func refresh_grid():
	var grid = GameManager.current_zone.grid
	var image: Image = Image.create(grid.width, grid.height, true, Image.FORMAT_RGBA8)
	for x in range(grid.width):
		for y in range(grid.height):
			var color = Color.BLACK.lerp(Color.WHITE, Savegame.player.area[Vector2i(x,y)][selected_property])
			if x == x_pos.value and y == (y_pos.max_value - y_pos.value):
				color = Color.DARK_GREEN
			image.set_pixel(x, y, color)
	grid_texture.texture.set_image(image)
