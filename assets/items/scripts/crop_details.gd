extends PanelContainer

@onready var crop_label: Label = %CropLabel
@onready var growth_label: Label = %GrowthLabel
@onready var health_label: Label = %HealthLabel

func _ready():
	visible = false
	GameManager.crop_hovered.connect(on_hover_crop)
	GameManager.crop_unhovered.connect(on_unhover_crop)

	
func on_hover_crop(cell: Vector2i):
	visible = true
	var crop = GameManager.get_crop_in_current_zone(cell)
	crop_label.text = crop.seed_id
	growth_label.text = "Growth: %.2f" % crop.growth
	health_label.text = "Health: %d" % [crop.health * 100]

func on_unhover_crop():
	visible = false
