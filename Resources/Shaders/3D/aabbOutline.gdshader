shader_type spatial;
render_mode unshaded, cull_disabled;

// It would be ideal if we didn't have an edge in the middle of the quad
// but we don't have time to do R&D on shaders anymore...

// Thanks to Arnklit on Godot Shaders for publishing the base version
// of this on https://godotshaders.com/shader/wireframe-shader-godot-4-0/

uniform vec4 albedo : source_color = vec4(0.99, 0.693, 0, 0.063);
uniform vec4 wire_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float wire_width : hint_range(0.0, 40.0) = 0.0;
uniform float wire_smoothness : hint_range(0.0, 0.1) = 0.01;

varying vec3 barys;

void vertex() {
	int index = VERTEX_ID % 3;
	switch (index) {
		case 0:
			barys = vec3(1.0, 0.0, 0.0);
			break;
		case 1:
			barys = vec3(0.0, 1.0, 0.0);
			break;
		case 2:
			barys = vec3(0.0, 0.0, 1.0);
			break;
	}
}

void fragment() {
	vec3 deltas = fwidth(barys);
	vec3 barys_s = smoothstep(deltas * wire_width - wire_smoothness, deltas * wire_width + wire_smoothness, barys);
	float wires = min(barys_s.x, min(barys_s.y, barys_s.z));
	ALBEDO = mix(wire_color.rgba, albedo.rgba, wires).rgb;
	ALPHA =  mix(wire_color.rgba, albedo.rgba, wires).a;
}
