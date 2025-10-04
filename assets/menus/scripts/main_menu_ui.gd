extends Control

@export_file("*.scn", "*.tscn") var initial_zone_scn: String
@export_file("*.scn", "*.tscn") var intro_crawl_scn: String

@onready var new_game_btn: Button = $VBoxContainer/NewGameButton
@onready var continue_btn: Button = $VBoxContainer/ContinueButton

func _ready() -> void:
	Savegame.load_file()
	Log.info("Deserialisation", "Operation completed")
	if not Savegame.metadata_section.has_valid_data():
		continue_btn.visible = false
	new_game_btn.pressed.connect(on_new_game_btn_pressed)
	continue_btn.pressed.connect(on_continue_btn_pressed)

func on_new_game_btn_pressed():
	Savegame.reset_file()
	GameManager.game_world.load_level(initial_zone_scn, {}, intro_crawl_scn)

func on_continue_btn_pressed():
	var levels_dt = load("res://assets/datatables/tables/levels_dt.tres")
	var row: LevelRow = levels_dt.get_row(Savegame.player.current_zone)
	GameManager.game_world.load_level(row.path, {
		"spawn_position": Savegame.player.current_position, 
		"spawn_rotation": Savegame.player.current_rotation
	})
