class_name Zone extends Node3D

var game_cam: GameCamera

func _shortcut_input(event):
	if event.is_action_pressed("next_turn"):
		GameManager.next_turn()
		get_viewport().set_input_as_handled()

func _ready():
	game_cam = Utils.get_first_node_with_script(self, GameCamera)
	GameManager.register_zone(self)

func _exit_tree():
	GameManager.deregister_zone(self)
