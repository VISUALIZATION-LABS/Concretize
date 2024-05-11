class_name ModelParse
## A custom model parser with support for OBJ, GLTF and COLLADA files
##
## This script contains several callable functions that will take in the raw model string,
## parse it and then return an array containing ArrayMeshes.
##
## @experimental 

## The model file path
var path: String:
	get:
		return path
	set(value):
		# Check if the value is an actual valid path
		if value.is_absolute_path() && value.rsplit("/", true, 1)[1].is_valid_filename():
			path = value
		else:
			push_error("Path is not valid")

# TODO: Make the generator a SINGLE function with some arguments that will be used
# to select how the parser will function, maybe even just automatically detect what the file is.

func compile_mesh() -> IPMDL:
	var extension = path.rsplit(".", true,1)[1]
	var final_mesh: IPMDL = IPMDL.new()
	
	match extension:
		# TODO: Basically rewrite so we can format the incoming OBJ into a standardized
		# POBJ format (obj is hard man)
		
		# FIXME: OBJ files are not read proper properly, leading to errors like [ISSUE]
		"obj":
			var time_start = Time.get_unix_time_from_system()
			
			# Face data
			
			var current_object: String
			var vertices := PackedVector3Array()
			var vertex_normals := PackedVector3Array()
			var vertex_textures := PackedVector2Array()
			
			# Material data
			
			var materials := {}
			var use_mtl: bool = false
			#var use_pbr_extensions: bool = false
			var mtl_name: String
			
			#var lines: PackedStringArray = FileAccess.get_file_as_string(model_path).split("\n",false)
			
			# Sequential read (takes a bit longer...)
			var lines = FileAccess.open(path, FileAccess.READ)
			
			var surface := SurfaceTool.new()
			surface.begin(Mesh.PRIMITIVE_TRIANGLES)
			
			if not path.is_empty():
				# .../folder/object.obj -> [.../folder/, object.obj] -> [object, obj]
				final_mesh.set_name(path.rsplit("/", false, 1)[1].rsplit(".", false, 1)[0])
			
			if lines != null:
				while lines.get_position() < lines.get_length():
					var line: String = lines.get_line()
					var parts = line.split(" ", false)
					
					
					# TODO: Add support for other (inferior) OBJ versions (cough cough 3ds max cough cough)
					match parts[0]:
						"#":
							# TODO: Store this in a comment array for future use
							pass
							
						"mtllib":
							print("Searching for material: " + parts[1])
							var mtllib: PackedStringArray = FileAccess.get_file_as_string(
								path.replace(path.rsplit("/", false, 1)[1], parts[1])).split("\n", false)
							
							var current_material: String
							
							for mtl_line in mtllib:
								var mtl: PackedStringArray = mtl_line.split(" ", false)
								
								# IPMDL doesn't store material names...
								# yet ;)
								match mtl[0]:
									"newmtl":
										current_material = mtl[1]
										materials[current_material] = {
											"Diffuse":[0.8,0.8,0.8],
											"Roughness": 0.5,
											"Metallic": 0.0,
											"Diffuse_map": null,
											"Roughness_map": null,
											"Metalness_map": null,
											"Normal_map": null,
											"Normal_strenght": 1.0,
											"_Ambient":["1","1","1"],
											"Alpha": 1.0
											}
									"Ns":
										# "Roughness" -> Specular exponent
										materials[current_material]["Roughness"] = float(mtl[1])
										pass
									"Ka":
										# Ambient color
										pass
									"Kd":
										# Diffuse color
										materials[current_material]["Diffuse"][0] = float(mtl[1])
										materials[current_material]["Diffuse"][1] = float(mtl[2])
										materials[current_material]["Diffuse"][2] = float(mtl[3])
									"Ks":
										# Specular wheight
										var specular_exponent: float = materials[current_material]["Roughness"]
										var specular_colour: float = float(mtl.slice(1)[0])
										
										# Sorta ok approximation?
										print("Approximated roughness for: " + current_material + " = " + str(clampf(specular_exponent/(1000*specular_colour), 0.0, 1.0)))
										materials[current_material]["Roughness"] = clampf(specular_exponent/(1000*specular_colour), 0.0, 1.0)
									"d":
										materials[current_material]["Alpha"] = float(mtl[1])
									
									# Textures
									"map_Kd":
										# Diffuse map
										var diffuse_image = Image.new()
										var err: int = -1
										
										if not mtl[1].is_absolute_path():
											var absolute_path = path.replace(path.rsplit("/", false, 1)[1], mtl[1])
											err = diffuse_image.load(absolute_path)
										else:
											err = diffuse_image.load(mtl[1])
										
										if err != OK:
											push_error("Image at " + mtl[1] + " could not be loaded, textures won't be created.")
											return
										
										diffuse_image.generate_mipmaps()
										
										var diffuse_texture = ImageTexture.create_from_image(diffuse_image)
										
										materials[current_material]["Diffuse_map"] = diffuse_texture
									
									"map_Ns", "map_Pr":
										# Roughness
										var roughness_image = Image.new()
										var err: int = -1
										
										if not mtl[1].is_absolute_path():
											var absolute_path = path.replace(path.rsplit("/", false, 1)[1], mtl[1])
											err = roughness_image.load(absolute_path)
										else:
											err = roughness_image.load(mtl[1])
										
										if err != OK:
											push_error("Image at " + mtl[1] + " could not be loaded, textures won't be created.")
											return
										
										roughness_image.generate_mipmaps()
										
										var roughness_texture = ImageTexture.create_from_image(roughness_image)
										
										materials[current_material]["Roughness_map"] = roughness_texture
									#
									"map_refl", "map_Pm":
										# Metalness
										var metalness_image = Image.new()
										var err: int = -1
										
										if not mtl[1].is_absolute_path():
											var absolute_path = path.replace(path.rsplit("/", false, 1)[1], mtl[1])
											err = metalness_image.load(absolute_path)
										else:
											err = metalness_image.load(mtl[1])
										if err != OK:
											push_error("Image at " + mtl[1] + " could not be loaded, textures won't be created.")
											return
										
										metalness_image.generate_mipmaps()
										
										var metalness_texture = ImageTexture.create_from_image(metalness_image)
										
										materials[current_material]["Metalness_map"] = metalness_texture
									
									"map_Bump":
										# Normal maps
										var normal_image = Image.new()
										var image_argument_index = 3
										
										materials[current_material]["Normal_strenght"] = float(mtl[2])
										
										if mtl[1] != "-bm":
											image_argument_index = 2
											materials[current_material]["Normal_strenght"] = 1.0
										
										var err: int = -1
										
										if not mtl[image_argument_index].is_absolute_path():
											var absolute_path = path.replace(path.rsplit("/", false, 1)[1], mtl[image_argument_index])
											err = normal_image.load(absolute_path)
										else:
											err = normal_image.load(mtl[image_argument_index])
										
										if err != OK:
											push_error("Image at " + mtl[image_argument_index] + " could not be loaded, textures won't be created.")
											return
										
										normal_image.generate_mipmaps(true)
										normal_image.normal_map_to_xy()
										
										var normal_texture = ImageTexture.create_from_image(normal_image)
										materials[current_material]["Normal_map"] = normal_texture
									
									
									# PBR
									
									"Pr":
										# Roughness
										#use_pbr_extensions = true
										materials[current_material]["Roughness"] = float(mtl[1])
									
									"Pm":
										# Metallic
										materials[current_material]["Metallic"] = float(mtl[1])
									
						
						"o":
								current_object = parts[1]
								final_mesh.add_object(current_object)
						
						"v":
							vertices.append(Vector3(
								float(parts[3]),
								float(parts[2]),
								float(parts[1])
							))
						
						"vn":
							vertex_normals.append(Vector3(
								float(parts[3]),
								float(parts[2]),
								float(parts[1])
							))
						
						"vt":
							vertex_textures.append(Vector2(
								float(parts[2]),
								float(parts[1])
							))
						
						"usemtl":
							# Ugly
							mtl_name = parts[1]
							print("Setting up materials for: " + mtl_name)
							
							if use_mtl:
								final_mesh.add_mesh(current_object, surface.commit())
								surface.clear()
								surface.begin(Mesh.PRIMITIVE_TRIANGLES)
								#surface.set_material(material)
							use_mtl = true
						
						"f":
							
							
							# TODO: Handle missing data (no normals or no VT)                          
							
							var f := parts.slice(1)
							
							# TODO: Implement vertex colours (kinda important...)
							
							# TODO: Refactor so this runs once per mtlgroup
							if use_mtl:
								var material: StandardMaterial3D = StandardMaterial3D.new()
								
								material.albedo_color = Color(
									materials[mtl_name]["Diffuse"][0],
									materials[mtl_name]["Diffuse"][1],
									materials[mtl_name]["Diffuse"][2],
									materials[mtl_name]["Alpha"] # Does nothing
									)
								
								# Doesn't work
								if materials[mtl_name]["Alpha"] < 1.0:
									material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
							
								material.roughness = materials[mtl_name]["Roughness"]
								material.metallic = materials[mtl_name]["Metallic"]
								
								if materials[mtl_name]["Diffuse_map"] != null:
									material.albedo_texture = materials[mtl_name]["Diffuse_map"]
								
								if materials[mtl_name]["Roughness_map"] != null:
									material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE
									material.roughness = 1.0 # Roughness material is multiplied by this value
									material.roughness_texture = materials[mtl_name]["Roughness_map"]
								#
								if materials[mtl_name]["Metalness_map"] != null:
									material.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE
									material.metallic = 1.0 # Metallic material is multiplied by this value
									material.metallic_texture = materials[mtl_name]["Metalness_map"]
								#
								if materials[mtl_name]["Normal_map"] != null:
									material.normal_enabled = true
									material.normal_scale = materials[mtl_name]["Normal_strenght"]
									material.normal_texture = materials[mtl_name]["Normal_map"]
								
								surface.set_material(material)
							
							if f.size() < 4:
								# Vertex 0
								surface.set_normal(vertex_normals[int(f[0].split("/", false)[2]) -1])
								
								surface.set_uv(vertex_textures[int(f[0].split("/", false)[1]) - 1])
								
								surface.add_vertex(vertices[int(f[0].split("/", false)[0]) -1])
								
								# Vertex 1
								surface.set_normal(vertex_normals[int(f[1].split("/", false)[2]) -1])
								
								surface.set_uv(vertex_textures[int(f[1].split("/", false)[1]) - 1])
								
								surface.add_vertex(vertices[int(f[1].split("/", false)[0]) -1])
								
								# Vertex 2	
								surface.set_normal(vertex_normals[int(f[2].split("/", false)[2]) -1])
								
								surface.set_uv(vertex_textures[int(f[2].split("/", false)[1]) - 1])
								
								surface.add_vertex(vertices[int(f[2].split("/", false)[0]) -1])
								
							else:
								
								 # Surface tool requires a built vertex array for the triangle fan,
								 # so now we need to walk through the array storing all of the
								 # v/vt/vn values
								
								var triangle_fan_vertices := PackedVector3Array()
								var triangle_fan_vertex_normals := PackedVector3Array()
								var triangle_fan_vertex_textures := PackedVector2Array()
								
								for face_group in f:
									triangle_fan_vertices.append(vertices[int(face_group.split("/", false)[0]) - 1])
									triangle_fan_vertex_textures.append(vertex_textures[int(face_group.split("/",false)[1]) - 1])
									triangle_fan_vertex_normals.append(vertex_normals[int(face_group.split("/",false)[2]) - 1])
								
								
								surface.add_triangle_fan(
									triangle_fan_vertices, 
									triangle_fan_vertex_textures,
									PackedColorArray(),
									PackedVector2Array(),
									triangle_fan_vertex_normals)
								
				# Finish up addign all meshes
				final_mesh.add_mesh(current_object, surface.commit())
				surface.clear()
			
			var time_elapsed = Time.get_unix_time_from_system() - time_start
			
			print("Elapsed time: " + str(time_elapsed))
			
			return final_mesh
		
		# Needs to be implemented differently from glb i think
		"gltf", "glb":
			var gltf_document_load = GLTFDocument.new()
			var gltf_state_load = GLTFState.new()
			var error = gltf_document_load.append_from_file(path, gltf_state_load)
			
			if not path.is_empty():
				# .../folder/object.obj -> [.../folder/, object.obj] -> [object, obj]
				final_mesh.set_name(path.rsplit("/", false, 1)[1].rsplit(".", false, 1)[0])
			
			
			if error == OK:
				var gltf_scene_root_node = gltf_document_load.generate_scene(gltf_state_load)
				var object = gltf_scene_root_node.get_children()
				
				# Will break if object starts as [Node3D] or has any children that are Node3D
				# Attempt to fix this by:
				#    Walking down the tree structure until a mesh is found
				#    Modifying IPMDL
				#    Writing custom GLTF parser
				# Attempt these solutions in order (best to worst case)
				for objects in object:
					print("Compiling " + object.name + " to IPMDL")
					final_mesh.add_object(object.name)
					final_mesh.add_mesh(object.name, object.mesh)
					final_mesh.set_position(object.name, object.position)
					
			
			return final_mesh
		
		# Returns an effectivelly "null" final mesh if no extensions are supported
		_: 
			assert(false, "No support for extension ." + extension + " found, halting.")
			return final_mesh
