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
	file_dialog.filters = PackedStringArray(["*.obj ; Wavefront", "*.bin ; GLTF Bin"])
	file_dialog.visible = true
	
	$MarginContainer/Control.add_child(file_dialog)
	file_dialog.file_selected.connect(importer)

func importer(path: String):
	var model_parser: ModelParse = ModelParse.new()
	model_parser.path = path
	
	if not model_parser.path.is_empty():
		var model = model_parser.compile_mesh()
		Shared.import_model = model
		get_tree().change_scene_to_file("res://Scenes/modelLoaderTest/modelLoaderScene.tscn")
	
