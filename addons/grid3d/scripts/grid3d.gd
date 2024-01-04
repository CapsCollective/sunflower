@tool
class_name Grid3D extends Node3D

@export var size: int = 1
@export var width: int = 1
@export var height: int = 1

@export var disabled_cells: Array[Vector2i] = []

func get_lower_cell_bounds() -> Vector2i:
	return Vector2i(-width/2, -height/2)

func get_upper_cell_bounds() -> Vector2i:
	return get_lower_cell_bounds() + Vector2i(width, height)

func is_cell_on_grid(cell: Vector2i) -> bool:
	var lower: Vector2i = get_lower_cell_bounds()
	var upper: Vector2i = get_upper_cell_bounds()
	return cell.x >= lower.x and cell.x < upper.x \
		and cell.y >= lower.y and cell.y < upper.y

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

func get_position_by_cell(cell_coords: Vector2i) -> Vector3:
	return Vector3(cell_coords.x, global_position.y, cell_coords.y)
