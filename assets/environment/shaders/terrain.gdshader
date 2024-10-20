shader_type spatial;

global uniform sampler2D grid_attributes;

uniform sampler2D noise_cracked;
uniform sampler2D noise_speckled;

uniform vec3 soil_light_color: source_color;
uniform vec3 soil_dark_color: source_color;

uniform vec3 radiation_color: source_color;

void fragment() {
	vec3 cracked = texture(noise_cracked, UV*100.0).xyz;
	vec3 speck = texture(noise_speckled, UV).xyz;
	vec4 attributes = texture(grid_attributes, UV);
	vec3 nitrogen = mix(soil_light_color, soil_dark_color, attributes.y - 0.5);
	ALBEDO = mix(nitrogen, nitrogen * cracked.r, 1.0 - attributes.r);

	vec3 radiation = mix(vec3(0, 0, 0), mix(vec3(0, 0, 0), radiation_color, attributes.z - 0.5), speck);
	if (radiation.g > 0.0) {
		EMISSION = vec3(0, smoothstep(0.05, 1.0, radiation.g), 0);
	}
}
