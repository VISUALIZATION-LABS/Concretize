extends Control

@onready var testing_scene = "res://Scenes/modelLoaderTest/modelLoaderTestScene.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
	match (path.rsplit(".", true, 1)[1].to_lower()):
		"obj":
			ModelParse.model_path = path
			#ModelParse.generate_obj()
			get_tree().change_scene_to_file("res://Scenes/modelLoaderTest/modelLoaderTestScene.tscn")
			
		"gltf":
			#TODO: Implement
			pass
