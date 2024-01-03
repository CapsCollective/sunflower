extends PersistentDataSection

const PD_SECTION_EXAMPLE = "example"
const PD_SECTION_EXAMPLE_TIME = "time"
const PD_SECTION_EXAMPLE_VALUE = "value"

var time: int
var value: int

func get_tag() -> String:
	return PD_SECTION_EXAMPLE

func serialise() -> Dictionary:
	return {
		PD_SECTION_EXAMPLE_TIME: time,
		PD_SECTION_EXAMPLE_VALUE: value,
	}

func deserialise(data: Dictionary) -> DeserialisationResult:
	time = data.get(PD_SECTION_EXAMPLE_TIME, 0)
	value = data.get(PD_SECTION_EXAMPLE_VALUE, 0)
	return DeserialisationResult.OK
