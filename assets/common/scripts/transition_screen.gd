class_name TransitionScreen extends Control

enum TransitionState {
	UNSTARTED,
	BEGAN,
	ENDED
}

signal transition_began
signal transition_ended

var state: TransitionState = TransitionState.UNSTARTED:
	set(new_state):
		state = new_state
		match(state):
			TransitionState.BEGAN:
				transition_began.emit()
			TransitionState.ENDED:
				transition_ended.emit()

func began() -> bool:
	return state == TransitionState.BEGAN

func ended() -> bool:
	return state == TransitionState.ENDED

func begin_transition():
	pass

func end_transition():
	pass
