class_name CropConfigRow extends DatatableRow

@export var crop_id: String
@export var name: String
@export var planting_radius: int
@export var effect_radius: int
@export var growth_required: int
@export var hydration: CropAttribute
@export var nitrogen: CropAttribute
@export var radiation: CropAttribute
@export var attributes: Array[CropAttribute]
@export_file("*.res", "*.tres") var mesh_grown: String
