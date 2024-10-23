class_name DialogueScriptValidation extends ValidationManager.Validation

const Utils = preload("res://assets/common/scripts/utils.gd") 

func get_name() -> String:
	return "DialogueScriptValidation"

func run_validations() -> bool:
	var result: bool = true
	var dialogue_scripts = find_dialogue_scripts_in_dir("res://assets")
	for script in dialogue_scripts:
		Utils.push_info("  - Validating ", script, "...")
		var dialogue_script: DialogueScript = DialogueScript.new(script)
		if not DialogueValidator.validate_script(dialogue_script):
			result = false
	return result

func find_dialogue_scripts_in_dir(dir_path: String) -> Array[String]:
	var dir: DirAccess = DirAccess.open(dir_path)
	if not dir:
		push_error("Failed to open assets directory for scan.")
		return []
	var files: Array[String] = []
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name:
		var full_path: String = "%s/%s"%[dir_path, file_name]
		if dir.current_is_dir():
			files.append_array(find_dialogue_scripts_in_dir(full_path))
		elif DialogueValidator.is_dialogue_script(full_path):
			files.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	return files
