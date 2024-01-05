class_name CharacterActionWaterSoil extends CharacterAction

var water_cell: Vector2i
var nav_to_action: CharacterAction

func _init(owning_character: Character, cell: Vector2i):
	super._init(owning_character)
	water_cell = cell

func start():
	super.start()
	GameManager.deselect_item()
	var pos = GameManager.current_zone.grid.get_position_by_cell(water_cell)
	nav_to_action = CharacterActionNavigateTo.new(character, pos)
	nav_to_action.completed.connect(water_soil)
	nav_to_action.aborted.connect(abort)
	nav_to_action.start()

func abort():
	super.abort()
	if nav_to_action and nav_to_action.active:
		nav_to_action.abort()
		nav_to_action = null

func water_soil():
	print("WATERED!")
