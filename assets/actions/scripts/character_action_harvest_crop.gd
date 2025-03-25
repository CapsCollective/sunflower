class_name CharacterActionHarvestCrop extends CharacterActionNavigateCallback

var crop_to_harvest: Crop

func configure(owning_character: Character, params: Dictionary):
	super.configure(owning_character, params)
	crop_to_harvest = params.get("crop")

func on_nav_complete():
	if GameManager.get_stat("energy") <= 0:
		return
	var crops = GameManager.get_crops_in_current_zone()
	var cell = crop_to_harvest.grid_cell
	var seed_id = crops[cell].seed_id
	var crop_details = GameManager.crops_dt.get_row(seed_id)
	if not GameManager.is_crop_dead(GameManager.current_zone.zone_id, cell):
		if GameManager.items_dt.has(seed_id):
			GameManager.change_item_count(seed_id, RandomNumberGenerator.new().randi_range(1,3))
		if GameManager.items_dt.has(crop_details.crop_id):
			GameManager.change_item_count(crop_details.crop_id, 1)
	else:
		GameManager.change_item_count("organic_waste", 1)
		if GameManager.items_dt.has(seed_id) and GameManager.get_item_count(seed_id) <= 2:
			GameManager.change_item_count(seed_id, 1)
	crops.erase(cell)
	crop_to_harvest.queue_free()
	GameManager.change_energy(Consts.ACTION_HARVEST_ENERGY)
	GameManager.increment_time()
