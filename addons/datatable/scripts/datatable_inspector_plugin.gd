extends EditorInspectorPlugin

signal datatable_inspected(datatable: Datatable)

func _can_handle(object):
	return object is Datatable

func _parse_begin(object):
	datatable_inspected.emit(object)
