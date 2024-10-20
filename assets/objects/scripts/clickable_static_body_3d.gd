class_name ClickableStaticBody3D extends StaticBody3D

@onready var outline: MeshInstance3D = %Outline

var mouse_over: bool = false

func _process(_delta):
	$Outline.visible = mouse_over

func _input(event):
	if event.is_action("lmb_down") and event.is_action_pressed("lmb_down"):
		if mouse_over:
			var player = GameManager.current_zone.player_character
			var action = CharacterActionNavigateTo.new(player, global_position)
			action.completed.connect(on_click)
			player.run_action(action)
			get_viewport().set_input_as_handled()

func _mouse_enter():
	mouse_over = true

func _mouse_exit():
	mouse_over = false
	
func on_click():
	Utils.log_warn("No callback written for ", name)
