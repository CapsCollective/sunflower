class_name ZoneTraversalTrigger extends Area3D

const levels_dt = preload("res://assets/datatables/tables/levels_dt.tres")

@export var traversal_zone_id: StringName
@export var spawn_location: StringName

@export var exits_to_zones: Array[StringName]

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node3D):
	if body is not PlayerCharacter:
		return
	
	body.input_enabled = false
	body_entered.disconnect(on_body_entered)
	for child in get_children():
		if child is WorldCharacterAction:
			child.run_action(body)
	
	var row: LevelRow = levels_dt.get_row(traversal_zone_id)
	GameManager.game_world.load_level(row.path, {"spawn_location": spawn_location})
