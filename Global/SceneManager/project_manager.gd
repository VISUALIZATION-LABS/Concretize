extends Node

func _load_image_from_disk(path: String, is_normal: bool = false) -> ImageTexture:
	var image: Image = Image.new()
	image.load(path)
	
	if is_normal:
		image.generate_mipmaps(true)
		image.normal_map_to_xy()
	else:
		image.generate_mipmaps(false)

	
	return ImageTexture.create_from_image(image)

func _string_color_to_color(color: String) -> Color:
	var final_color: Color = Color.WHITE
	
	var color_groups: PackedStringArray = color.trim_prefix("(").trim_suffix(")").split(", ")
	
	final_color = Color(
		color_groups[0].to_float(),
		color_groups[1].to_float(),
		color_groups[2].to_float(),
		color_groups[3].to_float(),
	)
	
	return final_color

func _string_array_to_vector_3_array(array: String) -> PackedVector3Array:
	var packed_vec3_array: PackedVector3Array = []
	
	var number_groups: PackedStringArray = array.trim_prefix("[(").trim_suffix(")]").split("), (")
	
	for number_group: String in number_groups:
		var split_number_group: PackedStringArray = number_group.split(", ")
		
		var translated_vector3: Vector3 = Vector3(
			split_number_group[0].to_float(),
			split_number_group[1].to_float(),
			split_number_group[2].to_float()
		)
		
		packed_vec3_array.append(translated_vector3)
	
	return packed_vec3_array

func _string_array_to_vector_2_array(array: String) -> PackedVector2Array:
	var packed_vec2_array: PackedVector2Array = []
	
	var number_groups: PackedStringArray = array.trim_prefix("[(").trim_suffix(")]").split("), (")
	
	for number_group: String in number_groups:
		var split_number_group: PackedStringArray = number_group.split(", ")
		
		var translated_vector3: Vector2 = Vector2(
			split_number_group[0].to_float(),
			split_number_group[1].to_float(),
		)
		
		packed_vec2_array.append(translated_vector3)
	
	return packed_vec2_array

func load_project(path: String) -> void:
	await SceneManager.change_scene(preload("res://Scenes/3D/MainScene/main_scene.tscn"))
	
	if not FileAccess.file_exists(path):
		return
	
	
	var save_file = FileAccess.open(path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var data = json.data
	
		print("Project name: ", data.project_name)
		print("Project author: ", data.author)

		#print(data)

		for data_object: Dictionary in data.project_data:
			for data_key: String in data_object:
				match data_key:
					"DirectionalLight3D":
						var directional_light: DirectionalLight = DirectionalLight.new()
						SceneManager.scene_tree.current_scene.add_child(directional_light)
						directional_light.name = data_object[data_key].name
						
						directional_light.position.x = data_object[data_key].transform.position.x
						directional_light.position.y = data_object[data_key].transform.position.y
						directional_light.position.z = data_object[data_key].transform.position.z
						
						
						directional_light.rotation.x = data_object[data_key].transform.rotation.x
						directional_light.rotation.y = data_object[data_key].transform.rotation.y
						directional_light.rotation.z = data_object[data_key].transform.rotation.z
						
						directional_light.light_energy = data_object[data_key].light_data.energy
						directional_light.light_color = _string_color_to_color(data_object[data_key].light_data.color)
						directional_light.shadow_blur = data_object[data_key].light_data.shadow_blur
						
						print(SceneManager.scene_tree.current_scene)
					
					"SpotLight3D":
						var spot_light: SpotLight = SpotLight.new()
						SceneManager.scene_tree.current_scene.add_child(spot_light)
						
						spot_light.name = data_object[data_key].name
						
						spot_light.position.x = data_object[data_key].transform.position.x
						spot_light.position.y = data_object[data_key].transform.position.y
						spot_light.position.z = data_object[data_key].transform.position.z
						
						spot_light.rotation.x = data_object[data_key].transform.rotation.x
						spot_light.rotation.y = data_object[data_key].transform.rotation.y
						spot_light.rotation.z = data_object[data_key].transform.rotation.z
						
						
						spot_light.light_color = _string_color_to_color(data_object[data_key].light_data.color)
						spot_light.light_energy = data_object[data_key].light_data.energy
						spot_light.spot_range = data_object[data_key].light_data.range
						spot_light.spot_attenuation = data_object[data_key].light_data.attenuation
						spot_light.spot_angle = data_object[data_key].light_data.angle
						spot_light.shadow_blur = data_object[data_key].light_data.shadow_blur
						
					"ImportedMesh":
						var head_node: Node3D = Node3D.new()
						
						
						for mesh_key: String in data_object[data_key]:
							if mesh_key.begins_with("mesh_"):
								
								var mesh_data: PackedInt32Array = []
								
								var mesh_data_string: Array = data_object[data_key][mesh_key].mesh_data
								

								var mesh_instance: MeshInstance3D = MeshInstance3D.new()
								var array_mesh: ArrayMesh = ArrayMesh.new()
								var surface_array_index: int = -1
								
								for surface: Array in mesh_data_string:
									surface_array_index += 1
									var surface_array: Array = []
									surface_array.resize(Mesh.ARRAY_MAX)
									
									surface_array[Mesh.ARRAY_VERTEX] = _string_array_to_vector_3_array(surface[Mesh.ARRAY_VERTEX])
									surface_array[Mesh.ARRAY_NORMAL] = _string_array_to_vector_3_array(surface[Mesh.ARRAY_NORMAL])
									surface_array[Mesh.ARRAY_TANGENT] = PackedFloat32Array(surface[Mesh.ARRAY_TANGENT])
									surface_array[Mesh.ARRAY_TEX_UV] = _string_array_to_vector_2_array(surface[Mesh.ARRAY_TEX_UV])
									
									array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
									
									var material: StandardMaterial3D = StandardMaterial3D.new()
									
									if data_object[data_key][mesh_key].material_data[surface_array_index].albedo_texture_path != null:
										material.albedo_texture = _load_image_from_disk(path.get_base_dir() + data_object[data_key][mesh_key].material_data[surface_array_index].albedo_texture_path.trim_prefix("."))
									
									
									material.roughness = data_object[data_key][mesh_key].material_data[surface_array_index].roughness
									
									if data_object[data_key][mesh_key].material_data[surface_array_index].roughness_texture_path != null:
										material.roughness_texture = _load_image_from_disk(path.get_base_dir() + data_object[data_key][mesh_key].material_data[surface_array_index].roughness_texture_path.trim_prefix("."))
									
									if data_object[data_key][mesh_key].material_data[surface_array_index].normal_texture_path != null:
										material.normal_texture = _load_image_from_disk(path.get_base_dir() + data_object[data_key][mesh_key].material_data[surface_array_index].normal_texture_path.trim_prefix("."), true)
									
									
									array_mesh.surface_set_material(surface_array_index, material)
								
								
								
								mesh_instance.mesh = array_mesh
								mesh_instance.name = mesh_key.trim_prefix("mesh_")
								
								mesh_instance.create_trimesh_collision()
								mesh_instance.get_child(0).name = "_collision"
								
								
								
								if data_object[data_key].name != head_node.name:
									head_node = Node3D.new()
									head_node.name = data_object[data_key].name
								
								head_node.set_meta("ImportedMesh", 1)
								head_node.add_child(mesh_instance)
								
								mesh_instance.position.x = data_object[data_key][mesh_key].transform.position.x
								mesh_instance.position.y = data_object[data_key][mesh_key].transform.position.y
								mesh_instance.position.z = data_object[data_key][mesh_key].transform.position.z
								
								mesh_instance.rotation.x = data_object[data_key][mesh_key].transform.rotation.x
								mesh_instance.rotation.y = data_object[data_key][mesh_key].transform.rotation.y
								mesh_instance.rotation.z = data_object[data_key][mesh_key].transform.rotation.z
								
								mesh_instance.scale.x = data_object[data_key][mesh_key].transform.scale.x
								mesh_instance.scale.y = data_object[data_key][mesh_key].transform.scale.y
								mesh_instance.scale.z = data_object[data_key][mesh_key].transform.scale.z
								
								
								
								head_node.position.x = data_object[data_key].transform.position.x
								head_node.position.y = data_object[data_key].transform.position.y
								head_node.position.z = data_object[data_key].transform.position.z
								
								head_node.rotation.x = data_object[data_key].transform.rotation.x
								head_node.rotation.y = data_object[data_key].transform.rotation.y
								head_node.rotation.z = data_object[data_key].transform.rotation.z
								
								head_node.scale.x = data_object[data_key].transform.scale.x
								head_node.scale.y = data_object[data_key].transform.scale.y
								head_node.scale.z = data_object[data_key].transform.scale.z
								
								SceneManager.scene_tree.current_scene.add_child(head_node)
								SceneManager.project_scene_tree.update_tree()
								
						#

func save_project(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		print("Saving to path: ", path)
		if not DirAccess.dir_exists_absolute(path + "/data"):
			await DirAccess.make_dir_absolute(path + "/data")
		
		var save_as_json = JSON.stringify(_get_scene_nodes(SceneManager.scene_tree.current_scene, path))
		var save_file = FileAccess.open(path + "/scene_data.csave", FileAccess.WRITE)
		
		
		save_file.store_line(save_as_json)

func _get_scene_nodes(node: Node3D, save_path: String) -> Dictionary:
	var save_data: Dictionary = {
		"project_name": "Project",
		"author": "Felipe",
		"project_data": []
	}
	
	var nodes: Array[Node] = []
	for child in node.get_children():
		if child.is_class("Node3D") && not child.name.begins_with("_"):
			var object_data: Dictionary = {}
			
			var main_key: String = child.get_class()
			
			if child.get_meta("ImportedMesh"):
				main_key = "ImportedMesh"
			
			
			object_data[main_key] = {
				"name": child.name,
				"transform": {
					"position": {
						"x": child.global_position.x,
						"y": child.global_position.y,
						"z": child.global_position.z
						},
					"rotation": {
						"x": child.rotation.x,
						"y": child.rotation.y,
						"z": child.rotation.z
						},
					"scale": {
						"x": child.scale.x,
						"y": child.scale.y,
						"z": child.scale.z
						},
				}
			}
			
			if child.get_meta("PackageInstance"):
				pass
			
			if child.get_meta("ImportedMesh"):
				# Get meshes and materials
				
				object_data[main_key].name = child.name
				for mesh_child: MeshInstance3D in child.get_children():
					var mesh_arrays: Array = []
					var mesh_material_def: Array = []
					for surface_idx: int in mesh_child.mesh.get_surface_count():
						mesh_arrays.append(mesh_child.mesh.surface_get_arrays(surface_idx))
						
						var material: StandardMaterial3D = mesh_child.mesh.surface_get_material(surface_idx)
						
						var albedo: int = material.albedo_texture.get_image().save_png("%s/data/%s_%s_%s_albedo_tex.png" % [save_path, child.name, mesh_child.name, str(surface_idx)]) if material.albedo_texture != null else -1
						var roughness: int = material.roughness_texture.get_image().save_png("%s/data/%s_%s_%s_roughness_tex.png" % [save_path, child.name, mesh_child.name, str(surface_idx)]) if material.roughness_texture != null else -1
						var normal: int = material.normal_texture.get_image().save_png("%s/data/%s_%s_%s_normal_tex.png" % [save_path, child.name, mesh_child.name, str(surface_idx)]) if material.normal_texture != null else -1
						var metallic: int = material.metallic_texture.get_image().save_png("%s/data/%s_%s_%s_metallic_tex.png" % [save_path, child.name, mesh_child.name, str(surface_idx)]) if material.metallic_texture != null else -1
						
						#print(error_string(albedo))
						
						var material_info: Dictionary = {
							"name": material.resource_name,
							"albedo_texture_path": "./data/%s_%s_%s_albedo_tex.png" % [child.name, mesh_child.name, str(surface_idx)] if albedo == 0 else null,
							"roughness_texture_path": "./data/%s_%s_%s_roughness_tex.png" % [child.name, mesh_child.name, str(surface_idx)] if roughness == 0 else null,
							"normal_texture_path": "./data/%s_%s_%s_normal.png" % [child.name, mesh_child.name, str(surface_idx)] if normal == 0 else null,
							"metallic_texture_path": "./data/%s_%s_%s_metallic_tex.png" % [child.name, mesh_child.name, str(surface_idx)] if metallic == 0 else null,
							"roughness": material.roughness,
							"metallic": material.metallic,
						}
						
						mesh_material_def.append(material_info)
					
					#print(mesh_arrays[Mesh.ARRAY_VERTEX], "\n")
					
					object_data[main_key]["mesh_" + mesh_child.name] = {
						"mesh_data": mesh_arrays,
						"material_data": mesh_material_def,
						"transform": {
							"position": {
								"x": mesh_child.position.x,
								"y": mesh_child.position.y,
								"z": mesh_child.position.z
							},
							"rotation": {
								"x": mesh_child.rotation.x,
								"y": mesh_child.rotation.y,
								"z": mesh_child.rotation.z
							},
							"scale": {
								"x": mesh_child.scale.x,
								"y": mesh_child.scale.y,
								"z": mesh_child.scale.z
							}
						}
					}
				
				
			match child.get_class():
				"SpotLight3D":
					object_data[main_key]["light_data"] = {
						"range": child.spot_range,
						"attenuation": child.spot_attenuation,
						"angle": child.spot_angle,
						"color": child.light_color,
						"energy": child.light_energy,
						"shadow_blur": child.shadow_blur
					}
				
				"DirectionalLight3D":
					object_data[main_key]["light_data"] = {
						"color": child.light_color,
						"energy": child.light_energy,
						"shadow_blur": child.shadow_blur
					}
			
			save_data.project_data.append(object_data)
			
			nodes.append(child)
	
	return save_data
