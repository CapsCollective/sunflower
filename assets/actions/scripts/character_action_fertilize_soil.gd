class_name CharacterActionFertilizeSoil extends CharacterActionNavigateCallback

func on_nav_complete():
	GameManager.change_energy(-5)
	GameManager.change_item_count("fertilizer", -1)
	GameManager.update_grid_attribute_for_current_zone(target_cell, GameManager.SoilAttr.NITROGEN, 0.3, 5)
	if GameManager.get_item_count("fertilizer") <= 0:
		GameManager.deselect_item()
	GameManager.increment_time()
