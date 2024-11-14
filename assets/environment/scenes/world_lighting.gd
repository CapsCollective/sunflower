extends WorldEnvironment

const lighting_gradient: Texture2D = preload("res://assets/environment/textures/tod_lighting_gradient.png")

@onready var base_background_colour: Color = environment.background_color

func _ready() -> void:
	GameManager.time_incremented.connect(on_time_incremented)
	var colour: Color = get_lighting_colour_for_current_time()
	set_lighting_colour(colour, true)

func on_time_incremented():
	var colour: Color = get_lighting_colour_for_current_time()
	set_lighting_colour(colour)

func get_lighting_colour_for_current_time() -> Color:
	var day_progress: float = GameManager.get_hour_of_day() / 24.0
	var width: int = lighting_gradient.get_image().get_width()
	return lighting_gradient.get_image().get_pixel(width * day_progress, 0)

func set_lighting_colour(colour: Color, direct: bool = false):
	if (direct):
		$DirectionalLight3D.light_color = colour
		environment.background_color = base_background_colour * colour
	else:
		var tween = create_tween()
		tween.parallel().tween_property($DirectionalLight3D, "light_color", colour, 1.0)
		tween.parallel().tween_property(environment, "background_color", base_background_colour * colour, 1.0)
