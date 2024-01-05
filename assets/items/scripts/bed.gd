class_name Bed extends StaticBody3D

var mouse_over: bool = false

func _process(_delta):
	$Outline.visible = mouse_over

func _input(event):
	if event.is_action("lmb_down") and event.is_action_pressed("lmb_down"):
		if mouse_over:
			var player = GameManager.current_zone.player_character
			var action = CharacterActionNavigateTo.new(player, global_position)
			action.completed.connect(func(): GameManager.increment_day())
			player.run_action(action)
			get_viewport().set_input_as_handled()

func _mouse_enter():
	mouse_over = true

func _mouse_exit():
	mouse_over = false
