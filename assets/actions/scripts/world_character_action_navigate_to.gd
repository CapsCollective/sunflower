class_name WorldCharacterActionNavigateTo extends WorldCharacterAction

func run_action(character: Character):
	character.run_action(CharacterActionNavigateTo.new(character, global_position))
