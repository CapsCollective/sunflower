extends PanelContainer

const attribute_bar_scn = preload("res://assets/items/scenes/attribute_bar.tscn")

@onready var crop_label: Label = %CropLabel
@onready var growth_label: Label = %GrowthLabel
@onready var health_label: Label = %HealthLabel
@onready var attributes_container = %AttributesContainer
var selected_crop = {}
var selected_cell
var planted = false

func _ready():
	visible = false
	GameManager.item_selected.connect(on_item_selected)
	GameManager.cell_hovered.connect(on_hover_cell)
	GameManager.grid_updated.connect(update_display)

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
	selected_cell = cell
	planted = false
	if not GameManager.crops_dt.has(GameManager.selected_item):
		selected_crop = GameManager.get_crop_in_current_zone(cell)
		if selected_crop != null:
			planted = true
			set_crop(selected_crop.seed_id)
	if not selected_crop:
		visible = false
		return
	visible = true
	update_display()

func set_crop(seed_id):
	var crop_details: CropConfigRow = GameManager.crops_dt.get_row(selected_crop.seed_id)
	crop_label.text = crop_details.name
	Utils.queue_free_children(attributes_container)
	for attr in crop_details.attributes:
		var bar: AttributeBar = attribute_bar_scn.instantiate()
		attributes_container.add_child(bar)
		bar.set_attribute(attr)

func update_display():
	if not selected_crop or not selected_cell:
		return
	# Get current not lerped health for plant
	var health = GameManager.get_crop_health(GameManager.current_zone.id, selected_cell, selected_crop.seed_id)
	growth_label.visible = planted
	health_label.visible = true
	if planted:
		var status = "Growing"
		if GameManager.is_crop_ripe(GameManager.current_zone.id, selected_cell):
			status = "Harvestable"
		elif selected_crop.health == 0:
			health_label.visible = false
			status = "Decayed"
		elif health < selected_crop.health and health < GameManager.crop_planting_min_health:
			status = "Withering"
		growth_label.text = "Status: %s" % status
	
	health_label.text = "Health: %d%%" % [health * 100]
	for attribute_bar in attributes_container.get_children():
		attribute_bar.on_hover_cell(selected_cell)
