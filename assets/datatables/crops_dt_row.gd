class_name CropConfigRow extends DatatableRow

@export var crop_id: String
@export var name: String
@export var planting_radius: int
@export var effect_radius: int
@export var growth_required: int
@export var hydration_change: float
@export var hydration_curve: Curve
@export_file("*.res", "*.tres") var mesh: String
