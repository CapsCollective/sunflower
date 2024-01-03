extends PersistentDataSection

const PD_SECTION_PLAYER = "player"
const PD_SECTION_PLAYER_DAY = "day"
const PD_SECTION_PLAYER_INVENTORY = "inventory"

var day: int
var inventory: Dictionary

func get_tag() -> String:
	return PD_SECTION_PLAYER

func serialise() -> Dictionary:
	return {
		PD_SECTION_PLAYER_DAY: day,
		PD_SECTION_PLAYER_INVENTORY: inventory,
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	day = data.get(PD_SECTION_PLAYER_DAY, 0)
	inventory = data.get(PD_SECTION_PLAYER_INVENTORY, {})
	return DeserialisationResult.OK
