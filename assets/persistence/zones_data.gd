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
		grid_props[zone_id] = Utils.convert_v2i_keys(grid_props_raw[zone_id])
	
	crops = {}
	var crops_raw = data.get(PD_SECTION_ZONES_CROPS, {})
	for zone_id in crops_raw:
		crops[zone_id] = Utils.convert_v2i_keys(crops_raw[zone_id])
	
	return DeserialisationResult.OK
