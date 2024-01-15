extends PersistentDataSection

const PD_SECTION_PLAYER = "player"
const PD_SECTION_PLAYER_DAY = "day"
const PD_SECTION_PLAYER_INVENTORY = "inventory"
const PD_SECTION_PLAYER_HOTBAR = "hotbar"

var day: int
var inventory: Dictionary # <ItemId, ItemInfo>
var hotbar: Array # Array[ItemId]

func get_tag() -> String:
	return PD_SECTION_PLAYER

func serialise() -> Dictionary:
	return {
		PD_SECTION_PLAYER_DAY: day,
		PD_SECTION_PLAYER_INVENTORY: inventory,
		PD_SECTION_PLAYER_HOTBAR: hotbar,
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	day = data.get(PD_SECTION_PLAYER_DAY, 0)
	inventory = data.get(PD_SECTION_PLAYER_INVENTORY, {})
	hotbar = data.get(PD_SECTION_PLAYER_HOTBAR, [])
	return DeserialisationResult.OK
