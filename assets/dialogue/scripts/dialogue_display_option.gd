extends Control

signal selected(value: Variant)

var option_text: String
var option_value: Variant = null
var locked_value: bool = false
var selected_value: bool = false

@onready var option_label: RichTextLabel = %OptionLabel
@onready var select_button: Button = %OptionButton
@onready var initial_color: Color = Color(1, 0.9, 0)
@onready var hover_color: Color = Color(0.2, 1.0, 0.2)

func _ready():
	select_button.mouse_entered.connect(func(): option_label.add_theme_color_override("default_color", hover_color))
	select_button.mouse_exited.connect(func(): option_label.add_theme_color_override("default_color", initial_color))
	option_label.text = "%d. %s"%[option_value+1, option_text]
	if selected_value:
		option_label.add_theme_color_override("default_color", Color.DIM_GRAY)
	select_button.disabled = locked_value
	select_button.pressed.connect(func():
		selected.emit(option_value)
	)

func set_value(value):
	option_value = value

func set_text(text):
	option_text = text

func set_locked(locked):
	locked_value = locked

func set_selected(was_selected):
	selected_value = was_selected
