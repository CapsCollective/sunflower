class_name Datatable extends Resource
## Keyed, schema-defined data structure resource for managing tabular data.
##
## Provides the ability to store tabular data in a way that is both keyed
## for quick runtime access, and schema-defined for correct access, utilising
## the [DatatableRow] resource.

## The key type that will be used by the datatable as [enum Variant.Type].
@export var key_type: Variant.Type = TYPE_NIL

## The default datatable row to use for each new row entry.
@export var default_row: DatatableRow

## The data of the datatable, stored by key-row.
@export var data: Dictionary

var _iterator_idx: int = 0

## Returns [code]true[/code] if the datatable is empty (its size is
## [code]0[/code]).
func is_empty() -> bool:
	return data.is_empty()

## Returns the number of rows in the datatable.
func size() -> int:
	return data.size()

## Returns [code]true[/code] if the datatable contains a row with the given key.
func has(key: Variant) -> bool:
	return data.has(key)

## Returns the key at a given index, or [code]null[/code] if it does not exist.
func get_key_by_index(idx: int) -> Variant:
	var keys = data.keys()
	if idx >= 0 and idx < keys.size():
		return keys[idx]
	push_warning("Non-existent index ", idx, " for datatable, out of bounds")
	return null

## Returns the corresponding row for a given key, or [code]null[/code] if it
## does not exist.
func get_row_by_index(idx: int) -> DatatableRow:
	var key = get_key_by_index(idx)
	return data[key] if key != null else null

## Returns the corresponding row pair for a given key, or [code]{}[/code] if it
## does not exist.
func get_row_pair_by_index(idx: int) -> Dictionary:
	var key = get_key_by_index(idx)
	return _create_row_pair(key, data[key]) if key != null else {}

## Returns the corresponding row for a given key, or [code]null[/code] if it
## does not exist.
func get_row(key: Variant) -> DatatableRow:
	return data.get(key)

## Returns the corresponding row pair for a given key, or [code]{}[/code] if it
## does not exist.
func get_row_pair(key: Variant) -> Dictionary:
	var value = data.find_key(key)
	if value != null:
		return _create_row_pair(key, value)
	push_warning("Failed to find key \"", key, "\" for datatable")
	return {}

## Replaces the key of a given row by key. Note that this operation does not
## guarentee stable ordering.
func move_row(old_key, new_key):
	var row_value = data.get(old_key)
	data.erase(old_key)
	data[new_key] = row_value

func _iter_init(arg):
	_iterator_idx = 0
	return _iterator_idx < size()

func _iter_next(arg):
	_iterator_idx += 1
	return _iterator_idx < size()

func _iter_get(arg) -> Dictionary:
	return get_row_pair_by_index(_iterator_idx)

func _create_row_pair(key: Variant, row: DatatableRow):
	return {"key": key, "value": data[key]}
