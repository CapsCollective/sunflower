class_name CharacterActionHarvestCrop extends CharacterAction

var crop_to_harvest: Crop
var nav_to_action: CharacterAction

func _init(owning_character: Character, crop: Crop):
	super._init(owning_character)
	crop_to_harvest = crop

func start():
	super.start()
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
	var crop_entry = Savegame.player.crops[GameManager.current_zone.id][crop_to_harvest.grid_cell]
	GameManager.change_item_count(crop_entry.type, 1)
	crop_to_harvest.queue_free()
