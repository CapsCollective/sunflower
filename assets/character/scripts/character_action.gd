class_name CharacterAction extends Resource

signal started
signal completed
signal aborted
signal ended

var active: bool = false
var character: Character

func configure(owning_character: Character, _params: Dictionary):
	character = owning_character

func _init():
	on_init()

func on_init():
	pass

func start():
	on_start()
	active = true
	started.emit()

func on_start():
	pass

func tick(delta: float):
	on_tick(delta)

func on_tick(_delta: float):
	pass

func abort():
	on_abort()
	active = false
	aborted.emit()
	ended.emit()

func on_abort():
	pass

func complete():
	active = false
	completed.emit()
	ended.emit()

func on_complete():
	pass

func on_ended():
	pass
