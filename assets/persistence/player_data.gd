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
	
	var zones_raw = data.get(PD_SECTION_PLAYER_ZONES, {})
	for zone_id in zones_raw:
		zones[zone_id] = convert_dict_keys(zones_raw[zone_id])
	
	var crops_raw = data.get(PD_SECTION_PLAYER_CROPS, {})
	for zone_id in crops_raw:
		crops[zone_id] = convert_dict_keys(crops_raw[zone_id])
	
	return DeserialisationResult.OK


func convert_dict_keys(dict_raw: Dictionary) -> Dictionary:
	var dict = {}
	for point_str in dict_raw:
		dict[str_to_var("Vector2i" + point_str)] = dict_raw[point_str]
	return dict
