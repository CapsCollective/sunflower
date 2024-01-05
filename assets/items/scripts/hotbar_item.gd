class_name HotbarItem extends Button

@onready var counter: Label = %Label

var item_id: String:
	set(id):
		item_id = id
		var details = GameManager.get_item_details(item_id)
		icon = load(details.icon_path)
		counter.text = str(GameManager.get_item_count(item_id))
		disabled = id == null

func _ready():
	GameManager.inventory_updated.connect(update_count)
	
func update_count(id: String, count: int):
	if id == item_id:
		counter.text = str(count)
