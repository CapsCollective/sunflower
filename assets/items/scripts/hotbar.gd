extends Node

const HOTBAR_ITEMS = 5

const hotbar_item_scene = preload("res://assets/items/scenes/hotbar_item.tscn")
@onready var button_group: ButtonGroup = ButtonGroup.new()

func _ready():
	button_group.allow_unpress = true
	button_group.pressed.connect(on_item_selected)
	GameManager.hotbar_updated.connect(refresh)
	refresh()

func refresh():
	for c in get_children():
		c.queue_free()
	for slot in range(HOTBAR_ITEMS):
		var instance: HotbarItem = hotbar_item_scene.instantiate()
		add_child(instance)
		instance.button_group = button_group
		if (len(Savegame.player.hotbar) > slot):
			instance.item_id = Savegame.player.hotbar[slot]

func on_item_selected(button: HotbarItem):
	GameManager.selected_item = button.item_id
