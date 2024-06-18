shader_type spatial;
render_mode unshaded;


uniform vec4 outline_color : source_color = vec4(0.2,0.8,0.0,1.0);
uniform float outline_thickness = 1.0;

// This shader should be rewritten in the future using a better method,
// while this works, it's not uniform with scaled meshes and also increases
// the rendered polygon amounts rendered (shouldn't be an issue with a selection outline though)

void vertex() {
	VERTEX *= -outline_thickness;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}

