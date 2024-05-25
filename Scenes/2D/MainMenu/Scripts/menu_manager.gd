extends Control

var model_builder_scene: PackedScene = preload("res://Scenes/3D/ModelBuilder/model_builder.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_dev_load_model_button_down() -> void:
	SceneManager.change_current_scene_to_packed(model_builder_scene)
