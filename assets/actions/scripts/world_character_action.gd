class_name WorldCharacterAction extends Node3D

@export var character_action: CharacterAction

func run_action(character: Character):
	if not character_action:
		Log.warn("CharacterActions", "World action, ", name, ", has undefined action")
		return
	
	if "target_pos" in character_action:
		character_action.target_pos = global_position
	character_action.character = character
	character.run_action(character_action)
