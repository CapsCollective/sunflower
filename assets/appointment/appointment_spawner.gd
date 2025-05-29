class_name AppointmentSpawner extends Node3D

@export var spawner_id: StringName
@export var spawn_offset: Vector3 = Vector3(0, 1, 0)
@export var action: WorldCharacterAction
@export_file("*.json") var dialogue_script: String

func run_spawn(character_id: StringName, spawn_options: Dictionary):
	var character = GameManager.current_zone.find_character(character_id)
	if not character:
		character = GameManager.current_zone.spawn_character(character_id)
		var spawn_pos: Vector3 = spawn_options.get("override_spawn_pos", global_position)
		character.global_position = spawn_pos + spawn_offset
	if character is NPCCharacter:
		character.dialogue_script = dialogue_script
	if action:
		action.run_action(character)
