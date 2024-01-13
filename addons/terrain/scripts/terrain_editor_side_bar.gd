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
var edit_mode_controls: VBoxContainer
var colour_select_btn: OptionButton
var height_spinbox: SpinBox

func _ready():
	add_theme_constant_override("margin_left", 10)
	
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	vbox.add_child(HSeparator.new())
	
	modes_select_btn = OptionButton.new()
	modes_select_btn.add_item("Select", 0)
	modes_select_btn.add_item("Height", 1)
	modes_select_btn.add_item("Colour", 2)
	modes_select_btn.item_selected.connect(on_mode_selected)
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
	
	edit_mode_controls = VBoxContainer.new()
	vbox.add_child(edit_mode_controls)
	
	colour_select_btn = OptionButton.new()
	
	height_spinbox = SpinBox.new()
	height_spinbox.step = 0.1
	height_spinbox.allow_greater = true
	height_spinbox.allow_lesser = true
	
	refresh()

func refresh():
	if current_terrain and colour_select_btn:
		colour_select_btn.clear()
		for colour_id in current_terrain.uv_ids:
			colour_select_btn.add_item(colour_id)

func on_mode_selected(idx: int):
	for child in edit_mode_controls.get_children():
		edit_mode_controls.remove_child(child)
	match(idx):
		TerrainEditorEditMode.HEIGHT:
			edit_mode_controls.add_child(height_spinbox)
		TerrainEditorEditMode.COLOUR:
			edit_mode_controls.add_child(colour_select_btn)

func get_height_value() -> float:
	return height_spinbox.value

func get_colour_id():
	return colour_select_btn.get_item_text(colour_select_btn.get_selected_id())

func get_select_mode() -> TerrainEditorSelectMode:
	var pressed = select_mode_btn_group.get_pressed_button()
	return select_mode_btns.get(pressed, TerrainEditorSelectMode.TRI)

func get_edit_mode() -> TerrainEditorEditMode:
	return modes_select_btn.get_selected_id()

func set_current_terrain(terrain: Terrain):
	current_terrain = terrain
	refresh()
