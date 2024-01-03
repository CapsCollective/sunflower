extends DebugSection

const levels_dt_path: String = "res://assets/content/levels_dt.tres"

@onready var level_options: OptionButton = %LevelOptions
@onready var load_button: Button = %LoadButton
@onready var grid_texture: TextureRect = %GridTexture
@onready var x_pos: SpinBox = %XPos
@onready var y_pos: SpinBox = %YPos
@onready var radius_input: SpinBox = %Radius
@onready var change_input: SpinBox = %Change
@onready var update_button: Button = %UpdateButton

var selected_property = 'nutrition'

func _ready():
	load_button.button_up.connect(on_load_button_up)
	update_button.button_up.connect(on_update_button_up)
	GameManager.grid_updated.connect(refresh_grid)

func on_opened():
	refresh_content()

func on_load_button_up():
	var levels_dt: Datatable = load(levels_dt_path)
	var row = levels_dt.get_row(level_options.get_selected_id())
	GameManager.game_world.load_level(row.path)

func on_update_button_up():
	GameManager.update_grid_property(Vector2i(x_pos.value, y_pos.value), selected_property, radius_input.value, change_input.value)

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
			image.set_pixel(x, y, Color.DARK_RED.lerp(Color.DARK_GREEN, Savegame.player.area[Vector2i(x,y)][selected_property]))
	grid_texture.texture.set_image(image)
