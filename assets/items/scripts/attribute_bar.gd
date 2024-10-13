class_name AttributeBar extends Control

const quality_gradient: Gradient = preload("res://assets/content/quality_gradient.tres")

@onready var label: Label = %AttributeLabel
@onready var gradient_texture: TextureRect = %AttributeGradient
@onready var marker: ColorRect = %AttributeMarker

func set_attribute(cell, attr):
	var gradient = Gradient.new()
	# Fix to clean gradient points
	gradient.offsets = PackedFloat32Array()
	gradient.colors = PackedColorArray()
	label.text = GameManager.soil_attr_labels[attr.attribute]
	marker.position.x = 200 * GameManager.get_soil_attrs_for_current_zone()[cell][attr.attribute]
	for i in attr.requirement.point_count:
		var point = attr.requirement.get_point_position(i)
		var color = quality_gradient.sample(point.y)
		gradient.add_point(point.x, color)
	print(gradient.offsets, gradient.colors)
	gradient_texture.texture = gradient_texture.texture.duplicate()
	gradient_texture.texture.set_gradient(gradient)
