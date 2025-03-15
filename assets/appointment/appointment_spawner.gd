class_name AppointmentSpawner extends Node3D

@export var spawner_id: StringName
@export var spawn_offset: Vector3 = Vector3(0, 1, 0)
@export var action: WorldCharacterAction

func run_spawn(character_id: StringName):
	var character = GameManager.current_zone.find_character(character_id)
	if not character:
		character = GameManager.current_zone.spawn_character(character_id)
		character.global_position = global_position + spawn_offset
	action.run_action(character)
