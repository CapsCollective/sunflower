extends PanelContainer

const attribute_bar_scn = preload("res://assets/items/scenes/attribute_bar.tscn")

@onready var crop_label: Label = %CropLabel
@onready var growth_label: Label = %GrowthLabel
@onready var health_label: Label = %HealthLabel
@onready var attributes_container = %AttributesContainer
var selected_crop = {}

func _ready():
	visible = false
	GameManager.item_selected.connect(on_item_selected)
	GameManager.cell_hovered.connect(on_hover_cell)

func on_item_selected(item_id: String):
	if GameManager.crops_dt.has(item_id):
		selected_crop = {
			"seed_id": item_id,
			"growth": 0,
		}
		set_crop(item_id)
	else:
		visible = false

func on_hover_cell(cell: Vector2i):
	var planted = false
	if GameManager.crops_dt.has(GameManager.selected_item):
		selected_crop.health = GameManager.get_crop_health(GameManager.current_zone.id, cell, GameManager.selected_item)
	else:
		selected_crop = GameManager.get_crop_in_current_zone(cell)
		if selected_crop != null:
			planted = true
			set_crop(selected_crop.seed_id)
	
	if not selected_crop:
		visible = false
		return
	visible = true
	growth_label.visible = planted
	growth_label.text = "Growth: %.2f" % selected_crop.growth
	health_label.text = "Health: %d%%" % [selected_crop.health * 100]
	for attribute_bar in attributes_container.get_children():
		attribute_bar.on_hover_cell(cell)

func set_crop(seed_id):
	crop_label.text = selected_crop.seed_id
	var crop_details: CropConfigRow = GameManager.crops_dt.get_row(selected_crop.seed_id)
	Utils.queue_free_children(attributes_container)
	for attr in crop_details.attributes:
		var bar: AttributeBar = attribute_bar_scn.instantiate()
		attributes_container.add_child(bar)
		bar.set_attribute(attr)
