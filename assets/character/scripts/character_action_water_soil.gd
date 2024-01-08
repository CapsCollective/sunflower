class_name CharacterActionWaterSoil extends CharacterAction

const WATER_INTERVAL = 0.3

var timer: Timer
var mouse_down: bool
var nav_to_action: CharacterAction
var water_cell: Vector2i:
	set(cell):
		water_cell = cell
		if active and nav_to_action:
			var character_cell = GameManager.current_zone.grid.get_cell_by_position(character.global_position)
			if Vector2(water_cell).distance_to(character_cell) >= 3:
				nav_to_action.target_pos = GameManager.current_zone.grid.get_position_by_cell(water_cell)
				if not nav_to_action.active:
					nav_to_action.start()

func _init(owning_character: Character, cell: Vector2i):
	super._init(owning_character)
	water_cell = cell
	print(cell)
	timer = Timer.new()
	timer.timeout.connect(water_soil)

func start():
	super.start()
	var pos = GameManager.current_zone.grid.get_position_by_cell(water_cell)
	print(water_cell)
	nav_to_action = CharacterActionNavigateTo.new(character, pos)
	nav_to_action.aborted.connect(abort)
	nav_to_action.start()
	character.add_child(timer)
	timer.start(WATER_INTERVAL)

func abort():
	super.abort()
	timer.stop()
	timer.queue_free()
	if nav_to_action and nav_to_action.active:
		nav_to_action.abort()
		nav_to_action = null

func water_soil():
	var character_cell = GameManager.current_zone.grid.get_cell_by_position(character.global_position)
	if Vector2(water_cell).distance_to(character_cell) <= 3:
		GameManager.update_grid_property(water_cell, 'hydration', 5, 0.1)
