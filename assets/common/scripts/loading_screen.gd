extends Control

signal faded_out
signal faded_in

func _ready() -> void:
	modulate = Color(1, 1, 1, 0)
	fade_out()

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1.0)
	tween.finished.connect(func(): faded_out.emit())

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.finished.connect(func(): faded_in.emit())
