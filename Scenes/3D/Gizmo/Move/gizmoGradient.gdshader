shader_type spatial;
render_mode unshaded;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 yColor = vec3(1,0,0);
	vec3 xColor = vec3(0,0,1);
	
	float rotationAmount = 2.35619;
	
	float rotX = rotationAmount;
	float rotY = rotationAmount;
	
	mat2 rotationMatrix = mat2(
		vec2(cos(rotX), sin(-rotX)),
		vec2(sin(rotY), cos(rotX))
		);
	
	vec2 rotatedUv = (UV - 0.9) * rotationMatrix;
	
	vec3 finalColor = (xColor * smoothstep(1.,-1, rotatedUv.x)) + (yColor * smoothstep(1,-1,  rotatedUv.y));
	
	ALBEDO = finalColor;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
