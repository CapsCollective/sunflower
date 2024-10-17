extends PanelContainer

var attr_checkboxes: Dictionary = {}

@onready var options_container: Container = %OptionsContainer
@onready var button_group: ButtonGroup = ButtonGroup.new()

func _ready():
	visible = false
	GameManager.item_selected.connect(on_item_selected)
	GameManager.scanner_attr_updated.connect(on_attr_updated)
	button_group.pressed.connect(on_attr_selected)
	for attr in GameManager.soil_attr_labels:
		var checkbox: CheckBox = CheckBox.new()
		checkbox.text = GameManager.soil_attr_labels[attr]
		checkbox.button_group = button_group
		attr_checkboxes[checkbox] = attr
		options_container.add_child(checkbox)

func on_item_selected(item: String):
	visible = item == "scanner"
	if visible:
		GameManager.scanner_attr = GameManager.SoilAttr.HYDRATION

func on_attr_updated(attr: GameManager.SoilAttr):
	for button in button_group.get_buttons():
		button.set_pressed_no_signal(attr_checkboxes[button] == attr)

func on_attr_selected(button: CheckBox):
	GameManager.scanner_attr = attr_checkboxes[button]
