#!/usr/bin/env -S godot -s
extends SceneTree

const Utils = preload("res://assets/common/scripts/utils.gd")
const EXPORT_PRESETS_FILE: String = "res://export_presets.cfg"

func _init():
	var result = apply_version()
	quit(0 if result else 1)

func apply_version() -> bool:
	var export_presets = ConfigFile.new()
	if export_presets.load(EXPORT_PRESETS_FILE) != OK:
		return false
	
	var version: String = Utils.get_version()
	var short_version = ".".join(version.rsplit("."))
	var long_version = (".".join(version.split(".").slice(0, 3))) + ".0"
	
	export_presets.set_value("preset.0.options", "application/version", version)
	export_presets.set_value("preset.0.options", "application/short_version", short_version)
	export_presets.set_value("preset.1.options", "application/file_version", long_version)
	export_presets.set_value("preset.1.options", "application/product_version", long_version)
	export_presets.save(EXPORT_PRESETS_FILE)
	
	return true
