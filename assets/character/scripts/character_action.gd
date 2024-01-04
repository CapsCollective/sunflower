class_name CharacterAction extends RefCounted

signal started
signal completed
signal aborted
signal ended

var active: bool = false
var character: Character

func _init(owning_character: Character):
	character = owning_character

func start():
	active = true
	started.emit()

func abort():
	active = false
	aborted.emit()
	ended.emit()

func complete():
	active = false
	completed.emit()
	ended.emit()
