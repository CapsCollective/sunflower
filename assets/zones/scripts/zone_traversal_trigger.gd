class_name ZoneTraversalTrigger extends Area3D

@export_file("*.scn", "*.tscn") var traversal_zone: String
@export var spawn_location: StringName

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
	GameManager.game_world.load_level(traversal_zone, {"spawn_location": spawn_location})
