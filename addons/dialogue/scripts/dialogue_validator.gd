class_name DialogueValidator extends RefCounted

const valid_line_fields: Array[String] = [
	"speaker_id",
	"raw_text",
	"localised_text",
	"next",
	"data",
	"dev_comment",
	"condition",
	"execution",
]

const valid_option_fields : Array[String] = [
	"condition",
	"raw_text",
	"next",
	"data",
]

const valid_option_line_fields: Array[String] = [
	"speaker_id",
	"raw_text",
	"localised_text",
	"data",
	"dev_comment",
	"condition",
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
					if not validate_expression(condition):
						result = false
				var execution = line.get("execution", null)
				if execution:
					if not validate_expression(execution):
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
				var condition = option.get("condition", null)
				if condition:
					if not validate_expression(condition):
						result = false
			var lines = segment.get("lines", null)
			if lines:
				for line in lines:
					if not validate_field_names(line.keys(), valid_option_line_fields):
						result = false
					var condition = line.get("condition", null)
					if condition:
						if not validate_expression(condition):
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

static func validate_expression(script) -> bool:
	var expression = Expression.new()
	var error = expression.parse(script, ["ctx"])
	if error != OK:
		push_error("Dialogue Validation Error: bad expression \"", script, "\" with error ", expression.get_error_text())
		return false
	return true
