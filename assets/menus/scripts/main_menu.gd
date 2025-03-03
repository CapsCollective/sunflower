extends Control

@export_file("*.scn", "*.tscn") var main_zone_scn: String
@export_file("*.scn", "*.tscn") var intro_crawl_scn: String

@onready var new_game_btn: Button = $VBoxContainer/NewGameButton

# TODO: Hide if no save game exists
@onready var continue_btn: Button = $VBoxContainer/ContinueButton

func _ready() -> void:
	new_game_btn.pressed.connect(on_new_game_btn_pressed)
	continue_btn.pressed.connect(on_continue_btn_pressed)

func on_new_game_btn_pressed():
	# TODO: Reset game state here
	GameManager.game_world.load_level(main_zone_scn, {}, intro_crawl_scn)

func on_continue_btn_pressed():
	# TODO: Link up to save game system
	GameManager.game_world.load_level(main_zone_scn, {"spawn_location": ""})
