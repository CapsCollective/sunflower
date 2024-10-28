extends PersistentDataSection

const PD_SECTION_PLAYER = "player"
const PD_SECTION_PLAYER_TIME = "time"
const PD_SECTION_PLAYER_INVENTORY = "inventory"
const PD_SECTION_PLAYER_HOTBAR = "hotbar"
const PD_SECTION_PLAYER_STATS = "stats"

const DEFAULT_STATS = {
	"energy": 1,
	"radiation": 0,
	"water": 1,
}

var time: int
var inventory: Dictionary # <ItemId, ItemInfo>
var hotbar: Array # Array[ItemId]
var stats: Dictionary # <Stat, float>

func get_tag() -> String:
	return PD_SECTION_PLAYER

func serialise() -> Dictionary:
	return {
		PD_SECTION_PLAYER_TIME: time,
		PD_SECTION_PLAYER_INVENTORY: inventory,
		PD_SECTION_PLAYER_HOTBAR: hotbar,
		PD_SECTION_PLAYER_STATS: stats
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	time = data.get(PD_SECTION_PLAYER_TIME, 0)
	inventory = data.get(PD_SECTION_PLAYER_INVENTORY, {})
	hotbar = data.get(PD_SECTION_PLAYER_HOTBAR, [])
	stats = data.get(PD_SECTION_PLAYER_STATS, DEFAULT_STATS.duplicate())
	return DeserialisationResult.OK
