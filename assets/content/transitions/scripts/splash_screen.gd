extends TransitionScreen

func begin_transition():
	state = TransitionState.BEGAN

func end_transition():
	await get_tree().create_timer(1.0).timeout
	state = TransitionState.ENDED
