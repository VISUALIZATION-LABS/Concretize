extends Control

@onready var model_compiler = preload("res://Global/ModelCompiler/model_compiler.cs")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	var compiled_mesh := model_compiler.new()

	self.get_parent().get_parent().add_child.call_deferred(compiled_mesh.compile_obj_mesh("C:\\Users\\Felipe\\dev\\tcc\\program\\TestFiles\\ModelsV2\\Mesh_tests\\MaterialPyramid\\materialPyramid.obj"))
