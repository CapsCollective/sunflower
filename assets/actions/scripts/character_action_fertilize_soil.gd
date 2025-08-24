class_name CharacterActionFertilizeSoil extends CharacterActionNavigateCallback

func configure(owning_character: Character, params: Dictionary):
	super.configure(owning_character, params)
	target_cell = params.get("target_cell")

func on_nav_complete():
	if GameManager.get_stat("energy") <= 0:
		return
	GameManager.change_energy(Consts.ACTION_FERTILIZE_ENERGY)
	GameManager.change_stat("radiation", Consts.ACTION_FERTILIZE_RADIATION)
	GameManager.change_item_count("fertilizer", -1)
	GameManager.update_grid_attribute(
		target_cell, 
		GameManager.SoilAttr.NITROGEN, 
		Consts.ACTION_FERTILIZE_NITROGEN_CHANGE
	)
	if GameManager.get_item_count("fertilizer") <= 0:
		GameManager.deselect_item()
	GameManager.increment_time()
