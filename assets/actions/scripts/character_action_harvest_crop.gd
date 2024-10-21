class_name CharacterActionHarvestCrop extends CharacterActionNavigateCallback

var crop_to_harvest: Crop
func _init(owning_character: Character, crop: Crop):
	super._init(owning_character, crop.grid_cell)
	crop_to_harvest = crop

func on_nav_complete():
	var crops = GameManager.get_crops_in_current_zone()
	var cell = crop_to_harvest.grid_cell
	var seed_id = crops[cell].seed_id
	var crop_details = GameManager.crops_dt.get_row(seed_id)
	if not GameManager.is_crop_dead(GameManager.current_zone.id, cell) or seed_id == "weed":
		if GameManager.items_dt.has(seed_id):
			GameManager.change_item_count(seed_id, RandomNumberGenerator.new().randi_range(1,2))
		if GameManager.items_dt.has(crop_details.crop_id):
			GameManager.change_item_count(crop_details.crop_id, 1)
	elif GameManager.items_dt.has(seed_id) and GameManager.get_item_count(seed_id) <= 2:
		GameManager.change_item_count(seed_id, 1)
	crops.erase(cell)
	crop_to_harvest.queue_free()
	GameManager.change_energy(-5)
