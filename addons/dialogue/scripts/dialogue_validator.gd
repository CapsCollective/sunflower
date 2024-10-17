class_name DialogueValidator extends RefCounted

const valid_line_fields: Array[String] = [
	"condition",
	"speaker_id",
	"text",
	"formatting",
	"next",
	"data",
	"execution",
	"dev_comment",
]

const valid_option_fields : Array[String] = [
	"hide_condition",
	"lock_condition",
	"option_id",
	"text",
	"next",
	"data",
	"execution",
	"dev_comment",
]

const valid_option_line_fields: Array[String] = [
	"condition",
	"speaker_id",
	"text",
	"formatting",
	"data",
	"dev_comment",
]

static func validate_script(dialogue_script: DialogueScript) -> bool:
	var result = true
	for key in dialogue_script.segments:
		var segment = dialogue_script.segments[key]
		if not validate_segment(segment, dialogue_script):
			push_error("Dialogue Validation Error: found validation errors in segment \"", key, "\"")
			result = false
	if not result:
		push_error("Dialogue Validation Error: found validation errors in script \"", dialogue_script.file_path, "\"")
	return result

static func validate_segment(segment: Variant, dialogue_script: DialogueScript) -> bool:
	var result = true
	match(DialogueScript.get_segment_type(segment)):
		DialogueScript.DialogueScriptSegmentType.LINE:
			for line in segment.lines:
				if not validate_field_names(line.keys(), valid_line_fields):
					result = false
				if not validate_next(line, dialogue_script):
					result = false
				var condition = line.get("condition", null)
				if condition:
					if not validate_expression(condition, false):
						result = false
				var execution = line.get("execution", null)
				if execution:
					if not validate_expression(execution, true):
						result = false
				var formatting = line.get("formatting", null)
				if formatting:
					if not validate_formatting(formatting):
						result = false
			if segment.get("options", null):
				push_error("Dialogue Validation Error: found options field under line segment")
				result = false
		DialogueScript.DialogueScriptSegmentType.OPTION:
			for option in segment.options:
				if not validate_field_names(option.keys(), valid_option_fields):
					result = false
				if not validate_next(option, dialogue_script):
					result = false
				var hide_condition = option.get("hide_condition", null)
				if hide_condition:
					if not validate_expression(hide_condition, false):
						result = false
				var lock_condition = option.get("lock_condition", null)
				if lock_condition:
					if not validate_expression(lock_condition, false):
						result = false
				var execution = option.get("execution", null)
				if execution:
					if not validate_expression(execution, true):
						result = false
			var lines = segment.get("lines", null)
			if lines:
				for line in lines:
					if not validate_field_names(line.keys(), valid_option_line_fields):
						result = false
					var condition = line.get("condition", null)
					if condition:
						if not validate_expression(condition, false):
							result = false
					var formatting = line.get("formatting", null)
					if formatting:
						if not validate_formatting(formatting):
							result = false
		DialogueScript.DialogueScriptSegmentType.UNKNOWN:
			push_error("Dialogue Validation Error: found unknown segment type")
	return result

static func validate_next(segment_entry, dialogue_script: DialogueScript):
	var next_id = segment_entry.get("next", null)
	if next_id:
		var next = dialogue_script.segments.get(next_id, null)
		if not next:
			push_error("Dialogue Validation Error: failed to find next segment \"", next_id,"\"")
			return false
	return true

static func validate_field_names(field_names: Array, valid_names: Array) -> bool:
	var result = true
	for field in field_names:
		if not valid_names.has(field):
			push_error("Dialogue Validation Error: found invalid field \"", field,"\"")
			result = false
	return result

static func validate_expression(script, can_split) -> bool:
	var result = true
	for line in script.split(";", false) if can_split else [script]:
		var expression = Expression.new()
		var error = expression.parse(line, ["ctx"])
		if error != OK:
			push_error("Dialogue Validation Error: bad expression \"", script, "\" with error ", expression.get_error_text())
			result = false
	return result

static func validate_formatting(formatting) -> bool:
	if formatting is not Dictionary:
		push_error("Dialogue Validation Error: formatting is not a dictionary")
		return false
	var result: bool = true
	for key in formatting:
		var value = formatting[key]
		if value is not String and value is not int and value is not float and value is not bool:
			push_error("Dialogue Validation Error: formatting value \"", key, "\" is not a valid type")
			result = false
	return result
