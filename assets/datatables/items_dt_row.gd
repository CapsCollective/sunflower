class_name ItemRow extends DatatableRow

enum ActionType {
	NONE,
	PLANT,
	WATER,
}

@export var name: String
@export_file("*.svg") var icon_path: String
@export var action_type: ActionType
