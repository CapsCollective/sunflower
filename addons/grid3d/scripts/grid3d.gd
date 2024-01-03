class_name Grid3D extends Node3D

@export var size: int = 1
@export var width: int = 1
@export var height: int = 1

@export var disabled_cells: Array[Vector2i] = []

func is_cell_on_grid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height

func is_cell_disabled(cell: Vector2i) -> bool:
	return disabled_cells.has(cell)

func is_cell_at_position_valid(pos: Vector3) -> bool:
	var cell = get_cell_by_position(pos)
	return (not is_cell_disabled(cell)) and is_cell_on_grid(cell)

func get_quantised_position(pos: Vector3) -> Vector3:
	return snapped(pos, Vector3(size, 0, size))

func get_cell_by_position(pos: Vector3) -> Vector2i:
	var quantised = get_quantised_position(pos)
	return Vector2i(quantised.x, quantised.z)
