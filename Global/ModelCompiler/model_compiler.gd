extends Node

class _material:
	var name: String
	var albedo_color: Color
	var albedo_texture: Texture3D
	var normal_texture: Texture3D
	var roughness_texture: Texture3D
	var metalness_texture: Texture3D
	
	# If is not null then enable displacements
	var height_texture: Texture3D


func compile_mesh() -> ArrayMesh:
	
	# OBJ
	var surface_tool:SurfaceTool = SurfaceTool.new()
	var vertices: PackedVector3Array = PackedVector3Array()
	var vertex_normals: PackedVector3Array = PackedVector3Array()
	var uv_coordinates: PackedVector2Array = PackedVector2Array()
	
	# THIS IS HERE FOR INITIAL DEBUG
	var obj_file:FileAccess = FileAccess.open("C:\\Users\\Felipe\\dev\\tcc\\program\\TestFiles\\ModelsV2\\Mesh_tests\\Text\\Text.obj",FileAccess.READ)
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Sequential read
	while obj_file.get_position() < obj_file.get_length():
		var current_line:PackedStringArray = obj_file.get_line().split(" ", false)
		
		match current_line[0]:
			"#":
				print(current_line)
			"v":
				vertices.append(Vector3(
					float(current_line[1]),
					float(current_line[2]),
					float(current_line[3])
				))
			"vn":
				vertex_normals.append(Vector3(
					float(current_line[1]),
					float(current_line[2]),
					float(current_line[3])
				))
			"vt":
				uv_coordinates.append(Vector2(
					float(current_line[1]),
					float(current_line[2])
				))
			"f":
				if current_line.size() < 4:
					
					# We need to convert our indices from counter-clockwise to clockwise
					# in this case we can just read it back-to-front
					
					for index in range(3, 0, -1):
						surface_tool.set_normal(
							vertex_normals[float(current_line[index].split("/", false)[2]) -1 ]
						)
						surface_tool.set_uv(
							uv_coordinates[float(current_line[index].split("/", false)[1]) -1 ]
						)
						surface_tool.add_vertex(
							vertices[float(current_line[index].split("/", false)[0]) -1 ]
						)
				else:
					
					# This is a bit more complicated, but still simple
					# we'll keep the first value of the index array put, and then
					# reverse the rest of the array
					
					# 1/1/1 2/2/2 3/3/3 4/4/4 5/5/5
					#            becomes
					# 1/1/1 5/5/5 4/4/4 3/3/3 2/2/2
					
					
					# Create a new array to store the indices (and then remove the "f" entry)
					var auxiliary_index_array:PackedStringArray = current_line
					auxiliary_index_array.remove_at(0)
					
					# Create a new array that'll store the correct winding order
					# then resize it so we can do faster operations with it.
					# Also assign the first index of the original array, since that won't change
					var index_array:PackedStringArray = PackedStringArray()
					index_array.resize(auxiliary_index_array.size())
					index_array[0] = auxiliary_index_array[0]
					
					# Remove the first index group and then reverse the whole array
					auxiliary_index_array.remove_at(0)
					auxiliary_index_array.reverse()
					
					# Finally, append the corrected array into the useable index array
					# and then clear the auxiliary index array
					
					for index in auxiliary_index_array.size():
						index_array[index+1] = auxiliary_index_array[index]
					
					auxiliary_index_array.clear()
					
					# Now we can create the meshes as triangle fans, and for that we need
					# properly built indices for every type of data we can possibly have
					
					var triangle_fan_vertices: PackedVector3Array = PackedVector3Array()
					triangle_fan_vertices.resize(index_array.size())
					
					var triangle_fan_vertex_normals: PackedVector3Array = PackedVector3Array()
					triangle_fan_vertex_normals.resize(index_array.size())
					
					var triangle_fan_uvs: PackedVector2Array = PackedVector2Array()
					triangle_fan_uvs.resize(index_array.size())
					
					for face_group_index in index_array.size():
						triangle_fan_vertices[face_group_index] = vertices[int(
							# "v/vt/vn" -> ["v"]
							index_array[face_group_index].split("/", false)[0]
							) -1 ]
						
						triangle_fan_uvs[face_group_index] = uv_coordinates[int(
							# "v/vt/vn" -> ["v"]
							index_array[face_group_index].split("/", false)[1]
							) -1 ]
							
						triangle_fan_vertex_normals[face_group_index] = vertex_normals[int(
							# "v/vt/vn" -> ["v"]
							index_array[face_group_index].split("/", false)[2]
							) -1 ]
					
					surface_tool.add_triangle_fan(
						triangle_fan_vertices,
						triangle_fan_uvs,
						PackedColorArray(),
						PackedVector2Array(),
						triangle_fan_vertex_normals
					)
		
	return surface_tool.commit()
