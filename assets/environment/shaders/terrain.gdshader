shader_type spatial;

global uniform sampler2D grid_attributes;

uniform sampler2D cracked_texture;
uniform sampler2D radiation_texture;

uniform vec3 soil_light_color: source_color;
uniform vec3 soil_dark_color: source_color;

uniform vec3 radiation_color: source_color;

void fragment() {
	vec3 cracked = texture(cracked_texture, UV * 20.0).xyz;
	vec3 speck = texture(radiation_texture, UV).xyz;
	vec4 attributes = texture(grid_attributes, UV);
	vec3 nitrogen = mix(soil_light_color, soil_dark_color, attributes.y);
	ALBEDO = mix(nitrogen - (cracked * 0.05), nitrogen, attributes.r);

	vec3 radiation = mix(vec3(0, 0, 0), mix(vec3(0, 0, 0), radiation_color, attributes.z - 0.5), speck);
	if (radiation.g > 0.0) {
		EMISSION = vec3(0, smoothstep(0.05, 0.2, radiation.g), 0);
	}
}
