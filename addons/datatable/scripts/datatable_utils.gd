class_name DatatableUtils
## Static utility functions for use with the [Datatable] resource.
##
## Contains static functions useful for operating the [Datatable] and
## [DatatableRow] resources, mirroring or containing many functions of the class
## itself, in order to allow for thier execution outside of runtime.

## Returns the script level class name for the type of a given row.
static func get_row_name(row: DatatableRow) -> String:
	var source = row.get_script().source_code
	var regex = RegEx.create_from_string("class_name ([A-z0-9]*)")
	var result = regex.search(source)
	return result.get_string(1) if result else "Unknown"

## Returns an [Array] of script properties for each member of a given row.
static func get_row_properties(row: DatatableRow) -> Array:
	var row_props: Array = []
	var prop_list = row.get_script().get_script_property_list()
	for prop in prop_list:
		if prop.type != TYPE_NIL:
			row_props.append(prop)
	return row_props

## Returns the type properties from hint string
static func get_properties_by_hint_string(hint_string: String) -> Dictionary:
	# PROPERTY_HINT_TYPE_STRING
	# hint_string = "%d:" % [elem_type]
	# hint_string = "%d/%d:%s" % [elem_type, elem_hint, elem_hint_string]
	var item_identifier = hint_string.split(":")[0]
	var properties = { 'type': 0, 'hint': 0, 'hint_string': hint_string.split(":")[1] }
	if (item_identifier.contains("/")):
		properties.type = int(item_identifier.split("/")[0])
		properties.hint = int(item_identifier.split("/")[1])
	else:
		properties.type = int(item_identifier)
	return properties

## Replaces the key of a given row by key, preserving stable ordering in the
## process. Note that in general the [Datatable] resource does not guarantee
## order, and this operation is slow and should be avoided at runtime.
static func move_row_stable(datatable: Datatable, old_key, new_key):
	var new_data = Dictionary()
	var all_keys = datatable.data.keys()
	var all_values = datatable.data.values()
	var key_idx = all_keys.find(old_key)
	
	for i in range(0, all_keys.size()):
		if i != key_idx:
			new_data[all_keys[i]] = all_values[i]
		else:
			new_data[new_key] = all_values[i]
	datatable.data = new_data

## Returns [code]true[/code] if all keys are of the correct type for a given
## datatable, [code]false[/code] otherwise, generating an error specifying the
## first offending row and its particular issue.
static func validate_datatable_keys(datatable: Datatable) -> bool:
	var default_props = get_row_properties(datatable.default_row)
	for key in datatable.data.keys():
		if typeof(key) != datatable.key_type:
			push_error("Found bad key ", key, "type should be ", datatable.key_type, " got ", typeof(key))
			return false
	return true
