class_name CharacterActionPlantCrop extends CharacterActionNavigateCallback

var plant_seed: String

func _init(owning_character: Character, cell: Vector2i, seed_id: String):
	super._init(owning_character, cell)
	plant_seed = seed_id

func on_start():
	super.on_start()
	GameManager.deselect_item()

func on_nav_complete():
	GameManager.change_energy(-10)
	GameManager.plant_crop(plant_seed, target_cell)
	if character is PlayerCharacter:
		GameManager.change_item_count(plant_seed, -1)
