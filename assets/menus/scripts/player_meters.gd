extends Container

const quality_gradient: Gradient = preload("res://assets/content/crops/data/quality_gradient.tres")

@onready var water_label: Label = %WaterLabel
@onready var energy_slider: ProgressBar = %EnergySlider
@onready var water_slider: ProgressBar = %WaterSlider
@onready var radiation_slider: ProgressBar = %RadiationSlider

func _ready():
	GameManager.item_selected.connect(on_item_selected)
	GameManager.stat_updated.connect(on_stat_updated)
	water_label.visible = false
	water_slider.visible = false
	on_stat_updated("energy")
	on_stat_updated("water")
	on_stat_updated("radiation")

func on_item_selected(item_id: String):
	var display_water = item_id == "watering_can"
	water_label.visible = display_water
	water_slider.visible = display_water

func on_stat_updated(stat: String):
	var value = GameManager.get_stat(stat)
	match(stat):
		"energy":
			energy_slider.value = value
			energy_slider.get("theme_override_styles/fill").bg_color = quality_gradient.sample(value)
		"water":
			water_slider.value = value
		"radiation":
			radiation_slider.value = value + 0.1
