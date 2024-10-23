class_name DialogueScript extends RefCounted

enum DialogueScriptSegmentType {
	LINE,
	OPTION,
	UNKNOWN,
}

signal started
signal ended
signal line_executed(line: Variant)
signal options_executed(options: Array[Variant], line: Variant)
signal advanced
signal advanced_with_option(option_id: int)

var file_path: String
var segments: Dictionary = {}
var current_segment_id: StringName
var context_object: Variant

func _init(file: String):
	file_path = file
	load_file()

func load_file():
	if not FileAccess.file_exists(file_path):
		push_error("File Error: no file found at ", file_path, ".")
		return
	var json_string = FileAccess.get_file_as_string(file_path)
	var json = JSON.new()
	if json.parse(json_string) != OK:
		push_error("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line(), ".")
		return
	segments = json.get_data()

func progress_segment():
	if current_segment_id.is_empty():
		end()
		return
	var current_segment = get_current_segment()
	if not current_segment:
		push_error("Dialogue Error: failed to retrieve current segment \"", current_segment_id, "\"")
		return
	match(get_segment_type(current_segment)):
		DialogueScriptSegmentType.LINE:
			var line = find_first_valid_line(current_segment.lines)
			if not line:
				push_warning("Failed to find valid line at \"", current_segment_id, "\"")
				return
			var execution = line.get("execution", null)
			if execution:
				run_execution(execution)
			line = line.duplicate(true)
			process_text(line)
			var formatting = line.get("formatting", null)
			if formatting:
				substitute_format_values(formatting)
				line.processed_text = line.processed_text.format(formatting)
			current_segment_id = line.get("next", StringName())
			execute_line(line)
		DialogueScriptSegmentType.OPTION:
			var valid_options = find_all_valid_options(current_segment.options)
			if valid_options.is_empty():
				push_warning("Failed to find valid options at \"", current_segment_id, "\"")
				return
			for key in valid_options:
				var option = valid_options[key]
				process_text(option)
			var line = find_first_valid_line(current_segment.get("lines", []))
			if line:
				line = line.duplicate()
				process_text(line)
				var formatting = line.get("formatting", null)
				if formatting:
					substitute_format_values(formatting)
					line.processed_text = line.processed_text.format(formatting)
			execute_options(valid_options, line)
		DialogueScriptSegmentType.UNKNOWN:
			push_warning("Encountered unknown segment type at \"", current_segment_id, "\"")

func select_option(option_id: int) -> bool:
	var current_segment = get_current_segment()
	if not current_segment:
		push_error("Dialogue Error: failed to retrieve current segment \"", current_segment_id, "\"")
		return false
	if not get_segment_type(current_segment) == DialogueScriptSegmentType.OPTION:
		push_warning("Attempted to select option on non-options segment \"", current_segment_id, "\"")
		return false
	var option = current_segment.options[option_id]
	current_segment_id = option.get("next", StringName())
	var execution = option.get("execution", null)
	if execution:
		run_execution(execution)
	return true

func find_first_valid_line(lines):
	for line in lines:
		var condition = line.get("condition", null)
		if not condition or is_condition_valid(condition):
			return line
	return null

func find_all_valid_options(options):
	var valid_options: Dictionary
	for i in range(options.size()):
		var option = options[i].duplicate()
		var hide_condition = option.get("hide_condition", null)
		if hide_condition and is_condition_valid(hide_condition):
			continue
		var lock_condition = option.get("lock_condition", null)
		if lock_condition and is_condition_valid(lock_condition):
			option["locked"] = true
		valid_options[i] = option
	return valid_options

func substitute_format_values(format_values):
	for key in format_values:
		var value = format_values[key]
		format_values[key] = run_expression(value)

func is_condition_valid(condition) -> bool:
	return true if run_expression(condition, true) else false

func run_execution(script):
	for execution in script.split(";", false):
		run_expression(execution)

func run_expression(script, only_run_const = false) -> Variant:
	var expression = Expression.new()
	var error = expression.parse(script, ["ctx"])
	if error != OK:
		push_error("Expression Parse Error: ", expression.get_error_text())
		return null
	var result = expression.execute([context_object], null, false, only_run_const)
	if expression.has_execute_failed():
		push_error("Expression Execution Error: ", expression.get_error_text())
		return null
	return result

func process_text(segment):
	segment["processed_text"] = tr(segment.text)

func start() -> bool:
	if is_active(): return false 
	current_segment_id = get_intial_segment_id()
	if not current_segment_id:
		push_error("Dialogue Error: failed to find intial segment ID for script \"", file_path, "\"")
		return false
	started.emit()
	progress_segment()
	return true

func end() -> bool:
	current_segment_id = StringName()
	ended.emit()
	return true

func execute_line(line: Variant):
	line_executed.emit(line)

func execute_options(options: Dictionary, line: Variant):
	options_executed.emit(options, line)

func advance():
	progress_segment()
	advanced.emit()

func advance_with_option(option_id: int):
	if select_option(option_id):
		progress_segment()
		advanced_with_option.emit(option_id)

func is_active() -> bool:
	return not current_segment_id.is_empty()

func get_intial_segment_id() -> StringName:
	var metadata = segments.get("dialogue_script", null) 
	return metadata.get("entry", "") if metadata else ""

func get_current_segment() -> Dictionary:
	return segments.get(current_segment_id, {})

static func get_segment_type(segment: Variant) -> DialogueScriptSegmentType:
	if "options" in segment: return DialogueScriptSegmentType.OPTION
	elif "lines" in segment: return DialogueScriptSegmentType.LINE
	return DialogueScriptSegmentType.UNKNOWN
