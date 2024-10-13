extends PanelContainer

const attribute_bar_scn = preload("res://assets/items/scenes/attribute_bar.tscn")

@onready var crop_label: Label = %CropLabel
@onready var growth_label: Label = %GrowthLabel
@onready var health_label: Label = %HealthLabel
@onready var attributes_container = %AttributesContainer
var hovered_crop

func _ready():
	visible = false
	GameManager.crop_hovered.connect(on_hover_crop)
	GameManager.crop_unhovered.connect(on_unhover_crop)

func on_hover_crop(cell: Vector2i):
	visible = true
	hovered_crop = GameManager.get_crop_in_current_zone(cell)
	print(hovered_crop)
	crop_label.text = hovered_crop.seed_id
	growth_label.text = "Growth: %.2f" % hovered_crop.growth
	health_label.text = "Health: %d" % [hovered_crop.health * 100]
	var crop_details: CropConfigRow = GameManager.crops_dt.get_row(hovered_crop.seed_id)
	Utils.queue_free_children(attributes_container)
	for attr in crop_details.attributes:
		var bar: AttributeBar = attribute_bar_scn.instantiate()
		attributes_container.add_child(bar)
		bar.set_attribute(cell, attr)

func on_unhover_crop():
	visible = false
