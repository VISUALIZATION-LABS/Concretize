extends Control

@onready var testing_scene = preload("res://Scenes/3D/InternalTests/loadTest.tscn").instantiate()
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
	file_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	file_dialog.size = Vector2(500, 300)
	file_dialog.filters = PackedStringArray(["*.obj ; Wavefront"])
	file_dialog.visible = true
	
	$MarginContainer/Control.add_child(file_dialog)
	file_dialog.file_selected.connect(importer)
	

func importer(path: String):
	match (path.rsplit(".", true, 0)[1].to_lower()):
		"obj":
			# Inital parsing with regex
			print("Init parse\n\nOBJ_FILE:\n")
			var object = RegEx.new()
			object.compile("o.*[A-Za-z]+[0-9]*\\.[0-9]+")
			
			var vertex = RegEx.new()
			vertex.compile("v\\s.*[0-9]*\\.[0-9]+.*[0-9]*\\.[0-9]+.*[0-9]*\\.[0-9]+")
			
			
			#var model: PackedStringArray = FileAccess.open(path, FileAccess.READ).\
			#get_as_text().rsplit("\n")
			
			var model: String = FileAccess.open(path, FileAccess.READ).get_as_text()
			# TODO: Convert the model into the variables below
			
			# References:
			# https://en.wikipedia.org/wiki/Wavefront_.obj_file
			var parsed_model = {}
			var objects: PackedStringArray
			var vertices: PackedVector3Array
			var normals: PackedVector3Array
			var uv: PackedVector3Array
			var faces: PackedVector3Array
			
			var finished: bool = false
			
			
			# FIXME: This doesn't work properly (gets all our data but doesn't
			#        match up with objects) 
			
			print("Objects")
			for result in object.search_all(model):
				objects.append(result.get_string())
			print(objects)
			
			print("Vertices")
			for result in vertex.search_all(model):
				
				# With this we'll have the vertices, then we just need to convert
				# them to floats
				
				var parsed_vertices: PackedStringArray = result.get_string().rsplit(" ").slice(1)
				
				vertices.append(Vector3(
					float(parsed_vertices[0]),
					float(parsed_vertices[1]),
					float(parsed_vertices[2])
					))
			print(vertices)
			
			# Test buld
			
			InternalModel.vertex_array = vertices
			
			get_tree().change_scene_to_file("res://Scenes/3D/InternalTests/loadTest.tscn")
			
		"gltf":
			#TODO: Implement
			pass
