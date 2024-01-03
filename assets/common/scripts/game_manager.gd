extends Node

signal load_completed

var game_world: GameWorld:
	set(world):
		Utils.log_info("Initialisation", "Game world registered")
		game_world = world

var current_zone: Zone

func _ready():
	Savegame.load_file()
	Utils.log_info("Deserialisation", Savegame.get_dump())
	load_completed.emit()

func register_zone(zone: Zone):
	current_zone = zone

func deregister_zone(zone: Zone):
	if zone == current_zone:
		current_zone = null
