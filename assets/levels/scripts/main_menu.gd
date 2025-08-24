extends Node

const main_menu_ui_scn = preload("res://assets/menus/scenes/main_menu_ui.tscn")

func _ready() -> void:
	GameManager.game_world.ui.add_child(main_menu_ui_scn.instantiate())
