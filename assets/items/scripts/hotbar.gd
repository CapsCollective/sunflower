extends Node

const hotbar_item_scene = preload("res://assets/items/scenes/hotbar_item.tscn")
@onready var button_group: ButtonGroup = ButtonGroup.new()

func _ready():
	button_group.pressed.connect(on_item_selected)
	button_group.allow_unpress = true
	refresh()

func refresh():
	print ("Loading")
	for c in get_children():
		c.queue_free()
	for item in GameManager.items_dt:
		print(item.key)
		var instance: HotbarItem = hotbar_item_scene.instantiate()
		add_child(instance)
		var details = GameManager.get_item_details(item.key)
		instance.icon = load(details.icon_path)
		instance.button_group = button_group
		instance.counter.text = str(GameManager.get_item_count(item.key))

func on_item_selected(button: HotbarItem):
	GameManager.selected_item = button.item_id
