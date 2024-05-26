extends Node

func _ready() -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var compiled_mesh = ModelCompiler.compile_mesh()
	mesh.mesh = compiled_mesh
	
	self.add_child.call_deferred(mesh)
