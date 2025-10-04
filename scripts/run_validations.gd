#!/usr/bin/env -S godot -s
extends SceneTree

const Validations = preload("res://assets/validation/validations.gd")

func _init():
	var manager = Validations.ValidationManager.new()
	var result = manager.run_all_validations()
	quit(0 if result else 1)
