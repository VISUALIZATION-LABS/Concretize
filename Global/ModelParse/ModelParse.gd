extends MeshInstance3D
var obj: String

func generate_obj() -> Mesh:
	
	# Setup variables
	
	var final_mesh := ArrayMesh.new()
	
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vertices := PackedVector3Array([])
	var vertex_normals := PackedVector3Array([])
	var vertex_textures := PackedVector3Array([])
	var uvs := PackedVector2Array([])
	
	# Wouldn't this use a lot of memory?
	var vertex_index := PackedInt64Array()
	
	var lines: PackedStringArray = obj.split("\n", false)
	
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
				
				
				vertex_index.append(int(parts[1].split("/", false)[0]) -1)
				vertex_index.append(int(parts[2].split("/", false)[0]) -1)
				vertex_index.append(int(parts[3].split("/", false)[0]) -1)
				
	print("foo")
	for i in vertex_index.size():
		print(i)
		surface.add_vertex(vertices[i])
		surface.add_index(vertex_index[i])
	
	final_mesh = surface.commit(final_mesh)
	return final_mesh
