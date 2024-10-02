// Grupo Madaga - 2024
// VisualizationLabs - 2024
// GUI acrylic shader using cheap LOD blurring

shader_type canvas_item;


uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform vec4 color: source_color = vec4(0.5,0.5,0.5,255);
uniform float blur_amount = 3.0;


void fragment() {
	vec4 screen_texture_blurred = textureLod(SCREEN_TEXTURE, SCREEN_UV, 6.5);

	//COLOR = vec4(vec3(n) / 3.0, 1.0);
	COLOR = vec4(screen_texture_blurred.rgb, 1.0) * color;
	//COLOR = vec4(0.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
