extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_up() -> void:
	# Create a new FileDialog window
	var file_dialog: FileDialog = FileDialog.new()
	
	# Parameters
	
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = PackedStringArray(["*.obj ; Wavefront"])
	file_dialog.visible = true
	
	$MarginContainer/Control.add_child(file_dialog)
	file_dialog.file_selected.connect(importer)
	

func importer(path: String):
	match (path.rsplit(".", true, 0)[1].to_lower()):
		"obj":
			var model: PackedStringArray = FileAccess.open(path, FileAccess.READ).\
			get_as_text().rsplit("\n")
			
			# TODO: Convert the model into the variables below
			
			# References:
			# https://en.wikipedia.org/wiki/Wavefront_.obj_file
			
			var vertices: PackedVector3Array
			var normals: PackedVector3Array
			var uv: PackedVector3Array
			var faces: PackedVector3Array
			
			
		"gltf":
			#TODO: Implement
			pass
