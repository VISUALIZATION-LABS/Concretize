extends Node
## A custom model parser with support for OBJ, GLTF and COLLADA files
##
## This script contains several callable functions that will take in the raw model string,
## parse it and then return an array containing ArrayMeshes.
##
## @experimental 

## The model file path
var model_path: String

# TODO: Make the generator a SINGLE function with some arguments that will be used
# to select how the parser will function, maybe even just automatically detect what the file is.

func generate_obj() -> IPMDL:
	
	# Setup variables
	
	# TODO: Make this return an array of array meshes to support multiple
	# objects
	
	
	var final_mesh:IPMDL = IPMDL.new()
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var current_object: String
	var vertices := PackedVector3Array()
	var vertex_normals := PackedVector3Array()
	var vertex_textures := PackedVector2Array()
	var materials := {}
	
	var use_mtl: bool = false
	var create_facegroup: bool = false
	var mtl_name: String
	
	# TODO: Optimize :D -F
	var lines: PackedStringArray = FileAccess.get_file_as_string(model_path).split("\n",false)
	
	
	
	if not model_path.is_empty():
		# .../folder/object.obj -> [.../folder/, object.obj] -> [object, obj]
		final_mesh.set_name(model_path.rsplit("/", false, 1)[1].rsplit(".", false, 1)[0])
	for line in lines:
		var parts = line.split(" ", false)
		match parts[0]:
			"#":
				# TODO: Store this in a comment array for future use
				pass
				
			"mtllib":
				print("Searching for material: " + parts[1])
				var mtllib: PackedStringArray = FileAccess.get_file_as_string(
					model_path.replace(model_path.rsplit("/", false, 1)[1], parts[1])).split("\n", false)
				
				var current_material: String
				
				# Ok yes, this is a very shitty implementation, it should probably
				# be moved to an mtllib_parse(mtllib) function, but this is a quick
				# and experimental implementation -F
				for mtl_line in mtllib:
					var mtl: PackedStringArray = mtl_line.split(" ", false)
					
					# TODO: Implement pbr extensions and the normal mtl params
					
					# Most mtl er, things will be ignored because I don't
					# know what to do with them! -F
					
					# IPMDL doesn't store material names...
					
					match mtl[0]:
						"newmtl":
							current_material = mtl[1]
							materials[current_material] = {
								"Ns": "250", 
								"Ka":["1","1","1"],
								"Kd":["0.8","0.8","0.8"]
								}
						"Ns":
							# Specular exponent
							pass
						"Ka":
							# Ambient color
							pass
						"Kd":
							# Diffuse color
							materials[current_material][mtl[0]] = mtl.slice(1)
						
						
			"o":
					current_object = parts[1]

					final_mesh.add_object(current_object)
			"v":
				vertices.append(Vector3(
					float(parts[1]),
					float(parts[2]),
					float(parts[3])
				))
			
			"vn":
				vertex_normals.append(Vector3(
					float(parts[1]),
					float(parts[2]),
					float(parts[3])
				))
			
			"vt":
				vertex_textures.append(Vector2(
					float(parts[1]),
					float(parts[2])
				))

			"usemtl":
				mtl_name = parts[1]
				print("Setting up materials for: " + mtl_name)
				if use_mtl:
					final_mesh.add_mesh(current_object, surface.commit())
					surface.clear()
					surface.begin(Mesh.PRIMITIVE_TRIANGLES)
				use_mtl = true
				

			"f":
				# Mesh assembler (maybe move to new func?)
				
				# TODO: Handle missing data (no normals or no VT)                          
				
				var f := parts.slice(1)
				
				# Assign "f" as a dict for InternalMesh
				
				# TODO: Implement vertex colours (kinda important...)
				
				
				#
				if use_mtl:
					var material: StandardMaterial3D = StandardMaterial3D.new()
					material.albedo_color = Color(
						float(materials[mtl_name]["Kd"][0]),
						float(materials[mtl_name]["Kd"][1]),
						float(materials[mtl_name]["Kd"][2])
						)
					
					#final_mesh.set_material(current_object, material)
					surface.set_material(material)
				
				if f.size() < 4:
					
					# Vertex 0
					surface.set_normal(vertex_normals[int(f[2].split("/", false)[2]) -1])
					
					surface.set_uv(vertex_textures[int(f[2].split("/", false)[1]) - 1])
					
					surface.add_vertex(vertices[int(f[2].split("/", false)[0]) -1])
					
					# Vertex 1
					surface.set_normal(vertex_normals[int(f[1].split("/", false)[2]) -1])
					
					surface.set_uv(vertex_textures[int(f[1].split("/", false)[1]) - 1])
					
					surface.add_vertex(vertices[int(f[1].split("/", false)[0]) -1])
					
					# Vertex 2	
					surface.set_normal(vertex_normals[int(f[0].split("/", false)[2]) -1])
					
					surface.set_uv(vertex_textures[int(f[0].split("/", false)[1]) - 1])
					
					surface.add_vertex(vertices[int(f[0].split("/", false)[0]) -1])
					
					
					
				else:
					
					 # Surface tool requires a built vertex array for the triangle fan,
					 # so now we need to walk through the array storing all of the
					 # v/vt/vn values
					
					var triangle_fan_vertices := PackedVector3Array()
					var triangle_fan_vertex_normals := PackedVector3Array()
					var triangle_fan_vertex_textures := PackedVector2Array()
					
					for face_group in f:
						triangle_fan_vertices.append(vertices[int(face_group.split("/", false)[0]) - 1])
						triangle_fan_vertex_normals.append(vertex_normals[int(face_group.split("/",false)[2]) - 1])
						triangle_fan_vertex_textures.append(vertex_textures[int(face_group.split("/",false)[1]) - 1])
					
					triangle_fan_vertices.reverse()
					triangle_fan_vertex_normals.reverse()
					triangle_fan_vertex_textures.reverse()
					
					surface.add_triangle_fan(
						triangle_fan_vertices, 
						triangle_fan_vertex_textures,
						PackedColorArray(),
						PackedVector2Array(),
						triangle_fan_vertex_normals)
					
					# TODO: Investigate if there is a better way to do this
					# Assigned to Felipe and Daniel
		if line == lines[lines.size() - 1]:
			final_mesh.add_mesh(current_object, surface.commit())
			surface.clear()
	return final_mesh
