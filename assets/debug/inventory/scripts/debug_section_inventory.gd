extends DebugSection

@onready var seeds_button: Button = %SeedsButton
@onready var tools_button: Button = %ToolsButton

func _ready():
	seeds_button.button_up.connect(add_seeds)
	tools_button.button_up.connect(add_tools)

func add_seeds():
	GameManager.change_item_count('sunflower_seed', 3)
	
func add_tools():
	GameManager.set_item_count('watering_can', 1)
	GameManager.set_item_count('scanner', 1)
