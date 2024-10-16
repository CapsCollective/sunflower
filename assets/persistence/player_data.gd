extends PersistentDataSection

const PD_SECTION_PLAYER = "player"
const PD_SECTION_PLAYER_DAY = "day"
const PD_SECTION_PLAYER_INVENTORY = "inventory"
const PD_SECTION_PLAYER_HOTBAR = "hotbar"
const PD_SECTION_PLAYER_HEALTH = "health"
const PD_SECTION_PLAYER_ENERGY = "energy"
const PD_SECTION_PLAYER_WATER = "water"

var day: int
var inventory: Dictionary # <ItemId, ItemInfo>
var hotbar: Array # Array[ItemId]
var health: int
var energy: int
var water: int

func get_tag() -> String:
	return PD_SECTION_PLAYER

func serialise() -> Dictionary:
	return {
		PD_SECTION_PLAYER_DAY: day,
		PD_SECTION_PLAYER_INVENTORY: inventory,
		PD_SECTION_PLAYER_HOTBAR: hotbar,
		PD_SECTION_PLAYER_HEALTH: health,
		PD_SECTION_PLAYER_ENERGY: energy,
		PD_SECTION_PLAYER_WATER: water
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	day = data.get(PD_SECTION_PLAYER_DAY, 0)
	inventory = data.get(PD_SECTION_PLAYER_INVENTORY, {})
	hotbar = data.get(PD_SECTION_PLAYER_HOTBAR, [])
	health = data.get(PD_SECTION_PLAYER_HEALTH, 100)
	energy = data.get(PD_SECTION_PLAYER_ENERGY, 100)
	water = data.get(PD_SECTION_PLAYER_WATER, 0)
	return DeserialisationResult.OK
