class_name CharacterActionNavigateTo extends CharacterAction

@export var target_pos: Vector3:
	set(pos):
		target_pos = pos
		if active:
			character.navigation_agent.set_target_position(target_pos)

func configure(owning_character: Character, params: Dictionary):
	super.configure(owning_character, params)
	target_pos = params.get("target_pos")

func on_start():
	if not character.navigation_agent.navigation_finished.is_connected(complete):
		character.navigation_agent.navigation_finished.connect(complete)
	character.navigation_agent.set_target_position(target_pos)

func on_abort():
	character.navigation_agent.set_target_position(character.global_position)
