class_name GameCamera extends Camera3D

@export var default_move_duration: float = 0.5
@export var subject_offset: Vector3 = Vector3(0, 0, 5)
@export var lower_bounds: Vector3 = Vector3(0, 0, 0)
@export var upper_bounds: Vector3 = Vector3(0, 0, 0)

@onready var reset_pos: Vector3 = position

var subject: Node3D = null
var moving: bool = false

func _physics_process(_delta):
	if subject:
		var target_pos = subject.global_position
		position.x = clampf(target_pos.x, lower_bounds.x, upper_bounds.x)
		position.z = clampf(target_pos.z, lower_bounds.z, upper_bounds.z) + subject_offset.z

func reset_position(animate: bool = true, duration: float = default_move_duration):
	move_to_position(reset_pos, animate, duration)

func move_to_position(new_pos: Vector3, animate: bool = true, duration: float = default_move_duration):
	if animate:
		create_tween().tween_property(self, "position", new_pos, duration)
	else:
		position = new_pos
