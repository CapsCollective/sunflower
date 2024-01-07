@tool
extends EditorPlugin

var terrain_gizmo_plugin = preload("res://addons/terrain/scripts/terrain_gizmo_plugin.gd").new()
var terrain_menu: Control

func _enter_tree():
	var terrain_icon = get_editor_interface().get_editor_main_screen().get_theme_icon("GPUParticlesCollisionSDF3D", "EditorIcons")
	add_custom_type("Terrain", "StaticBody3D", preload("res://addons/terrain/scripts/terrain.gd"), terrain_icon)
	terrain_menu = preload("res://addons/terrain/scripts/terrain_editor_menu.gd").new()
	get_editor_interface().get_selection().selection_changed.connect(on_selection_changed)
	add_node_3d_gizmo_plugin(terrain_gizmo_plugin)

func _exit_tree():
	remove_node_3d_gizmo_plugin(terrain_gizmo_plugin)
	terrain_menu.queue_free()
	remove_custom_type("Terrain")

func on_selection_changed():
	var selected_node = get_selected_node()
	if selected_node and selected_node is Terrain:
		terrain_menu.set_current_terrain(selected_node)
		add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, terrain_menu)
		return
	if terrain_menu.is_inside_tree():
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, terrain_menu)

func get_selected_node() -> Node:
	var selection = get_editor_interface().get_selection()
	var selected: Array = selection.get_selected_nodes()
	return null if selected.is_empty() else selected[0]
