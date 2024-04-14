extends MeshInstance3D
var obj: String

# Parse an obj file and separate comments, vertices, normals, uvs, etc

# Adapted from Ezcha
# TODO: Proper MIT lisence credits
# https://github.com/Ezcha/gd-obj/blob/master/LICENSE
# F: I have finally found a good article on the file doc, should put this in
# LaTeX so it's more readable...

# TODO: Understand and also make it support materials
#       also do tests and stuff...


# F: I'm a dumbass and this doesn't work, Ezcha has failed me...
#    READ THE LATEX DOC!!!!

func generate_obj() -> Mesh:
	
	# Setup variables
	var mesh := ArrayMesh.new()
	var vertices := PackedVector3Array()
	var vertex_normals := PackedVector3Array()
	var vertex_textures := PackedVector3Array()
	var uvs := PackedVector2Array()
	
	# PackedVector3Array for now, but the 3.1 ref declares this as a list
	var faces := {"default":[]}
	
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
				#vertex_textures.append(Vector3(
					#float(parts[1]),
					#float(parts[2]),
					#float(parts[3])
				#))
				pass
			"f":
				# Whenever a face is declared in a OBJ file a few rules apply:
				#	1. A face element must have at least 3 vertices;
				#	2. A face element consists of three triplets (or more) of data;
				#	3. A face element must have consistent syntax.
				# Here are some examples of face elements:
				#	f v/vt/vn v/vt/vn v/vt/vn ...
				#	f v v v ...
				#	f v//vn v//vn v//vn ...
				var vertices_index := PackedStringArray()
				
				for map in parts.slice(1):
					vertices_index = map.split("/")
				
				
				
				# Full set of triplets
				if (parts.size() == 4):
					var face = {"v":[], "vt":[], "vn":[]}
					face["v"].append(int(vertices_index[0])-1)
					face["vt"].append(int(vertices_index[1])-1)
					
					if (vertices_index.size() > 2):
						face["vn"].append(int(vertices_index[2])-1)
				elif (parts.size() > 4):
					# We have to triangulate the model
					var points = []
					for i in vertices_index.size():
						# F: I have no idea what this does
						var point: PackedInt64Array = []
						point.append(int(vertices_index[0]) -1)
						point.append(int(vertices_index[1]) -1)
						if (vertices_index.size() > 2):
							point.append(int(vertices_index[2])-1)
						
						points.append(point)
						
					for i in points.size():
						if (i != 0):
							# F: Should face be defined earlier (avoid repetition)
							# TODO: Figure out how this works and optimize it
							var face = {"v":[], "vt":[], "vn":[]}
							var point0 = points[0]
							var point1 = points[i]
							var point2 = points[i-1]
							
							face["v"].append(point0[0])
							face["v"].append(point2[0])
							face["v"].append(point1[0])
							
							face["vt"].append(point0[1])
							face["vt"].append(point2[1])
							face["vt"].append(point1[1])
							
							if (point0.size() > 2):
								face["vn"].append(point0[2])
							if (point2.size() > 2):
								face["vn"].append(point2[2])
							if (point1.size() > 2):
								face["vn"].append(point1[2])
							
							faces["default"].append(face)
							
				var surface: SurfaceTool = SurfaceTool.new()
				
				surface.begin(Mesh.PRIMITIVE_TRIANGLES)
				print(faces)
				for face in faces["default"]:
					
					if (face["v"].size() == 3):
						
						var fan_v := PackedVector3Array()
						fan_v.append(vertices[face["v"][0]])
						fan_v.append(vertices[face["v"][2]])
						fan_v.append(vertices[face["v"][1]])
						
						var fan_vn := PackedVector3Array()
						if (face["vn"].size() > 0):
							fan_vn.append(vertices[face["vn"][0]])
							fan_vn.append(vertices[face["vn"][2]])
							fan_vn.append(vertices[face["vn"][1]])
							
						#var fan_vt := PackedVector2Array()
						#if (face["vt"].size() > 0):
							#for k in [0,2,1]:
								#var f = face["vt"][k]
								#if (f > -1):
									#var uv = uvs[f]
						surface.add_triangle_fan(
							fan_v, # Vertices
							PackedVector2Array(),  # Texture vertex
							PackedColorArray(), # Vertex colors
							PackedVector2Array(), # Texture vertex 2
							fan_vn, # Vertex normals
							[] # Tangents
						)
				
				mesh = surface.commit(mesh)
				
	return mesh
