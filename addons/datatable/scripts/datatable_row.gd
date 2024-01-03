class_name DatatableRow extends Resource
## Row schema definition for usage with [Datatable] resources.
##
## Serves as the schema definition base for the [Datatable] resource, where any
## exported members define its "columns".

## Returns the script level class name of the row type.
func get_name() -> String:
	return DatatableUtils.get_row_name(self)

## Returns an [Array] of script properties for each member of the row.
func get_properties() -> Array:
	return DatatableUtils.get_row_properties(self)

func _to_string() -> String:
	var props = get_properties()
	var display_str = "{"
	for prop in props:
		display_str += "%s: %s," % [prop.name, get(prop.name)]
	return display_str.trim_suffix(",") + "}"
