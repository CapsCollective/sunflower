extends PersistentDataSection

const PD_SECTION_ZONES = "zones"
const PD_SECTION_ZONES_GRID_PROPS = "grid_props"
const PD_SECTION_ZONES_CROPS = "crops"

var grid_props: Dictionary # <ZoneId, Dict<Vector2i, CellInfo>
var crops: Dictionary # <ZoneId, Dict<Vector2i, CropInfo>

func get_tag() -> String:
	return PD_SECTION_ZONES

func serialise() -> Dictionary:
	return {
		PD_SECTION_ZONES_GRID_PROPS: grid_props,
		PD_SECTION_ZONES_CROPS: crops
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	grid_props = {}
	var grid_props_raw = data.get(PD_SECTION_ZONES_GRID_PROPS, {})
	for zone_id in grid_props_raw:
		grid_props[zone_id] = convert_v2i_keys(grid_props_raw[zone_id])
	
	crops = {}
	var crops_raw = data.get(PD_SECTION_ZONES_CROPS, {})
	for zone_id in crops_raw:
		crops[zone_id] = convert_v2i_keys(crops_raw[zone_id])
	
	return DeserialisationResult.OK

func convert_v2i_keys(dict_raw: Dictionary) -> Dictionary:
	var dict = {}
	for point_str in dict_raw:
		dict[str_to_var("Vector2i" + point_str)] = dict_raw[point_str]
	return dict
