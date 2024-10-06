class_name CropConfigRow extends DatatableRow

@export var crop_id: String
@export var name: String
@export var planting_radius: int
@export var effect_radius: int
@export var growth_required: int
@export var attributes: Array[CropAttribute]
@export_file("*.res", "*.tres") var mesh_planted: String
@export_file("*.res", "*.tres") var mesh_growing: String
@export_file("*.res", "*.tres") var mesh_grown: String
@export_file("*.res", "*.tres") var mesh_decayed: String
