class_name CharacterConfigRow extends DatatableRow

@export var display_name: String
@export_file("*.json") var dialogue_script: String
@export var appointments: Dictionary[int, AppointmentConfig]
