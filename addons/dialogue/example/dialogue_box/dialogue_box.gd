extends Control

enum DialogueBoxDisplayMode {
	HIDDEN,
	LINE,
	OPTIONS,
	OPTION_LINES
}

const DialogueOption = preload("res://addons/dialogue/example/dialogue_box/dialogue_box_option.tscn")

var dialogue_script: DialogueScript

var selected_options: Array[String]

@onready var dialogue_box_line_text_container: Control = %LineTextContainer
@onready var dialogue_box_speaker_label: Control = %SpeakerLabel
@onready var dialogue_box_line_label: RichTextLabel = %DialogueLineLabel
@onready var dialogue_box_line_continue_button: Button = %ContinueButton
@onready var dialogue_box_options: Control = %OptionsContainer

func _ready():
	set_display_mode(DialogueBoxDisplayMode.HIDDEN)

func set_dialogue_script(script):
	dialogue_script = script
	dialogue_script.ended.connect(func():
		set_display_mode(DialogueBoxDisplayMode.HIDDEN)
	)
	dialogue_script.line_executed.connect(func(line):
		dialogue_box_line_continue_button.pressed.connect(on_continue_button_pressed)
		dialogue_box_line_label.text = line.processed_text
		dialogue_box_speaker_label.text = "%s: "%[line.speaker_id]
		set_display_mode(DialogueBoxDisplayMode.LINE)
	)
	dialogue_script.options_executed.connect(func(options, line):
		if line:
			dialogue_box_line_label.text = line.processed_text
			dialogue_box_speaker_label.text = "%s: "%[line.speaker_id]
		for key in options.keys():
			var option = options[key]
			var dialogue_option = DialogueOption.instantiate()
			var option_id = option.get("option_id", null)
			if option_id:
				if selected_options.has(option_id):
					dialogue_option.set_selected(true)
				selected_options.append(option_id)
			dialogue_option.set_text(option.processed_text)
			dialogue_option.set_value(key)
			dialogue_option.set_locked(option.get("locked", false))
			dialogue_option.selected.connect(on_dialogue_option_selected)
			dialogue_box_options.add_child(dialogue_option)
		var mode = DialogueBoxDisplayMode.OPTION_LINES if line else DialogueBoxDisplayMode.OPTIONS
		set_display_mode(mode)
	)
	dialogue_script.advanced_with_option.connect(func(option_id):
		for option in dialogue_box_options.get_children():
			option.queue_free()
	)

func on_dialogue_option_selected(idx: int):
	dialogue_script.advance_with_option(idx)

func on_continue_button_pressed():
	dialogue_box_line_continue_button.pressed.disconnect(on_continue_button_pressed)
	dialogue_script.advance()

func set_display_mode(mode: DialogueBoxDisplayMode):
	visible = mode != DialogueBoxDisplayMode.HIDDEN
	dialogue_box_line_text_container.visible = mode == DialogueBoxDisplayMode.LINE or mode == DialogueBoxDisplayMode.OPTION_LINES
	dialogue_box_line_continue_button.visible = mode == DialogueBoxDisplayMode.LINE
	dialogue_box_options.visible = mode == DialogueBoxDisplayMode.OPTIONS or mode == DialogueBoxDisplayMode.OPTION_LINES
