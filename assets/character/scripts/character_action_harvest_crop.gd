class_name CharacterActionHarvestCrop extends CharacterAction

var crop_to_harvest: Crop
var nav_to_action: CharacterAction

func _init(owning_character: Character, crop: Crop):
	super._init(owning_character)
	crop_to_harvest = crop

func start():
	super.start()
	GameManager.deselect_item()
	var pos = GameManager.current_zone.grid.get_position_by_cell(crop_to_harvest.grid_cell)
	nav_to_action = CharacterActionNavigateTo.new(character, pos)
	nav_to_action.completed.connect(harvest_crop)
	nav_to_action.aborted.connect(abort)
	nav_to_action.start()

func abort():
	super.abort()
	if nav_to_action and nav_to_action.active:
		nav_to_action.abort()

func harvest_crop():
	var crop_zone = GameManager.get_crops_in_current_zone()
	var crop_details = GameManager.crops_dt.get_row(crop_zone[crop_to_harvest.grid_cell].seed_id)
	crop_zone.erase(crop_to_harvest.grid_cell)
	GameManager.change_item_count(crop_details.crop_id, 1)
	crop_to_harvest.queue_free()
