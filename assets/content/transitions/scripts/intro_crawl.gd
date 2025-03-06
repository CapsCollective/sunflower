extends TransitionScreen

func begin_transition():
	state = TransitionState.BEGAN

func end_transition():
	$ContinueButton.pressed.connect(on_continue_btn_pressed)
	$ContinueButton.visible = true

func on_continue_btn_pressed():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.finished.connect(func(): state = TransitionState.ENDED)
