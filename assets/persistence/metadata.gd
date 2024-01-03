extends MetadataSection

const PD_METADATA = "metadata"
const PD_METADATA_SAVE_VERSION = "save_version"
const PD_METADATA_SAVE_TIME = "save_time"

const SAVE_VERSION: int = 0

var deserialised_metadata: Dictionary = {}

func get_tag() -> String:
	return PD_METADATA

func serialise() -> Dictionary:
	return {
		PD_METADATA_SAVE_VERSION: SAVE_VERSION,
		PD_METADATA_SAVE_TIME: Time.get_datetime_string_from_system(true, true)
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	if not data.has(PD_METADATA):
		return DeserialisationResult.FAILED
	deserialised_metadata = data[PD_METADATA]
	return DeserialisationResult.OK
