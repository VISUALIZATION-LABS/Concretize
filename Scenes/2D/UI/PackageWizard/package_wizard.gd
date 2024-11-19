extends Control

@onready var grid: GridContainer = %GridContainer

var item_data: Dictionary = {}
var selected_item: Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ButtonCreate.button_up.connect(_button_create_pressed)
	%ButtonAddModel.button_up.connect(_button_add_model_pressed)
	%ButtonCancel.button_up.connect(_button_cancel_pressed)
	
	%ModelName.text_changed.connect(_model_name_changed)
	%ModelClass.text_changed.connect(_model_class_changed)
	%ModelDescription.text_changed.connect(_model_description_changed)
	
func _model_name_changed(text: String) -> void:
	if selected_item != null && not text.is_empty():
		var previous_dict_item: Dictionary = item_data[selected_item.name]
		selected_item.set_title(text)
		
		item_data[selected_item.title.text] = previous_dict_item
		item_data.erase(selected_item.name)
		
		selected_item.name = selected_item.title.text

func _model_class_changed(text: String) -> void:
	if selected_item != null:
		item_data[selected_item.name].class = text
		selected_item.object_class = text

func _model_description_changed() -> void:
	if selected_item != null:
		item_data[selected_item.name].description = %ModelDescription.text
		selected_item.set_description(%ModelDescription.text)



func _enter_tree() -> void:
	SceneManager.pkg_builder_node_hack = self

func _exit_tree() -> void:
	SceneManager.pkg_builder_node_hack = null

func _button_create_pressed() -> void:
		var file_dialog: FileDialog = FileDialog.new()
		file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
		file_dialog.use_native_dialog = true
		
		file_dialog.dir_selected.connect(func(path: String) -> void:
			var path_array: PackedStringArray = [path]
			_save_pkg(path)
			#print(path)
		)
			
		file_dialog.show()

func _save_pkg(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		print("Saving to path: ", path)
		if not DirAccess.dir_exists_absolute(path + "/data"):
			await DirAccess.make_dir_absolute(path + "/data")
			await DirAccess.make_dir_absolute(path + "/data/thumb")
			await DirAccess.make_dir_absolute(path + "/data/materials")
		# Create the package header
		
		var package: Dictionary = {
			"pkg_name": %PackageName.text,
			"pkg_author": %PackageAuthor.text,
			"pkg_global_class": %PackageClass.text,
			"pkg_assets": []
		}
		
		for asset: Control in grid.get_children():
			var pkg_asset: Dictionary = {
				"pkg_asset_name": asset.title.text,
				"pkg_asset_description": asset.description.text,
				"pkg_asset_class": asset.object_class,
				"pkg_asset_thumb_path": "./data/thumb/%s_thumbnail.png" % [asset.title.text],
				"pkg_asset_data": {
					"mesh_data": [],
					"material_data": []
				}
			}
			
			asset.preview.texture.get_image().save_png("%s/data/thumb/%s_thumbnail.png" % [path, pkg_asset.pkg_asset_name])
			
			for mesh_child: MeshInstance3D in asset.node.get_children():
				var mesh_arrays: Array = []
				var mesh_material_def: Array = []
				for surface_idx: int in mesh_child.mesh.get_surface_count():
					mesh_arrays.append(mesh_child.mesh.surface_get_arrays(surface_idx))
					var material: StandardMaterial3D = mesh_child.mesh.surface_get_material(surface_idx)
					
					#print("%s/data/materials/%s_%s_%s_albedo_tex.png" % [path, pkg_asset.pkg_asset_name, mesh_child.name, str(surface_idx)])
					
					var albedo: int = material.albedo_texture.get_image().save_png("%s/data/materials/%s_%s_%s_albedo_tex.png" % [path, pkg_asset.pkg_asset_name, mesh_child.name, str(surface_idx)]) if material.albedo_texture != null else -1
					var roughness: int = material.roughness_texture.get_image().save_png("%s/data/materials/%s_%s_%s_roughness_tex.png" % [path, pkg_asset.pkg_asset_name, mesh_child.name, str(surface_idx)]) if material.roughness_texture != null else -1
					var normal: int = material.normal_texture.get_image().save_png("%s/data/materials/%s_%s_%s_normal_tex.png" % [path, pkg_asset.pkg_asset_name, mesh_child.name, str(surface_idx)]) if material.normal_texture != null else -1
					var metallic: int = material.metallic_texture.get_image().save_png("%s/data/materials/%s_%s_%s_metallic_tex.png" % [path, pkg_asset.pkg_asset_name, mesh_child.name, str(surface_idx)]) if material.metallic_texture != null else -1
					
					#print(error_string(albedo))
					
					var material_info: Dictionary = {
						"name": material.resource_name,
						"albedo_texture_path": "./data/materials/%s_%s_%s_albedo_tex.png" % [pkg_asset.pkg_asset_name, mesh_child.name, str(surface_idx)] if albedo == 0 else null,
						"roughness_texture_path": "./data/materials/%s_%s_%s_roughness_tex.png" % [pkg_asset.pkg_asset_name, mesh_child.name, str(surface_idx)] if roughness == 0 else null,
						"normal_texture_path": "./data/materials/%s_%s_%s_normal.png" % [pkg_asset.pkg_asset_name, mesh_child.name, str(surface_idx)] if normal == 0 else null,
						"metallic_texture_path": "./data/materials/%s_%s_%s_metallic_tex.png" % [pkg_asset.pkg_asset_name, mesh_child.name, str(surface_idx)] if metallic == 0 else null,
						"roughness": material.roughness,
						"metallic": material.metallic,
					}
					
					pkg_asset.pkg_asset_data.mesh_data.append(mesh_arrays)
					pkg_asset.pkg_asset_data.material_data.append(material_info)
			package.pkg_assets.append(pkg_asset)
	
		var save_as_json = JSON.stringify(package)
		var save_file = FileAccess.open(path + "/%s.cpkg" % package.pkg_name, FileAccess.WRITE)
		save_file.store_line(save_as_json)

func _on_item_selected(item: Control) -> void:
	selected_item = item
	var item_found: bool = false
	for item_name: String in item_data:
		if item_name == item.name:
			%ModelName.text = item_name
			%ModelClass.text = item_data[item_name].class
			%ModelDescription.text = item_data[item_name].description
			item_found = true
			break

	if not item_found:
		# Create a new item entry
		item_data[item.name] = {
			"class" = "",
			"description" = ""
		}
		
		%ModelName.text = item.name
		%ModelClass.text = item_data[item.name].class
		%ModelDescription.text = item_data[item.name].description

func _button_add_model_pressed() -> void:
	var file_dialog: FileDialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter("*.obj, *.gltf, *.glb", "3D models")
	
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	file_dialog.use_native_dialog = true
	
	file_dialog.files_selected.connect(func(paths: PackedStringArray) -> void:
		print("Selected paths: ")
		SceneManager.import_mesh(paths, true)
	)
	
	file_dialog.show()

func _button_cancel_pressed() -> void:
	self.queue_free()

func add_asset_to_grid(asset: Control) -> void:
	grid.add_child(asset)
