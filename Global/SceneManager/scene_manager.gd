extends Node

# Manages scene related things, such as:
	# Switching
	# Reloading
	# ...

var selections: Array[SelectionModule.Selection] = []
var scene_tree: SceneTree = null
var current_ui: Control = null
var project_scene_tree: ProjectSceneTree = null
var current_camera: Camera3D = null
var current_viewport: SubViewport = null
var program_config: ConfigFile = ConfigFile.new()
var saver_nodes: Array[Node] = []

func disable_interaction() -> void:
	current_camera.movement_enabled = false
	current_camera.get_child(1).interaction_enabled = false


func enable_interaction() -> void:
	current_camera.movement_enabled = true
	current_camera.get_child(1).interaction_enabled = true

# Manage loading everything
func _enter_tree() -> void:
	scene_tree = get_tree()
	var err: Error = program_config.load("res://Internal_config/internal_config.cfg")

	if err != OK:
		OS.alert("Internal configuration file is either missing or corrupted, reconstruction will be attempted...")
		return

	# Set error reporting
	print("Verifying settings path...")
	if program_config.get_value("program_info", "settings_dir").length() == 0 || !program_config.get_value("program_info", "settings_dir").dir_exists:
		print("User settings directory doesn't exist, using built-in settings")
	else:
		print("Loading user settings...")
		# program_config.load("path")
		pass

	SceneDiagnostics.reporting_level = program_config.get_value("program_defaults", "debug_level")

	# Setup graphics settings
	# Renderer change still needs to be implemented
	# Set default world env settings
	# Set renderer quality
	if SceneDiagnostics.reporting_level > SceneDiagnostics.ReportingLevel.NONE:
		pass

	print("\nThis is: %s %s" % [program_config.get_value("program_info", "title"), program_config.get_value("program_info", "version")])
	print("Build %s %s\n" % [program_config.get_value("program_info", "build_info"), program_config.get_value("program_info", "branch")])


# Load settings


# Mesh importer
func import_mesh(paths: PackedStringArray) -> void:
	var importers: Array[Node3D] = []

	# Hack so i can thange this ref value in a lambda
	var importer_count: Dictionary = {"count": 0}

	if paths.size() == 0:
		ErrorManager.raise_error("Cannot import mesh", "Cannot import the desired mesh because there isn't a path to it.")
		return

	var popup: Control = SceneReporter.create_popup(tr("IMPORTER_NOTIFICATION_TITLE"), "", SceneReporter.PopupType.LOADING)

	var importer_finished_callback: Callable = func(file_name: StringName, importer: Node3D, imported_object: Node3D) -> void:
		imported_object.set_meta("ImportedMesh", 1)
		popup.description = popup.description.replace(file_name, "[color=green]%s[/color]" % file_name)	
		importers.remove_at(importers.find(importer))
		importer_count.count -= 1
		
		#scene_tree.current_scene.add_child(imported_object, true)
		
		# Render out the asset so we can store it in the gui
		var asset_container: Control = load("res://Scenes/2D/UI/Prefabs/Asset/Asset.tscn").instantiate()
		var asset_renderer: SubViewport = load("res://Scenes/3D/AssetThumbRender/asset_thumb_render.tscn").instantiate()
		#var asset_container: AssetContainer = AssetContainer.new()
		#var asset_renderer: AssetThumbnailRenderer = AssetThumbnailRenderer.new()
		
		scene_tree.current_scene.add_child(asset_renderer)
		current_ui.add_asset_to_dock(asset_container)
		
		#print(asset_container.get_children())
		
		#current_ui.add_asset_to_dock(asset_container)
		#scene_tree.current_scene.add_child(asset_renderer)
		asset_renderer.add_asset(imported_object.duplicate())
		await asset_container.set_preview_texture(await asset_renderer.render())
		asset_container.node = imported_object.duplicate()
		asset_container.set_title(file_name.trim_suffix(".obj"))
		asset_container.set_description(tr("ASSET_DESCRIPTION_IMPORTED"))
		asset_renderer.queue_free()
		
		

	scene_tree.current_scene.get_node("_UI").add_child(popup)
	#scene_tree.current_scene.get_node("UI").move_child(popup, 0)
	
	for path in paths:		
		var description_path: String = path.get_file()
		popup.description = popup.description + description_path + "\n"
		
		var mesh_importer: Node3D = load("res://Scenes/3D/RuntimeAssetImporter/runtime_asset_importer.tscn").instantiate()

		# Scene could be null but no user will import a mesh before the program is loaded... hopefully
		scene_tree.current_scene.add_child(mesh_importer)
		mesh_importer.Compile_mesh(path, false)
		mesh_importer.connect("ImporterFinished", importer_finished_callback)
		importers.append(mesh_importer)

	var importer_amount: int = importers.size()

	var timer: Timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = 0.2
	scene_tree.current_scene.add_child(timer)
	timer.start()
	timer.timeout.connect(func() -> void:
		var importer_sum: float = 0.0
		if not importers.is_empty():
			importer_sum = importers[0].Get_importer_percentage() / importer_amount
			
			popup.progress_bar.value = importer_sum
		else:
			popup.progress_bar.value = 100	
			timer.queue_free()
			
			scene_tree.create_timer(0.3).timeout.connect(func() -> void: 
				popup.queue_free()
				
				project_scene_tree.update_tree()
			)
	)
	
	

func change_scene(scene: PackedScene) -> void:
	scene_tree.change_scene_to_packed.call_deferred(scene)
	await RenderingServer.frame_post_draw

func get_loaded_node_amount() -> Dictionary:
	var loaded_node_amount: Dictionary = {
		"total_nodes": scene_tree.root.get_child_count(),
		"nodes_in_scene": scene_tree.current_scene.get_child_count()
	}
	return loaded_node_amount
