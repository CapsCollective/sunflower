extends MarginContainer

const tri_icon = preload("res://addons/terrain/icons/tri.svg")
const plane_icon = preload("res://addons/terrain/icons/plane.svg")

enum TerrainEditorEditMode {
	SELECT,
	HEIGHT,
	COLOUR,
	RESIZE
}

enum TerrainEditorSelectMode {
	TRI,
	PLANE
}

var editor_plugin: EditorPlugin
var current_terrain: Terrain

var modes_select_btn: OptionButton
var select_mode_btn_group: ButtonGroup = ButtonGroup.new()
var select_mode_btns: Dictionary = {}
var edit_mode_controls: VBoxContainer
var colour_select_btn: OptionButton
var height_spinbox: SpinBox
var resize_controls: VBoxContainer
var rows_spinbox: SpinBox
var cols_spinbox: SpinBox
var resize_btn: Button

func _init(plugin: EditorPlugin):
	editor_plugin = plugin

func _ready():
	add_theme_constant_override("margin_left", 10)
	
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	vbox.add_child(HSeparator.new())
	
	modes_select_btn = OptionButton.new()
	modes_select_btn.add_item("Select", 0)
	modes_select_btn.add_item("Height", 1)
	modes_select_btn.add_item("Colour", 2)
	modes_select_btn.add_item("Resize", 3)
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
	
	resize_controls = VBoxContainer.new()
	
	rows_spinbox = SpinBox.new()
	rows_spinbox.step = 1
	rows_spinbox.min_value = 1
	rows_spinbox.suffix = "rows"
	resize_controls.add_child(rows_spinbox)
	
	cols_spinbox = SpinBox.new()
	cols_spinbox.step = 1
	rows_spinbox.min_value = 1
	cols_spinbox.suffix = "cols"
	resize_controls.add_child(cols_spinbox)
	
	resize_btn = Button.new()
	resize_btn.text = "Resize"
	resize_btn.pressed.connect(on_resize_button_pressed)
	resize_controls.add_child(resize_btn)
	
	refresh()

func set_current_terrain(terrain: Terrain):
	current_terrain = terrain
	refresh()

func refresh():
	if not current_terrain:
		return
	
	if colour_select_btn:
		colour_select_btn.clear()
		for colour_id in current_terrain.uv_ids:
			colour_select_btn.add_item(colour_id)
	
	if rows_spinbox and cols_spinbox:
		rows_spinbox.value = current_terrain.rows
		cols_spinbox.value = current_terrain.cols

func on_mode_selected(idx: int):
	for child in edit_mode_controls.get_children():
		edit_mode_controls.remove_child(child)
	match(idx):
		TerrainEditorEditMode.HEIGHT:
			edit_mode_controls.add_child(height_spinbox)
		TerrainEditorEditMode.COLOUR:
			edit_mode_controls.add_child(colour_select_btn)
		TerrainEditorEditMode.RESIZE:
			edit_mode_controls.add_child(resize_controls)

func on_resize_button_pressed():
	var undo_redo: EditorUndoRedoManager = editor_plugin.get_undo_redo()
	undo_redo.create_action("Resize terrain row-cols", UndoRedo.MERGE_DISABLE, null, false)
	undo_redo.add_do_method(self, "resize_terrain_row_cols", current_terrain, rows_spinbox.value, cols_spinbox.value)
	undo_redo.add_undo_method(self, "resize_terrain_row_cols", current_terrain, current_terrain.rows, current_terrain.cols)
	undo_redo.commit_action()

func resize_terrain_row_cols(terrain: Terrain, rows: int, cols: int):
	terrain.rows = rows
	terrain.cols = cols
	terrain.generate_mesh()
	terrain.generate_collision()

func get_height_value() -> float:
	return height_spinbox.value

func get_colour_id():
	return colour_select_btn.get_item_text(colour_select_btn.get_selected_id())

func get_select_mode() -> TerrainEditorSelectMode:
	var pressed = select_mode_btn_group.get_pressed_button()
	return select_mode_btns.get(pressed, TerrainEditorSelectMode.TRI)

func get_edit_mode() -> TerrainEditorEditMode:
	return modes_select_btn.get_selected_id()
