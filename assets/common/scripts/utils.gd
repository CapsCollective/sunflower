class_name Utils

const VERSION_CONFIG_SETTING: String = "application/config/version"

static func push_info(arg1 = "", arg2 = "", arg3 = "", arg4 = "", arg5 = "", arg6 = "", arg7 = "", arg8 = ""):
	print(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)

static func log_info(category_name: String, arg1 = "", arg2 = "", arg3 = "", arg4 = "", arg5 = "", arg6 = "", arg7 = ""):
	push_info("LOG_INFO_" + category_name + ": ", arg1, arg2, arg3, arg4, arg5, arg6, arg7)
	
static func log_warn(category_name: String, arg1 = "", arg2 = "", arg3 = "", arg4 = "", arg5 = "", arg6 = "", arg7 = ""):
	push_warning("LOG_WARN_" + category_name + ": ", arg1, arg2, arg3, arg4, arg5, arg6, arg7)
	
static func log_error(category_name: String, arg1 = "", arg2 = "", arg3 = "", arg4 = "", arg5 = "", arg6 = "", arg7 = ""):
	push_error("LOG_ERROR_" + category_name + ": ", arg1, arg2, arg3, arg4, arg5, arg6, arg7)

static func get_version() -> String:
	return ProjectSettings.get_setting(VERSION_CONFIG_SETTING)

static func roll_dice(dice: Dictionary) -> Array:
	var rolls = []
	for tier in dice:
		for i in dice[tier]:
			rolls.append({
				"roll": randi_range(1, tier),
				"tier": tier
			})
	rolls.sort_custom(func(a, b):
		if (a.roll == b.roll):
			return a.tier < b.tier
		return a.roll > b.roll
	)
	return rolls

static func queue_free_children(node: Node):
	if not node: return
	for n in node.get_children():
		n.queue_free()

static func get_all_nodes_of_class(search_node: Node, classname: String):
	var found_nodes = Array()
	if search_node.is_class(classname):
		found_nodes.append(search_node)
	for child in search_node.get_children():
		found_nodes.append_array(get_all_nodes_of_class(child, classname))
	return found_nodes

static func get_all_nodes_with_script(search_node: Node, script: GDScript):
	var found_nodes = Array()
	if search_node.get_script() == script:
		found_nodes.append(search_node)
	for child in search_node.get_children():
		found_nodes.append_array(get_all_nodes_with_script(child, script))
	return found_nodes

static func get_first_node_with_script(search_node: Node, script: GDScript):
	var child_nodes = search_node.get_children()
	for child_node in child_nodes:
		if child_node.get_script() == script:
			return child_node
	for child_node in child_nodes:
		var found_node = get_first_node_with_script(child_node, script)
		if found_node:
			return found_node
	return null

static func get_perspective_collision_ray_point(ctx: Node3D, collide_with_areas: bool = false, mask: int = 1):
	var viewport: Viewport = ctx.get_viewport()
	var mouse_position: Vector2 = viewport.get_mouse_position()
	var camera: Camera3D = viewport.get_camera_3d()
	var origin: Vector3 = camera.project_ray_origin(mouse_position)
	var direction: Vector3 = camera.project_ray_normal(mouse_position)
	var end: Vector3 = origin + direction * camera.far
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = collide_with_areas
	query.collision_mask = mask
	var result := ctx.get_world_3d().direct_space_state.intersect_ray(query)
	return result.get("position", null)

static func convert_v2i_keys(dict_raw: Dictionary) -> Dictionary:
	var dict = {}
	for point_str in dict_raw:
		dict[str_to_var("Vector2i" + point_str)] = dict_raw[point_str]
	return dict

static func find_script_class_by_name(name: String) -> Dictionary:
	for class_details in ProjectSettings.get_global_class_list():
		if str(class_details.class) == name:
			return class_details
	return {}

static func instantiate_script_class_by_name(name: String) -> Object:
	var class_details = find_script_class_by_name(name)
	if class_details:
		var script_class = load(class_details.path)
		return script_class.new()
	return null

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
