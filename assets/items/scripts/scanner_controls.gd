extends PanelContainer

const grid_props_dt: Datatable = preload("res://assets/content/grid_props_dt.tres")

var prop_checkboxes: Dictionary = {}

@onready var options_container: Container = %OptionsContainer
@onready var button_group: ButtonGroup = ButtonGroup.new()

func _ready():
	visible = false
	GameManager.item_selected.connect(on_item_selected)
	GameManager.scanner_prop_updated.connect(on_prop_updated)
	button_group.pressed.connect(on_prop_selected)
	for option in grid_props_dt:
		var checkbox: CheckBox = CheckBox.new()
		checkbox.text = option.value.name
		checkbox.button_group = button_group
		prop_checkboxes[checkbox] = option.key
		options_container.add_child(checkbox)

func on_item_selected(item: String):
	visible = item == "scanner"
	if item == "scanner":
		GameManager.scanner_prop = 'acidity'
		
func on_prop_updated(prop: String):
	for button in button_group.get_buttons():
		button.set_pressed_no_signal(prop_checkboxes[button] == prop)
	
func on_prop_selected(button: CheckBox):
	GameManager.scanner_prop = prop_checkboxes[button]
