class_name ZoneTraversalTrigger extends Area3D

@export_file("*.scn", "*.tscn") var traversal_zone: String
@export var spawn_location: StringName

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node3D):
	if body is PlayerCharacter:
		GameManager.game_world.load_level(traversal_zone, {"spawn_location": spawn_location})
