extends DebugSection

@onready var seeds_button: Button = %SeedsButton

func _ready():
	seeds_button.button_up.connect(add_seeds)

func add_seeds():
	GameManager.change_item_count('sunflower_seed', 3)
