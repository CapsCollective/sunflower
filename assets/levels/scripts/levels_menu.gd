extends Control

func _ready():
	var levels_dt = load("res://assets/content/levels_dt.tres")
	for entry in levels_dt:
		var new_button = Button.new()
		new_button.text = entry.value.name
		new_button.button_up.connect(func():
			GameManager.game_world.load_level(entry.value.path)
		)
		$VBoxContainer.add_child(new_button)
