extends DebugSection

const levels_dt_path: String = "res://assets/content/levels_dt.tres"

@onready var level_options: OptionButton = %LevelOptions
@onready var load_button: Button = %LoadButton

func _ready():
	load_button.button_up.connect(on_load_button_up)

func on_opened():
	refresh_content()

func on_load_button_up():
	var levels_dt: Datatable = load(levels_dt_path)
	var row = levels_dt.get_row(level_options.get_selected_id())
	GameManager.game_world.load_level(row.path)

func refresh_content():
	level_options.clear()
	var levels_dt: Datatable = load(levels_dt_path)
	for entry in levels_dt:
		level_options.add_item(entry.value.name, entry.key)
