class_name CompostBin extends ClickableStaticBody3D

var compostible_items = ["sunflower", "organic_waste"]

func on_click():
	if compostible_items.has(GameManager.selected_item):
		GameManager.change_item_count("fertilizer", 1)
		GameManager.change_item_count(GameManager.selected_item, -1)
		if GameManager.get_item_count(GameManager.selected_item) == 0:
			GameManager.deselect_item()
