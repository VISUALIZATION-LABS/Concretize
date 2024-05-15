extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
		# Create a new FileDialog window
	var file_dialog: FileDialog = FileDialog.new()
	
	# Parameters
	
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	file_dialog.size = Vector2(500, 300)
	file_dialog.filters = PackedStringArray(["*.obj ; Wavefront", "*.gltf, *.glb ; glTF model"])
	file_dialog.visible = true
	$".".add_child(file_dialog)
	file_dialog.file_selected.connect(importer)

func importer(path: String):
	var model_parser: ModelParse = ModelParse.new()
	model_parser.path = path
	
	if not model_parser.path.is_empty():
		var model = model_parser.compile_mesh()
		Shared.import_model = model
		add_mesh()

func add_mesh() -> void:
	var imported_mesh: IPMDL = Shared.import_model
	
	# TODO: Implement GLTF and OBJ functionality (will be easier with classes)
	
	# Node tree build
	var header_node := Node3D.new()
	#var gizmo : Node3DGizmo
	#header_node.add_gizmo(gizmo)
	header_node.name = "Model"
	
	header_node.name = imported_mesh.compiled_model.model_name
	
	for object in imported_mesh.compiled_model.object_list:
		var object_node := Node3D.new()
		object_node.name = "Object"
		if not object.object_name.is_empty():
			object_node.name = object.object_name
		
		# TODO: Support mesh-names
		
		if object.positions.size() > 0:
			for i in object.meshes.size():
				var mesh_instance = MeshInstance3D.new()
				mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
				mesh_instance.mesh = object["meshes"][i]
				mesh_instance.name = ("Mesh " + str(i))
				mesh_instance.position = object["positions"][i]
				mesh_instance.set_meta("header_node", header_node)
				# Needed for raycasts
				mesh_instance.create_trimesh_collision()
				
				object_node.add_child(mesh_instance)
		else:
			for i in object.meshes.size():
				var mesh_instance = MeshInstance3D.new()
				mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
				mesh_instance.mesh = object.meshes[i]
				mesh_instance.name = ("Mesh " + str(i))
				mesh_instance.set_meta("header_node", header_node)
				# Needed for raycasts
				mesh_instance.create_trimesh_collision()
				
				object_node.add_child(mesh_instance)
		header_node.add_child(object_node)
	get_tree().root.add_child.call_deferred(header_node)
