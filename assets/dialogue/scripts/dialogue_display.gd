extends Control

enum DialogueDisplayMode {
	HIDDEN,
	LINE,
	OPTIONS,
	OPTION_LINES
}

const DialogueOption = preload("res://assets/dialogue/scenes/dialogue_display_option.tscn")

var dialogue_script: DialogueScript

var selected_options: Array[String]

@onready var dialogue_container: Control = %DialogueContainer
@onready var dialogue_line_label: RichTextLabel = %DialogueLineLabel
@onready var dialogue_line_continue_button: Control = %ContinueButton
@onready var dialogue_options: Control = %OptionsContainer

@onready var intial_pos: Vector2 = dialogue_container.position

func _ready():
	set_display_mode(DialogueDisplayMode.HIDDEN)

func _process(_delta: float):
	var camera = get_viewport().get_camera_3d()
	var speaker = get_current_speaker()
	if speaker:
		dialogue_container.position = camera.unproject_position(speaker.global_position)
	else:
		dialogue_container.position = intial_pos
	dialogue_container.position.y -= dialogue_line_label.size.y
	dialogue_container.position.y -= dialogue_options.size.y

func get_current_speaker():
	var characters = GameManager.current_zone.get_all_characters()
	for character: Character in characters:
		if character.character_id == current_speaker:
			return character
	return null

var current_speaker: StringName

func set_dialogue_script(script):
	dialogue_script = script
	dialogue_script.ended.connect(func():
		set_display_mode(DialogueDisplayMode.HIDDEN)
	)
	dialogue_script.line_executed.connect(func(line):
		current_speaker = line.speaker_id
		dialogue_line_continue_button.pressed.connect(on_continue_button_pressed)
		dialogue_line_label.text = "%s: %s"%[line.speaker_id, line.processed_text]
		set_display_mode(DialogueDisplayMode.LINE)
	)
	dialogue_script.options_executed.connect(func(options, line):
		if line:
			current_speaker = line.speaker_id
			dialogue_line_label.text = "%s: %s"%[line.speaker_id, line.processed_text]
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
			dialogue_options.add_child(dialogue_option)
		var mode = DialogueDisplayMode.OPTION_LINES if line else DialogueDisplayMode.OPTIONS
		set_display_mode(mode)
	)
	dialogue_script.advanced_with_option.connect(func(_option_id):
		for option in dialogue_options.get_children():
			option.queue_free()
	)

func on_dialogue_option_selected(idx: int):
	dialogue_script.advance_with_option(idx)

func on_continue_button_pressed():
	dialogue_line_continue_button.pressed.disconnect(on_continue_button_pressed)
	dialogue_script.advance()

func set_display_mode(mode: DialogueDisplayMode):
	visible = mode != DialogueDisplayMode.HIDDEN
	dialogue_line_label.visible = mode == DialogueDisplayMode.LINE or mode == DialogueDisplayMode.OPTION_LINES
	dialogue_line_continue_button.visible = mode == DialogueDisplayMode.LINE
	dialogue_options.visible = mode == DialogueDisplayMode.OPTIONS or mode == DialogueDisplayMode.OPTION_LINES
