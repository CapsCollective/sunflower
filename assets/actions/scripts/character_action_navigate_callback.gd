class_name CharacterActionNavigateCallback extends CharacterAction

var target_cell: Vector2i
var nav_to_action: CharacterAction

func _init(owning_character: Character, cell: Vector2i):
	super._init(owning_character)
	target_cell = cell

func on_start():
	var pos = GameManager.current_zone.grid.get_position_by_cell(target_cell)
	nav_to_action = CharacterActionNavigateTo.new(character, pos)
	nav_to_action.completed.connect(on_nav_complete)
	nav_to_action.aborted.connect(abort)
	nav_to_action.start()

func on_abort():
	if nav_to_action and nav_to_action.active:
		nav_to_action.abort()

func on_nav_complete():
	Utils.log_warn("No callback on completed navigation")
