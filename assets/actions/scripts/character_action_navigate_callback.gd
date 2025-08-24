class_name CharacterActionNavigateCallback extends CharacterAction

@export var target_cell: Vector2i

var nav_to_action: CharacterAction

func configure(owning_character: Character, params: Dictionary):
	super.configure(owning_character, params)
	target_cell = params.get("target_cell")

func on_start():
	var pos = GameManager.current_zone.grid.get_position_by_cell(target_cell)
	nav_to_action = CharacterActionNavigateTo.new()
	nav_to_action.configure(character, {"target_pos": pos})
	nav_to_action.completed.connect(on_nav_complete)
	nav_to_action.aborted.connect(abort)
	nav_to_action.start()

func on_abort():
	if nav_to_action and nav_to_action.active:
		nav_to_action.abort()

func on_nav_complete():
	Utils.log_warn("No callback on completed navigation")
