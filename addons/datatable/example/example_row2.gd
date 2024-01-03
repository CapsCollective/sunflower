class_name ExampleRow2 extends DatatableRow

enum DamageType { FIRE, WATER, NECROTIC }

@export var is_enabled: bool
@export var effect_offset: Vector4
@export var effect_colour: Color
@export var damage_type: DamageType
@export_flags("Earth:1", "Ice:2", "Poison:4") var weaknesses: int
@export_file("*.gd") var script_path: String
