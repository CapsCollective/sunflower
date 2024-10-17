class_name AttributeBar extends Control

const quality_gradient: Gradient = preload("res://assets/content/quality_gradient.tres")

@onready var label: Label = %AttributeLabel
@onready var gradient_texture: TextureRect = %AttributeGradient
@onready var marker: ColorRect = %AttributeMarker
var attribute: CropAttribute

func _ready():
	GameManager.cell_hovered.connect(on_hover_cell)

func on_hover_cell(cell: Vector2i):
	if attribute == null:
		return
	var score = GameManager.get_soil_attrs_for_current_zone().get(cell, {}).get(attribute.attribute, 0)
	marker.position.x = 200 * score

func set_attribute(attr: CropAttribute):
	attribute = attr
	label.text = GameManager.soil_attr_labels[attr.attribute]
	# Fix to clean gradient points
	var gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array()
	gradient.colors = PackedColorArray()
	# Map points from curve to gradient
	for i in attr.requirement.point_count:
		var point = attr.requirement.get_point_position(i)
		var color = quality_gradient.sample(point.y)
		gradient.add_point(point.x, color)
	gradient_texture.texture = gradient_texture.texture.duplicate()
	gradient_texture.texture.set_gradient(gradient)
