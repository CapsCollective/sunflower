extends Container

@onready var label: Label = %Label
@onready var discard_button: Button = %DiscardButton

var item_id: String:
	set(id):
		item_id = id
		update_row()

func _ready():
	discard_button.pressed.connect(discard_item)

func update_row():
	var details = GameManager.get_item_details(item_id)
	label.text = "%s: %s" % [details.name, GameManager.get_item_count(item_id)]

func discard_item():
	GameManager.set_item_count(item_id, 0)
