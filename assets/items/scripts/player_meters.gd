extends Container

@onready var health_slider: Slider = %HealthSlider
@onready var energy_slider: Slider = %EnergySlider


func _ready():
	GameManager.health_changed.connect(on_health_changed)
	GameManager.energy_changed.connect(on_energy_changed)
	on_health_changed()
	on_energy_changed()

func on_health_changed():
	health_slider.value = Savegame.player.health

func on_energy_changed():
	energy_slider.value = Savegame.player.energy
