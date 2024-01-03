class_name GameCamera extends Camera3D

@export var default_move_duration: float = 0.5

@onready var reset_pos: Vector3 = position

func reset_position(animate: bool = true, duration: float = default_move_duration):
	move_to_position(reset_pos, animate, duration)

func move_to_position(new_pos: Vector3, animate: bool = true, duration: float = default_move_duration):
	if animate:
		create_tween().tween_property(self, "position", new_pos, duration)
	else:
		position = new_pos
