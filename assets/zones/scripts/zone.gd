class_name Zone extends Node3D

const player_character_scn = preload("res://assets/character/scenes/player_character.tscn")
const npc_character_scn = preload("res://assets/character/scenes/npc_character.tscn")

const appointments_dt: Datatable = preload("res://assets/datatables/tables/appointments_dt.tres")

@export var id: StringName

var game_cam: GameCamera
var player_character: PlayerCharacter
var grid: Grid3D
var crops: Dictionary = {}

func _ready():
	game_cam = Utils.get_first_node_with_script(self, GameCamera)
	grid = Utils.get_first_node_with_script(self, Grid3D)
	GameManager.register_zone(self)
	GameManager.time_incremented.connect(on_time_incremented)
	
	var zone_crops = Savegame.zones.crops.get(id, {})
	for cell in zone_crops:
		GameManager.spawn_crop_at_cell(cell)
	
	var spawn_position: Vector3
	var spawn_rotation: Vector3
	if GameManager.game_world.level_args.has("spawn_position"):
		spawn_position = GameManager.game_world.level_args.get("spawn_position")
		spawn_rotation = GameManager.game_world.level_args.get("spawn_rotation", Vector3())
	else:
		var spawn_location: StringName = GameManager.game_world.level_args.get("spawn_location", "default")
		var spawn = find_spawn_location(spawn_location)
		if not spawn:
			Utils.log_error("Zones", "Failed to find spawner for location ", spawn_location)
			return
		spawn_position = spawn.global_position
		spawn_rotation = spawn.global_rotation
	player_character = player_character_scn.instantiate()
	add_child(player_character)
	player_character.global_position = spawn_position
	player_character.global_rotation = spawn_rotation
	
	# TODO Make up for most recent appointment
	refresh_appointment_spawners()

func _exit_tree():
	GameManager.deregister_zone(self)

func get_all_characters():
	return get_tree().get_nodes_in_group("characters")

func find_character(character_id: StringName) -> Character:
	for character in get_all_characters():
		if character.id == character_id:
			return character
	return null

func spawn_character(character_id: StringName) -> Character:
	var character: Character = npc_character_scn.instantiate()
	character.id = character_id
	add_child(character)
	return character

func find_spawn_location(spawner_id: StringName) -> ZoneSpawn:
	var spawners = Utils.get_all_nodes_with_script(self, ZoneSpawn)
	for spawner in spawners:
		if spawner.id == spawner_id:
			return spawner
	return null

func find_appointment_spawner(spawner_id: StringName) -> AppointmentSpawner:
	var spawners = Utils.get_all_nodes_with_script(self, AppointmentSpawner)
	for spawner in spawners:
		if spawner.id == spawner_id:
			return spawner
	return null

func on_time_incremented():
	refresh_appointment_spawners()

func refresh_appointment_spawners():
	for row in appointments_dt:
		var appointment: AppointmentConfig = row.value.appointments.get(Savegame.player.time, null)
		if appointment and appointment.zone_id == id:
			refresh_appointment_spawner(row.key, appointment.spawner_id)

func refresh_appointment_spawner(character_id: StringName, spawner_id: StringName):
	var spawner: AppointmentSpawner = find_appointment_spawner(spawner_id)
	if not spawner:
		Utils.log_warn("Zones", "Failed to find spawner \"", spawner_id, "\"")
		return
	spawner.run_spawn(character_id)
