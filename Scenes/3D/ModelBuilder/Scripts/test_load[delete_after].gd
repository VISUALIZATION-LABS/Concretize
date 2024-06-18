extends Node

func _ready() -> void:
	#var compiled_mesh = ModelCompiler.compile_mesh()
	var mesh_compiler = preload("res://Global/ModelCompiler/model_compiler.cs").new()
	#self.add_child.call_deferred(compiled_mesh)
	self.add_child.call_deferred(mesh_compiler.compile_mesh("C:/Users/Felipe/dev/tcc/program/TestFiles/ModelsV2/Mesh_tests/Dense/StanfordDragon/stabfordDragonPureTri.obj"))
