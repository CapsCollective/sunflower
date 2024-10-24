class_name CharacterActionWaterSoil extends CharacterAction

const WATER_INTERVAL = 0.3

var timer: Timer
var mouse_down: bool
var nav_to_action: CharacterActionNavigateTo
var water_cell: Vector2i:
	set(cell):
		water_cell = cell
		if active and nav_to_action:
			var character_cell = GameManager.current_zone.grid.get_cell_by_position(character.global_position)
			if Vector2(water_cell).distance_to(character_cell) > 3:
				nav_to_action.target_pos = GameManager.current_zone.grid.get_position_by_cell(water_cell)
				if not nav_to_action.active:
					nav_to_action.start()

func _init(owning_character: Character, cell: Vector2i):
	super._init(owning_character)
	water_cell = cell

func on_start():
	var pos = GameManager.current_zone.grid.get_position_by_cell(water_cell)
	nav_to_action = CharacterActionNavigateTo.new(character, pos)
	nav_to_action.aborted.connect(abort)
	nav_to_action.start()
	timer = Timer.new()
	character.add_child(timer)
	timer.timeout.connect(water_soil)
	timer.start(WATER_INTERVAL)

func on_abort():
	timer.stop()
	timer.queue_free()
	if nav_to_action and nav_to_action.active:
		nav_to_action.abort()
		nav_to_action = null

func on_complete():
	timer.stop()
	timer.queue_free()

func water_soil():
	var character_cell = GameManager.current_zone.grid.get_cell_by_position(character.global_position)
	if Vector2(water_cell).distance_to(character_cell) <= 3:
		if GameManager.change_water(-5):
			GameManager.change_energy(-2)
			GameManager.update_grid_attribute_for_current_zone(water_cell, GameManager.SoilAttr.HYDRATION, 0.1, 5)
			GameManager.update_grid_attribute_for_current_zone(water_cell, GameManager.SoilAttr.RADIATION, 0.002, 5)
