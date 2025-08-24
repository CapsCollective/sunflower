class_name CharacterActionPlantCrop extends CharacterActionNavigateCallback

@export var seed_id: String

func configure(owning_character: Character, params: Dictionary):
	super.configure(owning_character, params)
	target_cell = params.get("target_cell")
	seed_id = params.get("seed_id")

func on_start():
	super.on_start()
	GameManager.deselect_item()

func on_nav_complete():
	if GameManager.get_stat("energy") <= 0:
		return
	GameManager.change_energy(Consts.ACTION_PLANT_ENERGY)
	GameManager.change_stat("radiation", Consts.ACTION_PLANT_RADIATION)
	GameManager.plant_crop(seed_id, target_cell)
	if character is PlayerCharacter:
		GameManager.change_item_count(seed_id, -1)
	GameManager.increment_time()
