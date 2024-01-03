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
