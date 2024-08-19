extends Control

var model_importer: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	
	#self.add_child.call_deferred(model_importer)

	call_deferred("_compile")	

func _compile() -> void:
	model_importer = load("res://Scenes/3D/RuntimeAssetImporter/runtime_asset_importer.tscn").instantiate()
	get_tree().current_scene.add_child(model_importer)
	model_importer.Compile_mesh("/home/felipe/Development/Blender/Projects/Gallery_test/Gallery_test.obj")
