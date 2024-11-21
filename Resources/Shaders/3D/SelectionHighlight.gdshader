// Grupo Madaga - 2024
// VisualizationLabs - 2024
// Selection highlighting shader done on a secondary pass

shader_type spatial;
render_mode unshaded;

uniform vec4 overlayColor:source_color = vec4(240, 120, 0, 1);


void fragment() {
	ALBEDO = overlayColor.rgb;
	ALPHA = 0.7;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
