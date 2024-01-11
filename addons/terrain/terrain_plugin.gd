@tool
extends EditorPlugin

var terrain_gizmo_plugin = preload("res://addons/terrain/scripts/terrain_gizmo_plugin.gd").new(self)
var terrain_menu: Control
var terrain_side_bar: Control

func _enter_tree():
	var terrain_icon = get_editor_interface().get_editor_main_screen().get_theme_icon("GPUParticlesCollisionSDF3D", "EditorIcons")
	add_custom_type("Terrain", "StaticBody3D", preload("res://addons/terrain/scripts/terrain.gd"), terrain_icon)
	terrain_menu = preload("res://addons/terrain/scripts/terrain_editor_menu.gd").new()
	terrain_side_bar = preload("res://addons/terrain/scripts/terrain_editor_side_bar.gd").new()
	get_editor_interface().get_selection().selection_changed.connect(on_selection_changed)
	add_node_3d_gizmo_plugin(terrain_gizmo_plugin)

func _exit_tree():
	remove_node_3d_gizmo_plugin(terrain_gizmo_plugin)
	terrain_menu.queue_free()
	terrain_side_bar.queue_free()
	remove_custom_type("Terrain")

func on_selection_changed():
	var selected_node = get_selected_node()
	if selected_node and selected_node is Terrain:
		terrain_menu.set_current_terrain(selected_node)
		terrain_side_bar.set_current_terrain(selected_node)
		add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, terrain_menu)
		add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, terrain_side_bar)
		terrain_side_bar.refresh()
		return
	if terrain_menu.is_inside_tree():
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, terrain_menu)
		terrain_menu.set_current_terrain(null)
	if terrain_side_bar.is_inside_tree():
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, terrain_side_bar)
		terrain_side_bar.set_current_terrain(null)

func get_selected_node() -> Node:
	var selection = get_editor_interface().get_selection()
	var selected: Array = selection.get_selected_nodes()
	return null if selected.is_empty() else selected[0]
