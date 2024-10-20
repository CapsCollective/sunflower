extends Control

class ExampleContext:
	var player = ExamplePlayer.new()
	var state = ExampleState.new()

class ExamplePlayer:
	var name = "Jerry"
	var hp = 2

class ExampleState:
	var line = false
	var looped = false

var dialogue_script: DialogueScript
var context = ExampleContext.new()

@onready var dialogue_box = %DialogueBox

func _ready():
	dialogue_script = DialogueScript.new("res://addons/dialogue/example/example_dialogue.json")
	DialogueValidator.validate_script(dialogue_script)
	dialogue_script.context_object = context
	
	dialogue_script.ended.connect(func():
		await get_tree().create_timer(1).timeout
		dialogue_script.start()
	)
	
	dialogue_box.set_dialogue_script(dialogue_script)
	dialogue_script.start()
