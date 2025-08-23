extends PersistentDataSection

const PD_SECTION_PLAYER = "player"
const PD_SECTION_PLAYER_TIME = "time"
const PD_SECTION_PLAYER_CURRENT_ZONE = "current_zone"
const PD_SECTION_PLAYER_CURRENT_POSITION = "current_position"
const PD_SECTION_PLAYER_CURRENT_ROTATION = "current_rotation"
const PD_SECTION_PLAYER_INVENTORY = "inventory"
const PD_SECTION_PLAYER_HOTBAR = "hotbar"
const PD_SECTION_PLAYER_STATS = "stats"
const PD_SECTION_PLAYER_STATE = "state"

const DEFAULT_STATS = {
	"energy": 1,
	"radiation": 0,
	"water": 1,
}

const DEFAULT_STATE = {
	"farmer": {
		"met": false,
		"questions_returning": false,
		"hunger": 0,
		"mood": 0,
	},
	"scientist": {
		"met": false,
		"questions_returning": false,
		"hunger": 0,
		"mood": 0,
	}
}


var time: int
var current_zone: StringName
var current_position: Vector3
var current_rotation: Vector3
var inventory: Dictionary # <ItemId, ItemInfo>
var hotbar: Array # Array[ItemId]
var stats: Dictionary # <Stat, float>
var state: Dictionary # <String, Variant>

func get_tag() -> String:
	return PD_SECTION_PLAYER

func serialise() -> Dictionary:
	if GameManager.current_zone:
		current_zone = GameManager.current_zone.zone_id
		var player_character: PlayerCharacter = GameManager.current_zone.player_character
		current_position = player_character.global_position
		current_rotation = player_character.global_rotation
	else:
		current_zone = StringName()
		current_position = Vector3()
		current_rotation = Vector3()
	return {
		PD_SECTION_PLAYER_TIME: time,
		PD_SECTION_PLAYER_CURRENT_ZONE: current_zone,
		PD_SECTION_PLAYER_CURRENT_POSITION: current_position,
		PD_SECTION_PLAYER_CURRENT_ROTATION: current_rotation,
		PD_SECTION_PLAYER_INVENTORY: inventory,
		PD_SECTION_PLAYER_HOTBAR: hotbar,
		PD_SECTION_PLAYER_STATS: stats,
		PD_SECTION_PLAYER_STATE: state
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	time = data.get(PD_SECTION_PLAYER_TIME, 0)
	current_zone = data.get(PD_SECTION_PLAYER_CURRENT_ZONE, StringName())
	current_position = str_to_var("Vector3" + data.get(PD_SECTION_PLAYER_CURRENT_POSITION, "(0,0,0)"))
	current_rotation = str_to_var("Vector3" + data.get(PD_SECTION_PLAYER_CURRENT_ROTATION, "(0,0,0)"))
	inventory = data.get(PD_SECTION_PLAYER_INVENTORY, {})
	hotbar = data.get(PD_SECTION_PLAYER_HOTBAR, [])
	stats = data.get(PD_SECTION_PLAYER_STATS, DEFAULT_STATS.duplicate())
	state = data.get(PD_SECTION_PLAYER_STATE, DEFAULT_STATE.duplicate(true))
	return DeserialisationResult.OK
