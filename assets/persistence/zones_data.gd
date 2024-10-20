extends PersistentDataSection

const PD_SECTION_ZONES = "zones"
const PD_SECTION_ZONES_SOIL_ATTRS = "soil_attrs"
const PD_SECTION_ZONES_CROPS = "crops"

var soil_attrs: Dictionary # <ZoneId, Dict<Vector2i, CellInfo>
var crops: Dictionary # <ZoneId, Dict<Vector2i, CropInfo>

func get_tag() -> String:
	return PD_SECTION_ZONES

func serialise() -> Dictionary:
	return {
		PD_SECTION_ZONES_SOIL_ATTRS: soil_attrs,
		PD_SECTION_ZONES_CROPS: crops
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	soil_attrs = {}
	var soil_attrs_raw = data.get(PD_SECTION_ZONES_SOIL_ATTRS, {})
	for zone_id in soil_attrs_raw:
		soil_attrs[zone_id] = Utils.convert_v2i_keys(soil_attrs_raw[zone_id])
		for cell in soil_attrs[zone_id]:
			soil_attrs[zone_id][cell] = Utils.convert_int_keys(soil_attrs[zone_id][cell])
	
	crops = {}
	var crops_raw = data.get(PD_SECTION_ZONES_CROPS, {})
	for zone_id in crops_raw:
		crops[zone_id] = Utils.convert_v2i_keys(crops_raw[zone_id])
	return DeserialisationResult.OK
