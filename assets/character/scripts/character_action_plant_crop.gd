class_name CharacterActionPlantCrop extends CharacterAction

const crop_scn = preload("res://assets/crops/scenes/crop.tscn")

var plant_cell: Vector2i
var nav_to_action: CharacterAction

func _init(owning_character: Character, cell: Vector2i):
	super._init(owning_character)
	plant_cell = cell

func start():
	super.start()
	var pos = GameManager.current_zone.grid.get_position_by_cell(plant_cell)
	nav_to_action = CharacterActionNavigateTo.new(character, pos)
	nav_to_action.completed.connect(plant_crop)
	nav_to_action.aborted.connect(abort)
	nav_to_action.start()

func abort():
	super.abort()
	if nav_to_action and nav_to_action.active:
		nav_to_action.abort()

func plant_crop():
	var crop = crop_scn.instantiate()
	character.add_sibling(crop)
	crop.global_position = GameManager.current_zone.grid.get_position_by_cell(plant_cell)
	crop.crop_name = "sunflower"
	crop.grid_position = plant_cell
	crop.serialise()
