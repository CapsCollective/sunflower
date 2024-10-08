class_name CharacterActionHarvestCrop extends CharacterAction

var crop_to_harvest: Crop
var nav_to_action: CharacterAction

func _init(owning_character: Character, crop: Crop):
	super._init(owning_character)
	crop_to_harvest = crop

func on_start():
	GameManager.deselect_item()
	var pos = GameManager.current_zone.grid.get_position_by_cell(crop_to_harvest.grid_cell)
	nav_to_action = CharacterActionNavigateTo.new(character, pos)
	nav_to_action.completed.connect(harvest_crop)
	nav_to_action.aborted.connect(abort)
	nav_to_action.start()

func on_abort():
	if nav_to_action and nav_to_action.active:
		nav_to_action.abort()

func harvest_crop():
	var crops = GameManager.get_crops_in_current_zone()
	var cell = crop_to_harvest.grid_cell
	var crop_details = GameManager.crops_dt.get_row(crops[cell].seed_id)
	if not GameManager.is_crop_dead(GameManager.current_zone.id, cell):
		GameManager.change_item_count(crop_details.crop_id, 1)
	crops.erase(cell)
	crop_to_harvest.queue_free()
	GameManager.change_energy(-10)
