extends ColorRect

@onready var dial_disc: Sprite2D = %DialDisc

func _ready() -> void:
	GameManager.time_incremented.connect(on_time_tick)
	on_time_tick()

func on_time_tick() -> void:
	dial_disc.rotation_degrees = Savegame.player.time * 15
	pass
