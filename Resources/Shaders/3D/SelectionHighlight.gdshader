// Grupo Madaga - 2024
// VisualizationLabs - 2024
// Selection highlighting shader done on a secondary pass

shader_type spatial;
render_mode unshaded;

uniform vec4 backgroundColor: source_color;
uniform vec4 foregroundColor: source_color;

void fragment() {
	float verticalLines = floor(sin(SCREEN_UV.x * 0.0) + 1.8) + ceil(sin(SCREEN_UV.y * 000.0));
	float y = step(verticalLines, SCREEN_UV.x);

	if (y < 0.2) {
		ALBEDO = backgroundColor.rgb * 2.0;
	} else if (y > 0.9) {
		ALBEDO = foregroundColor.rgb * 2.0;
	}
	ALPHA = 0.5;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
