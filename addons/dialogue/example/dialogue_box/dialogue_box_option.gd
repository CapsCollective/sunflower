extends Control

signal selected(value: Variant)

var option_text: String
var option_value: Variant = null

@onready var select_button: Button = %SelectButton
@onready var text_label: RichTextLabel = %OptionLabel

func _ready():
	text_label.text = option_text
	select_button.pressed.connect(func():
		selected.emit(option_value)
	)

func set_value(value):
	option_value = value

func set_text(text):
	option_text = text
