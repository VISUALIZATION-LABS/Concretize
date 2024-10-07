extends Node

# Manages scene related things, such as:
	# Switching
	# Reloading
	# ...

var scene_tree: SceneTree
var program_config: ConfigFile = ConfigFile.new()

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

	if paths.size() == 0:
		ErrorManager.raise_error("Cannot import mesh", "Cannot import the desired mesh because there isn't a path to it.")
		return

	var popup: Control = SceneReporter.create_popup("Importing mesh", "", SceneReporter.PopupType.LOADING)
	
	var importer_finished_callback: Callable = func(file_name: StringName) -> void:
		popup.description = popup.description.replace(file_name, "[color=green]%s[/color]" % file_name)

	scene_tree.current_scene.get_node("UI").add_child(popup)
	
	for path in paths:
		var description_path: String = path.get_file()
		popup.description = popup.description + description_path + "\n"
		
		var mesh_importer: Node3D = load("res://Scenes/3D/RuntimeAssetImporter/runtime_asset_importer.tscn").instantiate()
		# Scene could be null but no user will import a mesh before the program is loaded... hopefully
		scene_tree.current_scene.add_child(mesh_importer)
		mesh_importer.Compile_mesh(path)
		mesh_importer.connect("ImporterFinished", importer_finished_callback)


	


func get_loaded_node_amount() -> Dictionary:
	var loaded_node_amount: Dictionary = {
		"total_nodes": scene_tree.root.get_child_count(),
		"nodes_in_scene": scene_tree.current_scene.get_child_count()
	}

	return loaded_node_amount

	
	
