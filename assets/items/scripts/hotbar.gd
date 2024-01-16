extends Node

const HOTBAR_ITEMS = 5

const hotbar_item_scn = preload("res://assets/items/scenes/hotbar_item.tscn")
@onready var button_group: ButtonGroup = ButtonGroup.new()

func _ready():
	button_group.allow_unpress = true
	button_group.pressed.connect(toggle_hotbar_item)
	GameManager.hotbar_updated.connect(refresh)
	refresh()

func refresh():
	Utils.queue_free_children(self)
	for slot in range(HOTBAR_ITEMS):
		var instance: HotbarItem = hotbar_item_scn.instantiate()
		add_child(instance)
		instance.button_group = button_group
		if (len(Savegame.player.hotbar) > slot):
			instance.item_id = Savegame.player.hotbar[slot]

func toggle_hotbar_item(button: HotbarItem):
	if button.item_id == GameManager.selected_item:
		GameManager.deselect_item()
	else: 
		GameManager.selected_item = button.item_id
