class_name ExampleRow1 extends DatatableRow

@export_range(0, 10) var priority: int
@export_range(0, 10, 0.01) var move_speed: float
@export var display_name: String
@export var combat_script: GDScript
@export_enum("class_name", "CSGShape3D") var debug_shape: String
