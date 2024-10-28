class_name CharacterActionPlantCrop extends CharacterActionNavigateCallback

var plant_seed: String

func _init(owning_character: Character, cell: Vector2i, seed_id: String):
	super._init(owning_character, cell)
	plant_seed = seed_id

func on_start():
	super.on_start()
	GameManager.deselect_item()

func on_nav_complete():
	if GameManager.get_stat("energy") <= 0:
		return
	GameManager.change_energy(Consts.ACTION_PLANT_ENERGY)
	GameManager.change_stat("radiation", Consts.ACTION_PLANT_RADIATION)
	GameManager.plant_crop(plant_seed, target_cell)
	if character is PlayerCharacter:
		GameManager.change_item_count(plant_seed, -1)
	GameManager.increment_time()
