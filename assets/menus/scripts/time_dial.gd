extends ColorRect

@onready var dial_disc: Sprite2D = %DialDisc

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	dial_disc.rotate(-0.01 * delta)
	pass
