shader_type spatial;
render_mode blend_mix,diffuse_burley,specular_schlick_ggx, unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 0.0);


void vertex() {
	// Called for every vertex the material is visible on.
}

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}
void fragment() {
	vec3 world_normal =  (INV_VIEW_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	
	float fresnel = fresnel(1.0, NORMAL, VIEW);
	
	vec4 alpha = vec4(1.0);
	alpha = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	ALBEDO = alpha.rgb * albedo.rgb;
	
	ROUGHNESS = 1.0 - clamp(fresnel, 0.75, 0.9);
	ALPHA = 0.9;
}