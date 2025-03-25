class_name WorldCharacterActionNavigateTo extends WorldCharacterAction

func run_action(character: Character):
	var action: CharacterActionNavigateTo = CharacterActionNavigateTo.new()
	action.configure(character, {"target_pos": global_position})
	character.run_action(action)
