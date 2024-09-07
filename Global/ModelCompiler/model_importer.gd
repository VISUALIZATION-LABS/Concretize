extends Node
class_name ModelCompiler


func import_mesh() -> int:
	# Instance a new file dialog

	var file_dialog: FileDialog = FileDialog.new()

	
	
	self.add_child(file_dialog)
	
	file_dialog.add_filter("*.obj, *.glb, *.gltf", "3D model files")
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	file_dialog.min_size = Vector2i(800,500)
	file_dialog.move_to_center()
	file_dialog.use_native_dialog = true
	file_dialog.show()
	file_dialog.connect("files_selected", _on_file_dialog_files_selected)
	
	return OK

func _on_file_dialog_files_selected(files: PackedStringArray) -> void:
	# For now multiple files don't work
	var model_compiler: Node3D = load("res://Scenes/3D/RuntimeAssetImporter/runtime_asset_importer.tscn").instantiate()
	get_tree().current_scene.add_child(model_compiler)
	model_compiler.Compile_mesh(files[0])
	self.queue_free()