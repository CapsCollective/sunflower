extends MarginContainer

const tri_icon = preload("res://addons/terrain/icons/tri.svg")
const plane_icon = preload("res://addons/terrain/icons/plane.svg")

enum TerrainEditorEditMode {
	SELECT,
	HEIGHT,
	COLOUR
}

enum TerrainEditorSelectMode {
	TRI,
	PLANE
}

var current_terrain: Terrain

var modes_select_btn: OptionButton

var select_mode_btn_group: ButtonGroup = ButtonGroup.new()
var select_mode_btns: Dictionary = {}

func _ready():
	add_theme_constant_override("margin_left", 10)
	refresh()

func refresh():
	for child in get_children():
		child.queue_free()
	select_mode_btns.clear()
	
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	vbox.add_child(HSeparator.new())
	
	modes_select_btn = OptionButton.new()
	modes_select_btn.add_item("Select", 0)
	modes_select_btn.add_item("Height", 1)
	modes_select_btn.add_item("Colour", 2)
	vbox.add_child(modes_select_btn)
	
	vbox.add_child(HSeparator.new())
	
	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	
	var plane_select_mode_btn = Button.new()
	plane_select_mode_btn.icon = plane_icon
	plane_select_mode_btn.theme_type_variation = "FlatButton"
	plane_select_mode_btn.toggle_mode = true
	plane_select_mode_btn.button_group = select_mode_btn_group
	hbox.add_child(plane_select_mode_btn)
	select_mode_btns[plane_select_mode_btn] = TerrainEditorSelectMode.PLANE
	plane_select_mode_btn.set_pressed_no_signal(true)
	
	var tri_select_mode_btn = Button.new()
	tri_select_mode_btn.icon = tri_icon
	tri_select_mode_btn.theme_type_variation = "FlatButton"
	tri_select_mode_btn.toggle_mode = true
	tri_select_mode_btn.button_group = select_mode_btn_group
	hbox.add_child(tri_select_mode_btn)
	select_mode_btns[tri_select_mode_btn] = TerrainEditorSelectMode.TRI
	
	vbox.add_child(HSeparator.new())
	
	var modes_select_1 = OptionButton.new()
	modes_select_1.add_item("blue", 0)
	modes_select_1.add_item("red", 1)
	vbox.add_child(modes_select_1)
	
	var box = SpinBox.new()
	box.step = 0.1
	vbox.add_child(box)

func get_select_mode() -> TerrainEditorSelectMode:
	var pressed = select_mode_btn_group.get_pressed_button()
	return select_mode_btns.get(pressed, TerrainEditorSelectMode.TRI)

func get_edit_mode() -> TerrainEditorEditMode:
	return modes_select_btn.get_selected_id()

func set_current_terrain(terrain: Terrain):
	current_terrain = terrain
