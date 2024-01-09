extends PersistentDataSection

const PD_SECTION_PLAYER = "player"
const PD_SECTION_PLAYER_DAY = "day"
const PD_SECTION_PLAYER_INVENTORY = "inventory"
const PD_SECTION_PLAYER_HOTBAR = "hotbar"
const PD_SECTION_PLAYER_GRID = "grid"
const PD_SECTION_PLAYER_CROPS = "crops"

var day: int
var inventory: Dictionary # <ItemId, ItemInfo>
var hotbar: Array # Array[ItemId]
var grid: Dictionary # <ZoneId, Dict<Vector2i, CellInfo>
var crops: Dictionary # <ZoneId, Dict<Vector2i, CropInfo>

func get_tag() -> String:
	return PD_SECTION_PLAYER

func serialise() -> Dictionary:
	return {
		PD_SECTION_PLAYER_DAY: day,
		PD_SECTION_PLAYER_INVENTORY: inventory,
		PD_SECTION_PLAYER_HOTBAR: hotbar,
		PD_SECTION_PLAYER_GRID: grid,
		PD_SECTION_PLAYER_CROPS: crops
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	day = data.get(PD_SECTION_PLAYER_DAY, 0)
	inventory = data.get(PD_SECTION_PLAYER_INVENTORY, {})
	hotbar = data.get(PD_SECTION_PLAYER_HOTBAR, [])
	
	grid = {}
	var grid_raw = data.get(PD_SECTION_PLAYER_GRID, {})
	for zone_id in grid_raw:
		grid[zone_id] = convert_v2i_keys(grid_raw[zone_id])
	
	crops = {}
	var crops_raw = data.get(PD_SECTION_PLAYER_CROPS, {})
	for zone_id in crops_raw:
		crops[zone_id] = convert_v2i_keys(crops_raw[zone_id])
	
	return DeserialisationResult.OK

func convert_v2i_keys(dict_raw: Dictionary) -> Dictionary:
	var dict = {}
	for point_str in dict_raw:
		dict[str_to_var("Vector2i" + point_str)] = dict_raw[point_str]
	return dict
