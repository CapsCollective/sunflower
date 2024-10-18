class_name ItemConfigRow extends DatatableRow

enum ActionType {
	NONE,
	PLANT,
	WATER,
	SCAN,
	EAT,
	FERTILIZE
}

@export var name: String
@export_file("*.svg") var icon_path: String
@export var action_type: ActionType
