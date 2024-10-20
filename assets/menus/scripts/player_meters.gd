extends Container

@onready var water_label: Label = %WaterLabel
@onready var water_slider: ProgressBar = %WaterSlider
@onready var health_slider: ProgressBar = %HealthSlider
@onready var energy_slider: ProgressBar = %EnergySlider

func _ready():
	GameManager.item_selected.connect(on_item_selected)
	GameManager.water_changed.connect(on_water_changed)
	GameManager.health_changed.connect(on_health_changed)
	GameManager.energy_changed.connect(on_energy_changed)
	on_health_changed()
	on_energy_changed()
	on_water_changed()
	water_label.visible = false
	water_slider.visible = false

func on_item_selected(item_id: String):
	var display_water = item_id == "watering_can"
	water_label.visible = display_water
	water_slider.visible = display_water

func on_water_changed():
	water_slider.value = Savegame.player.water

func on_health_changed():
	health_slider.value = Savegame.player.health

func on_energy_changed():
	energy_slider.value = Savegame.player.energy
