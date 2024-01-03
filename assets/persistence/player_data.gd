extends PersistentDataSection

const PD_SECTION_PLAYER = "player"
const PD_SECTION_PLAYER_DAY = "day"
const PD_SECTION_PLAYER_INVENTORY = "inventory"
const PD_SECTION_PLAYER_AREA = "area"

const GRID_WIDTH = 10
const GRID_HEIGHT = 10

var day: int
var inventory: Dictionary
var area_map: Dictionary

func get_tag() -> String:
	return PD_SECTION_PLAYER

func serialise() -> Dictionary:
	return {
		PD_SECTION_PLAYER_DAY: day,
		PD_SECTION_PLAYER_INVENTORY: inventory,
		PD_SECTION_PLAYER_AREA: area_map,
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	day = data.get(PD_SECTION_PLAYER_DAY, 0)
	inventory = data.get(PD_SECTION_PLAYER_INVENTORY, {})
	area_map = data.get(PD_SECTION_PLAYER_AREA, _init_map())
	return DeserialisationResult.OK

func _init_map() -> Dictionary:
	var map = {}
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			map[Vector2i(x,y)] = {
				'nutrition': 0,
				'hydration': 0,
				'radiation': 0.5
			}
	return map
