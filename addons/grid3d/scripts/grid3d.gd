class_name Grid3D extends Node3D

@export var size: int = 1
@export var width: int = 1
@export var height: int = 1

@export var disabled_cells: Array[Vector2i] = []

func is_cell_disabled(cell: Vector2i) -> bool:
	return disabled_cells.has(cell)

func get_quantised_position(pos: Vector3) -> Vector3:
	return pos
