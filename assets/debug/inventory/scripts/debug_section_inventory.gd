extends DebugSection

@onready var seeds_button: Button = %SeedsButton
@onready var watering_can_botton: Button = %WateringCanButton

func _ready():
	seeds_button.button_up.connect(add_seeds)
	watering_can_botton.button_up.connect(add_watering_can)

func add_seeds():
	GameManager.change_item_count('sunflower_seed', 3)
	
func add_watering_can():
	GameManager.change_item_count('watering_can', 1)
