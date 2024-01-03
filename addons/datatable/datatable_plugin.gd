@tool
extends EditorPlugin

const DatatableEditor = preload("res://addons/datatable/scripts/datatable_editor.gd")
const DatatableInspectorPlugin = preload("res://addons/datatable/scripts/datatable_inspector_plugin.gd")

var dt_editor: DatatableEditor
var dt_inspector_plugin: DatatableInspectorPlugin

func _enter_tree():
	dt_editor = DatatableEditor.new()
	add_control_to_bottom_panel(dt_editor, "Datatable Editor")
	dt_inspector_plugin = DatatableInspectorPlugin.new()
	dt_inspector_plugin.datatable_inspected.connect(on_datatable_inspected)
	add_inspector_plugin(dt_inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(dt_inspector_plugin)
	remove_control_from_bottom_panel(dt_editor)
	dt_editor.queue_free()

func on_datatable_inspected(datatable: Datatable):
	dt_editor.set_current_datatable(datatable)
	make_bottom_panel_item_visible(dt_editor)
