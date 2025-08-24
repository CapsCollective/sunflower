class_name Zone extends Node3D

const player_character_scn = preload("res://assets/character/scenes/player_character.tscn")
const npc_character_scn = preload("res://assets/character/scenes/npc_character.tscn")

const characters_dt: Datatable = preload("res://assets/datatables/tables/characters_dt.tres")

@export var zone_id: StringName

var game_cam: GameCamera
var player_character: PlayerCharacter
var grid: Grid3D
var crops: Dictionary = {}

func _ready():
	game_cam = Utils.get_first_node_with_script(self, GameCamera)
	grid = Utils.get_first_node_with_script(self, Grid3D)
	GameManager.register_zone(self)
	GameManager.time_incremented.connect(on_time_incremented)
	
	var zone_crops = Savegame.zones.crops.get(zone_id, {})
	for cell in zone_crops:
		GameManager.spawn_crop_at_cell(cell)
	
	var spawn_position: Vector3
	var spawn_rotation: Vector3
	if GameManager.game_world.level_args.has("spawn_position"):
		spawn_position = GameManager.game_world.level_args.get("spawn_position")
		spawn_rotation = GameManager.game_world.level_args.get("spawn_rotation", Vector3())
	else:
		var spawn_location: StringName = GameManager.game_world.level_args.get("spawn_location", "default")
		var spawn = find_player_spawn(spawn_location)
		if not spawn:
			Utils.log_error("Zones", "Failed to find spawner for location ", spawn_location)
			return
		spawn_position = spawn.global_position
		spawn_rotation = spawn.global_rotation
	player_character = player_character_scn.instantiate()
	add_child(player_character)
	player_character.global_position = spawn_position
	player_character.global_rotation = spawn_rotation
	
	refresh_appointment_spawners(true)

func _exit_tree():
	GameManager.deregister_zone(self)

func get_all_characters():
	return get_tree().get_nodes_in_group("characters")

func find_character(character_id: StringName) -> Character:
	for character in get_all_characters():
		if character.character_id == character_id:
			return character
	return null

func spawn_character(character_id: StringName) -> Character:
	var character: Character = npc_character_scn.instantiate()
	character.character_id = character_id
	add_child(character)
	return character

func find_player_spawn(spawn_id: StringName) -> PlayerSpawn:
	var spawns = Utils.get_all_nodes_with_script(self, PlayerSpawn)
	for spawn in spawns:
		if spawn.spawn_id == spawn_id:
			return spawn
	return null

func find_zone_traversal_for_exit(exit_zone_id: StringName) -> ZoneTraversalTrigger:
	var traversals = Utils.get_all_nodes_with_script(self, ZoneTraversalTrigger)
	for traversal: ZoneTraversalTrigger in traversals:
		if traversal.exits_to_zones.has(exit_zone_id):
			return traversal
	return null

func find_appointment_spawner(spawner_id: StringName) -> AppointmentSpawner:
	var spawners = Utils.get_all_nodes_with_script(self, AppointmentSpawner)
	for spawner in spawners:
		if spawner.spawner_id == spawner_id:
			return spawner
	return null

func on_time_incremented():
	refresh_appointment_spawners()

func refresh_appointment_spawners(intial_check: bool = false):
	for row in characters_dt:
		var appointment: Dictionary = get_active_appointment(row.value)
		if appointment.is_empty():
			Utils.log_warn("Zones", "Received invalid appointment config for \"", row.key, "\"")
			continue
		
		if appointment.details.zone_id == zone_id:
			var changed_now: bool = GameManager.get_hour_of_day() == appointment.time and not intial_check
			if changed_now:
				var traversal: ZoneTraversalTrigger = find_zone_traversal_for_exit(appointment.previous.zone_id)
				if not traversal:
					Utils.log_warn("Zones", "Failed to find exit for zone \"", appointment.previous.zone_id, "\"")
					continue
				run_appointent_spawner(appointment.details.spawner_id, row.key, {"override_spawn_pos": traversal.global_position})
			run_appointent_spawner(appointment.details.spawner_id, row.key)
		else:
			var character: Character = find_character(row.key)
			if not character:
				continue
			var traversal: ZoneTraversalTrigger = find_zone_traversal_for_exit(appointment.details.zone_id)
			if not traversal:
				Utils.log_warn("Zones", "Failed to find exit for zone \"", appointment.details.zone_id, "\"")
				continue
			var action := CharacterActionNavigateTo.new()
			action.configure(character, {"target_pos": traversal.global_position})
			action.completed.connect(func(): character.queue_free())
			character.run_action(action)

func get_active_appointment(row: CharacterConfigRow) -> Dictionary:
	if row.appointments.is_empty():
		return {}
	row.appointments.sort()
	var appointment_times = row.appointments.keys()
	var closest: int = appointment_times[-1]
	var previous: int = appointment_times[-2] if appointment_times.size() > 1 else -1
	var current: int = GameManager.get_hour_of_day()
	for time: int in appointment_times:
		if time > current:
			break
		previous = closest
		closest = time
	return {
		"time": closest,
		"details": row.appointments[closest],
		"previous": row.appointments[previous],
	}

func run_appointent_spawner(spawner_id: StringName, character_id: StringName, spawn_options: Dictionary = {}):
	var spawner: AppointmentSpawner = find_appointment_spawner(spawner_id)
	if not spawner:
		Utils.log_warn("Zones", "Failed to find spawner \"", spawner_id, "\"")
		return
	spawner.run_spawn(character_id, spawn_options)
