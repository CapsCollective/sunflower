extends PersistentDataSection

const PD_SECTION_PLAYER = "player"
const PD_SECTION_PLAYER_DAY = "day"
const PD_SECTION_PLAYER_INVENTORY = "inventory"
const PD_SECTION_PLAYER_ZONES = "zones"
const PD_SECTION_PLAYER_CROPS = "crops"

var day: int
var inventory: Dictionary
var zones: Dictionary # <ZoneId, Dict<Vector2i, ZoneData>
var crops: Dictionary

func get_tag() -> String:
	return PD_SECTION_PLAYER

func serialise() -> Dictionary:
	return {
		PD_SECTION_PLAYER_DAY: day,
		PD_SECTION_PLAYER_INVENTORY: inventory,
		PD_SECTION_PLAYER_ZONES: zones,
		PD_SECTION_PLAYER_CROPS: crops
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	day = data.get(PD_SECTION_PLAYER_DAY, 0)
	inventory = data.get(PD_SECTION_PLAYER_INVENTORY, {})
	zones = data.get(PD_SECTION_PLAYER_ZONES, {})
	crops = data.get(PD_SECTION_PLAYER_CROPS, {})
	return DeserialisationResult.OK
