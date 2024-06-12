extends Node

func _ready() -> void:
	var compiled_mesh = ModelCompiler.compile_mesh()

	self.add_child.call_deferred(compiled_mesh)
