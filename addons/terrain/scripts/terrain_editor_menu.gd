extends HBoxContainer

const terrain_icon = preload("res://addons/terrain/icons/terrain.svg")

var current_terrain: Terrain

func _ready():
	var menu_btn = MenuButton.new()
	menu_btn.text = "Terrain"
	menu_btn.icon = terrain_icon
	menu_btn.get_popup().add_item("Regenerate All", 0)
	menu_btn.get_popup().add_item("Clean Up", 1)
	menu_btn.get_popup().add_separator()
	menu_btn.get_popup().add_item("Regenerate Mesh", 2)
	menu_btn.get_popup().add_item("Regenerate Collision", 3)
	menu_btn.get_popup().add_separator()
	menu_btn.get_popup().add_item("Reset", 4)
	menu_btn.get_popup().id_pressed.connect(on_id_pressed)
	add_child(menu_btn)

func set_current_terrain(terrain: Terrain):
	current_terrain = terrain

func on_id_pressed(id: int):
	match(id):
		0:
			current_terrain.generate_mesh()
			current_terrain.generate_collision()
		1:
			current_terrain.clean()
		2:
			current_terrain.generate_mesh()
		3:
			current_terrain.generate_collision()
		4:
			current_terrain.reset()
