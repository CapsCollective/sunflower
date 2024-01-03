class_name DatatableEditorUtils

class FlagsEdit extends MenuButton:
	
	signal value_changed(value)
	
	var value: int
	var hint_string: String
	
	func _ready():
		var on_pressed = func(idx):
			var flags = hint_string.split(",")
			var flag = int(flags[idx])
			value = value & ~flag if value & flag else value | flag
			build_layout()
			value_changed.emit(value)
		get_popup().id_pressed.connect(on_pressed)
		build_layout()
	
	func build_layout():
		get_popup().clear()
		get_popup().hide_on_checkable_item_selection = false
		
		text = "Edit (%s)" % value
		var flags = hint_string.split(",")
		for i in range(0, flags.size()):
			var flag_details = flags[i].split(":")
			var is_set = value & int(flag_details[1])
			get_popup().add_check_item(flag_details[0], i)
			get_popup().set_item_checked(i, is_set)

class VectorEdit extends HBoxContainer:
	
	signal value_changed(value)
	
	const component_names = ["x", "y", "z", "w"]
	
	var vector: Variant
	
	func _ready():
		build_layout()
	
	func build_layout():
		for child in get_children():
			child.queue_free()
		for i in range(0, get_component_count()):
			add_child(build_component_label(i))
			add_child(build_component_spinbox(i))
	
	func build_component_label(idx):
		var panel_container = PanelContainer.new()
		var stylebox = get_theme_stylebox("label_bg", "EditorSpinSlider")
		panel_container.add_theme_stylebox_override("panel", stylebox)
		
		var comp_label = Label.new()
		var component_name = component_names[idx]
		comp_label.text = component_name
		var color = get_theme_color("property_color_" + component_name, "Editor")
		comp_label.add_theme_color_override("font_color", color)
		panel_container.add_child(comp_label)
		return panel_container
	
	func build_component_spinbox(idx):
		var internal_setter_callback = func(new_value):
			set_component_value(idx, new_value)
			build_layout()
			value_changed.emit(vector)
		var spinbox = SpinBox.new()
		spinbox.step = 0.001
		spinbox.allow_lesser = true
		spinbox.allow_greater = true
		spinbox.value = get_component_value(idx)
		spinbox.value_changed.connect(internal_setter_callback)
		return spinbox
	
	func get_component_count() -> int:
		match(typeof(vector)):
			TYPE_VECTOR2, TYPE_VECTOR2I:
				return 2
			TYPE_VECTOR3, TYPE_VECTOR3I:
				return 3
			TYPE_VECTOR4, TYPE_VECTOR4I:
				return 4
		return 0
	
	func get_component_value(idx):
		match(idx):
			0:
				return vector.x
			1:
				return vector.y
			2:
				return vector.z
			3:
				return vector.w
	
	func set_component_value(idx, value):
		match(idx):
			0:
				vector.x = value
			1:
				vector.y = value
			2:
				vector.z = value
			3:
				vector.w = value
