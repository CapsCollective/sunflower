class_name ItemConfig extends DatatableRow

enum ActionType {
	NONE,
	PLANT,
	WATER,
	SCAN,
}

@export var name: String
@export_file("*.svg") var icon_path: String
@export var action_type: ActionType
