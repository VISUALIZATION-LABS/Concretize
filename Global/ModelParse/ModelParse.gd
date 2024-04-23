extends MeshInstance3D
## A custom model parser with support for OBJ, GLTF, FBX and COLLADA files
##
## This script contains several callable functions that will take in the raw model string,
## parse it and then return an array containing ArrayMeshes.
##
## @experimental 


# TODO: Rename this so it's just a generic "file" type
## The model File
var obj: String

# TODO: Make the generator a SINGLE function with some arguments that will be used
# to select how the parser will function, maybe even just automatically detect what the file is.

func generate_obj() -> ArrayMesh:
	
	# Setup variables
	
	# TODO: Make this return an array of array meshes to support multiple
	# objects
	
	var final_mesh := ArrayMesh.new()
	
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vertices := PackedVector3Array([])
	var vertex_normals := PackedVector3Array([])
	var vertex_textures := PackedVector3Array([])
	var uvs := PackedVector2Array([])
	var _vertex_index := PackedInt32Array()
	
	var lines: PackedStringArray = obj.split("\n", false);
	
	# TODO: Big restructure to support mtllib sections
	
	for line in lines:
		var parts = line.split(" ", false)
		match parts[0]:
			"#":
				# TODO: Store this in a comment array for future use
				pass
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
				# Worry about UVs later please for the love of my sanity
				#vertex_textures.append(Vector3(
					#float(parts[1]),
					#float(parts[2]),
					#float(parts[3])
				#))
				pass
			"f":
				# Mesh assembler (maybe move to new func?)
				
				# TODO: Handle missing data (no normals or no VT)
				
				# OBJ and Godot have different winding orders. While OBJ is Anti-clockwise
				# Godot is clockwise, so we have to convert the array like this:          
				#                                                                         
				# original_array[{0,1,1}, {1,3.40,2}, {4,2,5.2}]                          
				#                   │         │           │                               
				#                 ┌─┼─────────┼───────────┘                               
				#                 │ │         │                                           
				#                 │ └─────────┼─────────────┐                             
				#                 │           │             │                             
				#                 └───┐       └──┐          │                             
				#                     ▼          ▼          ▼                             
				# reordered_array[{4,2,5.2}, {1,3.40,2}, {0,1,1}]                         
				#
				# This is basically just an array inversion
				#
				# This has to be done with every set of triangles                                    
				
				var f := parts.slice(1)
				
				# Remember that OBJ faces are structured like this:
				# f v/vt/vn ... (minimum is 3)
				
				if f.size() < 4:
					
					# Vertex 0
					surface.set_normal(vertex_normals[int(f[2].split("/", false)[2]) -1])
					
					surface.add_vertex(vertices[int(f[2].split("/", false)[0]) -1])
					
					# Vertex 1
					surface.set_normal(vertex_normals[int(f[1].split("/", false)[2]) -1])
					
					surface.add_vertex(vertices[int(f[1].split("/", false)[0]) -1])
					
					# Vertex 2	
					surface.set_normal(vertex_normals[int(f[0].split("/", false)[2]) -1])
					
					surface.add_vertex(vertices[int(f[0].split("/", false)[0]) -1])
					
				else:
					
					# Surface tool requires a built vertex array for the triangle fan,
					# so now we need to walk through the array storing all of the
					# f[1] values
					
					var triangle_fan_vertices := PackedVector3Array()
					var triangle_fan_vertex_normals := PackedVector3Array()
					
					for face_group in f:
						# TODO: Implement UVS
						triangle_fan_vertices.append(vertices[int(face_group.split("/", false)[0]) - 1])
						triangle_fan_vertex_normals.append(vertex_normals[int(face_group.split("/",false)[2]) - 1])
					
					triangle_fan_vertices.reverse()
					triangle_fan_vertex_normals.reverse()
					
					surface.add_triangle_fan(
						triangle_fan_vertices, 
						PackedVector2Array(),
						PackedColorArray(),
						PackedVector2Array(),
						triangle_fan_vertex_normals)

	final_mesh = surface.commit()
	return final_mesh
