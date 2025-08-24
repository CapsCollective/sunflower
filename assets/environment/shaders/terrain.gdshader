shader_type spatial;

global uniform sampler2D grid_attributes;
global uniform vec3 sun_dir;

uniform sampler2D cracked_texture;
uniform sampler2D radiation_texture;

uniform vec3 soil_light_color: source_color;
uniform vec3 soil_dark_color: source_color;

uniform vec3 radiation_color: source_color;

void vertex(){
	COLOR = vec4(1.0) * dot(NORMAL, vec3(0,1,0));
}

void fragment() {
	vec3 cracked = texture(cracked_texture, UV * 20.0).xyz;
	vec3 speck = texture(radiation_texture, UV).xyz;
	vec4 attributes = texture(grid_attributes, UV);
	vec3 nitrogen = mix(soil_light_color, soil_dark_color, attributes.r);
	ALBEDO = mix(nitrogen - (cracked * 0.05), nitrogen, attributes.b) * COLOR.rgb;

	vec3 radiation = mix(vec3(0, 0, 0), mix(vec3(0, 0, 0), radiation_color, attributes.g - 0.5), speck);
	if (radiation.g > 0.0 && attributes.a > 0.0) {
		EMISSION = mix(vec3(0, 0, 0), vec3(0, smoothstep(0.01, 0.2, radiation.g), 0), attributes.a);
	}

	vec3 world_norm = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float flatness = dot(vec3(0.0, 1.0, 0.0), world_norm);
	ALBEDO = mix(ALBEDO, vec3(0, 0, 0), min((1.0 - flatness) * 5.0, 0.9));
}

vec3 posterize(vec3 color, float steps){
	steps = 1.0/steps;
	vec3 col = floor(color / steps) * steps;
	return col;
}