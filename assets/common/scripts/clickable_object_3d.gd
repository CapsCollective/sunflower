class_name ClickableObject3D extends CollisionObject3D

@onready var outline: MeshInstance3D = %Outline

signal clicked

var mouse_over: bool = false

func _process(_delta):
	outline.visible = mouse_over

func _input(event):
	if event.is_action("lmb_down") and event.is_action_pressed("lmb_down"):
		if mouse_over and GameManager.get_player().input_enabled:
			var player = GameManager.get_player()
			var action = CharacterActionNavigateTo.new()
			var target_pos = Utils.get_perspective_collision_ray_point(self)
			action.configure(player, {"target_pos": target_pos})
			action.completed.connect(_on_click)
			player.run_action(action)
			get_viewport().set_input_as_handled()

func _mouse_enter():
	mouse_over = true

func _mouse_exit():
	mouse_over = false
	
func _on_click():
	clicked.emit()
	on_click()
	
func on_click():
	pass
