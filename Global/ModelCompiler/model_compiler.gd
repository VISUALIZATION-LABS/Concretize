


extends Node

var _materials: Dictionary

class _material:
	var name: String
	var use_textures: bool = false
	var albedo_color: Color = Color(1,1,1)
	var albedo_texture: ImageTexture = null
	var normal_texture: ImageTexture = null
	var normal_strenght: float = 1.0
	var roughness_texture: ImageTexture = null
	var roughness: float = 0.5
	var metallic_texture: ImageTexture = null
	var metallic: float = 0
	var alpha: float = 0.0
	# If is not null then enable displacements
	var height_texture: ImageTexture = null


func compile_mesh() -> Node3D:
	var start_time = Time.get_unix_time_from_system()

	var thread_mtl_ldr: Thread
	var path: String = "C:/Users/Felipe/dev/tcc/program/TestFiles/Models/obj/MTLTEST/MaterialRoom/texturedNoPBR/mtlRoom.obj"
	var current_mesh: MeshInstance3D
	var current_material_group: StringName = &""
	var final_mesh_tree: Node3D = Node3D.new()
	var current_object: Node3D = null
	# OBJ
	var surface_tool:SurfaceTool = SurfaceTool.new()
	var vertices: PackedVector3Array = PackedVector3Array()
	var vertex_normals: PackedVector3Array = PackedVector3Array()
	var uv_coordinates: PackedVector2Array = PackedVector2Array()


	# THIS IS HERE FOR INITIAL DEBUG
	var obj_file:FileAccess = FileAccess.open(path,FileAccess.READ)

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Sequential read
	while obj_file.get_position() < obj_file.get_length():
		var current_line:PackedStringArray = obj_file.get_line().split(" ", false)
		current_mesh = MeshInstance3D.new()

		# Mesh should receive material name when those are implemented


		match current_line[0]:
			"#":
				print(current_line)
			"mtllib":
				thread_mtl_ldr = Thread.new()
				thread_mtl_ldr.start(_mtl_parse.bind(path.get_base_dir().path_join(current_line[1])))

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

			"o":
				current_object = Node3D.new()
				current_object.name = current_line[1]
				print("Created new object \"%s\"" % [current_object.name, ])
				final_mesh_tree.add_child(current_object)

			"usemtl":
				if thread_mtl_ldr.is_started():
					print("Waiting for material thread...")
					thread_mtl_ldr.wait_to_finish()

				if current_material_group:
					current_mesh.mesh = surface_tool.commit()
					current_object.add_child(current_mesh)

					surface_tool.clear()
					surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
					current_material_group = &""

				current_material_group = &"%s" % current_line[1]

				var material: StandardMaterial3D = StandardMaterial3D.new()

				material.albedo_color = _materials[current_line[1]].albedo_color
				material.roughness = _materials[current_line[1]].roughness
				material.metallic = _materials[current_line[1]].metallic

				# Texture loading

				if _materials[current_line[1]].use_textures:

					if _materials[current_line[1]].albedo_texture:
						material.albedo_texture = _materials[current_line[1]].albedo_texture


					if _materials[current_line[1]].roughness_texture:
						material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE
						material.roughness_texture = _materials[current_line[1]].roughness_texture
						material.roughness = 1.0


					if _materials[current_line[1]].metallic_texture:
						material.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE
						material.metallic_texture = _materials[current_line[1]].metallic_texture

					if _materials[current_line[1]].normal_texture:
						material.normal_enabled = true
						material.normal_texture = _materials[current_line[1]].normal_texture


				surface_tool.set_material(material)

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

	#final_mesh_tree.add_child(current_object)

	# TODO: Work on a better way to do this instead of commiting a leftover mesh section
	print("Finished %s" % current_material_group)

	current_mesh.mesh = surface_tool.commit()
	current_object.add_child(current_mesh)

	surface_tool.clear()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	current_material_group = &""

	print("Elapsed time %s" % str(Time.get_unix_time_from_system() - start_time))
	return final_mesh_tree

func _mtl_parse(mtl_path: String):
	print("Loading material at: %s" % mtl_path)

	var mtl_file:FileAccess = FileAccess.open(mtl_path,FileAccess.READ)
	var current_material: _material


	while mtl_file.get_position() < mtl_file.get_length():
		var mtl_line: PackedStringArray = mtl_file.get_line().split(" ", true)

		match mtl_line[0]:
			"newmtl":
				if current_material:
					_materials[current_material.name] = current_material
				current_material = _material.new()
				current_material.name = mtl_line[1]

			# NON PBR

			# Specular
			"Ns":
				current_material.roughness = float(mtl_line[1])

			# Ambient color
			"Ka":
				push_warning("Wavefront MTL \"Ka\" parameter is unused.")

			# Diffuse color
			"Kd":
				current_material.albedo_color = Color(
					float(mtl_line[1]),
					float(mtl_line[2]),
					float(mtl_line[3])
				)

			# Specular weight
			"Ks":
				var spec_exp: float = current_material.roughness
				var spec_col: float = float(mtl_line.slice(1)[0])

				var approx_rough: float = clampf(spec_exp/(1000*spec_col), 0.0, 1.0)
				current_material.roughness = approx_rough

				# FIXME: Approximation is not good enough, develop a new formula
				print("Approximating roughness for %s = %s" % [current_material.name, str(approx_rough)])

			# Alpha
			"d":
				current_material.alpha = float(mtl_line[1])

			# PBR

			# Roughness
			"Pr":
				current_material.roughness = float(mtl_line[1])

			# metallic
			"Pm":
				current_material.metallic = float(mtl_line[1])

			# Diffuse map
			"map_Kd":
				current_material.use_textures = true
				var diffuse_image = Image.new()
				var err: int = -1

				var image_path: String = ""
				# Prepare the path
				if mtl_line[1].is_absolute_path():
					image_path = mtl_line[1]
				else: if mtl_line[1].is_relative_path():
					image_path = mtl_path.get_base_dir().path_join(mtl_line[1])

				err = diffuse_image.load(image_path)

				if err != OK:
					push_error("Image at %s could not be loaded, textures won't be created." % image_path)

				diffuse_image.generate_mipmaps(true)

				var diffuse_texture = ImageTexture.create_from_image(diffuse_image)

				current_material.albedo_texture = diffuse_texture


			# Roughness
			"map_Ns", "map_Pr":
				current_material.use_textures = true
				var roughness_image = Image.new()
				var err: int = -1

				var image_path: String = ""
				# Prepare the path
				if mtl_line[1].is_absolute_path():
					image_path = mtl_line[1]
				else: if mtl_line[1].is_relative_path():
					image_path = mtl_path.get_base_dir().path_join(mtl_line[1])



				err = roughness_image.load(image_path)

				if err != OK:
					push_error("Image at %s could not be loaded, textures won't be created." % image_path)

				roughness_image.generate_mipmaps(true)

				var roughness_texture = ImageTexture.create_from_image(roughness_image)
				current_material.roughness_texture = roughness_texture

			# metallic
			"map_refl", "map_Pm":
				current_material.use_textures = true
				var metallic_image = Image.new()
				var err: int = -1

				var image_path: String = ""
				# Prepare the path
				if mtl_line[1].is_absolute_path():
					image_path = mtl_line[1]
				else: if mtl_line[1].is_relative_path():
					image_path = mtl_path.get_base_dir().path_join(mtl_line[1])



				err = metallic_image.load(image_path)

				if err != OK:
					push_error("Image at %s could not be loaded, textures won't be created." % image_path)

				metallic_image.generate_mipmaps(true)


				var metallic_texture = ImageTexture.create_from_image(metallic_image)
				current_material.metallic_texture = metallic_texture

			# Normal
			"map_Bump":
				current_material.use_textures = true
				var normal_image = Image.new()
				var err: int = -1
				var path_index: int = 1



				if mtl_line.find("-bm") > 0:
					path_index = 3
					current_material.normal_strenght = float(mtl_line[2])

				var image_path: String = ""
				# Prepare the path
				if mtl_line[path_index].is_absolute_path():
					image_path = mtl_line[path_index]
				else: if mtl_line[path_index].is_relative_path():
					image_path = mtl_path.get_base_dir().path_join(mtl_line[path_index])



				err = normal_image.load(image_path)

				if err != OK:
					push_error("Image at %s could not be loaded, textures won't be created." % image_path)

				normal_image.generate_mipmaps(true)
				normal_image.normal_map_to_xy()

				var normal_texture = ImageTexture.create_from_image(normal_image)
				current_material.normal_texture = normal_texture
	if current_material:
		_materials[current_material.name] = current_material
	print("Finished loading materials")

