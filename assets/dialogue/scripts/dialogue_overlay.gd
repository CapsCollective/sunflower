extends Control

class ExampleContext:
	pass

var active_dialogue_script: DialogueScript
var context = ExampleContext.new()

@onready var dialogue_display = $DialogueDisplay

func _ready():
	GameManager.dialogue_initiated.connect(on_dialogue_initiated)

func on_dialogue_initiated(script: String):
	active_dialogue_script = DialogueScript.new(script)
	active_dialogue_script.context_object = context
	
	active_dialogue_script.started.connect(func():
		mouse_filter = MOUSE_FILTER_STOP
	)
	
	active_dialogue_script.ended.connect(func():
		mouse_filter = MOUSE_FILTER_IGNORE
	)
	
	dialogue_display.set_dialogue_script(active_dialogue_script)
	active_dialogue_script.start()
