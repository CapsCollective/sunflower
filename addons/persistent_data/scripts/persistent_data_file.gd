class_name PersistentDataFile extends Node

enum DeserialisationResult {
	OK = 0,
	RECOVERED = 1,
	FAILED = 2,
}

var metadata_section: MetadataSection
var save_sections: Dictionary = {}

func get_file_name() -> String:
	return "user://persistent_data.save"

func register_metadata(metadata: MetadataSection):
	metadata_section = metadata

func register_section(section: PersistentDataSection):
	var tag = section.get_tag()
	if save_sections.has(tag):
		push_warning("Registration Warning: Section tag \"", tag, "\" already registered, skipping registration.")
		return
	save_sections[tag] = section

func serialise_all_sections() -> Dictionary:
	var save_data: Dictionary = {}
	if metadata_section:
		save_data[metadata_section.get_tag()] = metadata_section.serialise()
	for section in save_sections.values():
		save_data[section.get_tag()] = section.serialise()
	return save_data

func deserialise_all_sections(data: Dictionary) -> DeserialisationResult:
	var result: DeserialisationResult = metadata_section.deserialise(data) if metadata_section else OK
	for section in save_sections.values():
		var tag = section.get_tag()
		if not data.has(tag):
			continue
		var section_result = section.deserialise(data[tag])
		if section_result == DeserialisationResult.FAILED:
			push_error("Deserialisation Error: Failed to deserialise section \"", tag, "\".")
		elif section_result == DeserialisationResult.RECOVERED:
			push_warning("Deserialisation Warning: Deserialisation of section \"", tag, "\" required recovery.")
		result = (section_result if section_result > result else result)
	return result

func save_file():
	var file = FileAccess.open(get_file_name(), FileAccess.WRITE)
	var json_string = JSON.stringify(serialise_all_sections())
	file.store_line(json_string)

func load_file():
	var file_name = get_file_name()
	if not FileAccess.file_exists(file_name):
		return
	var save_game = FileAccess.open(file_name, FileAccess.READ)
	
	var json_string: String
	while save_game.get_position() < save_game.get_length():
		json_string = json_string + save_game.get_line()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		push_error("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line(), ".")
	var save_data = json.get_data()
	if deserialise_all_sections(save_data) == DeserialisationResult.FAILED:
		push_error("Deserialisation Error: Some sections failed to deserialise.")

func reset_file():
	var file_name = get_file_name()
	if not FileAccess.file_exists(file_name):
		return
	DirAccess.remove_absolute(file_name)
	metadata_section.reset()
	for section in save_sections.values():
		section.reset()
	save_file()

func get_dump() -> Dictionary:
	return serialise_all_sections()
