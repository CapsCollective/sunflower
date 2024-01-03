class_name PersistentDataSection

const DeserialisationResult = PersistentDataFile.DeserialisationResult

func _init(file: PersistentDataFile):
	reset()
	file.register_section(self)

func get_tag() -> String:
	return "none"

func serialise() -> Dictionary:
	return {}

func deserialise(_data: Dictionary) -> DeserialisationResult:
	return DeserialisationResult.OK

func reset():
	deserialise({})
