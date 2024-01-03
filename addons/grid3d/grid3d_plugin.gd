@tool
extends EditorPlugin

var grid3d_gizmo_plugin = preload("res://addons/grid3d/scripts/grid3d_gizmo_plugin.gd").new()

func _enter_tree():
	var grid_3d_icon = get_editor_interface().get_editor_main_screen().get_theme_icon("RootMotionView", "EditorIcons")
	add_custom_type("Grid3D", "Node3D", preload("res://addons/grid3d/scripts/grid3d.gd"), grid_3d_icon)
	add_node_3d_gizmo_plugin(grid3d_gizmo_plugin)

func _exit_tree():
	remove_node_3d_gizmo_plugin(grid3d_gizmo_plugin)
	remove_custom_type("Grid3D")
