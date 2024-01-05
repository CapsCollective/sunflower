class_name CharacterActionNavigateTo extends CharacterAction

var target_pos: Vector3

func _init(owning_character: Character, pos: Vector3):
	super._init(owning_character)
	target_pos = pos

func start():
	super.start()
	character.navigation_agent.navigation_finished.connect(complete)
	character.navigation_agent.set_target_position(target_pos)

func abort():
	super.abort()
	character.navigation_agent.set_target_position(character.global_position)
