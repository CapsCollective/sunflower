extends TransitionScreen

func _ready() -> void:
	modulate = Color(1, 1, 1, 0)

func begin_transition():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1.0)
	tween.finished.connect(func(): state = TransitionState.BEGAN)

func end_transition():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.finished.connect(func(): state = TransitionState.ENDED)
