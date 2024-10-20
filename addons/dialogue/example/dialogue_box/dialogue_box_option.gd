extends Control

signal selected(value: Variant)

var option_text: String
var option_value: Variant = null
var locked_value: bool = false
var selected_value: bool = false

@onready var select_button: Button = %SelectButton
@onready var text_label: RichTextLabel = %OptionLabel

func _ready():
	text_label.text = option_text
	if selected_value:
		text_label.add_theme_color_override("default_color", Color.DIM_GRAY)
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

func set_selected(selected):
	selected_value = selected
