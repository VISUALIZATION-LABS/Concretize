extends Node

var mesh_compiler: Node3D

func _ready() -> void:
	#var compiled_mesh = ModelCompiler.compile_mesh()
	#var mesh_compiler = preload("res://Global/ModelCompiler/model_compiler.cs").new()

	mesh_compiler = preload("res://Scenes/3D/RuntimeAssetImporter/runtime_asset_importer.tscn").instantiate()
	RenderingServer.set_debug_generate_wireframes(true);
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	#mesh_compiler.Compile_mesh("")


	self.add_child.call_deferred(mesh_compiler)

	call_deferred("compile_mesh")

func compile_mesh() -> void:
	mesh_compiler.Compile_mesh("C:/Users/Felipe/dev/tcc/program/TestFiles/ModelsV2/Mesh_tests/Ref_cube/Blend/Cube.obj")

	#self.add_child.call_deferred(compiled_mesh)
	#self.add_child.call_deferred(mesh_compiler.compile_mesh("C://Users//Felipe//Downloads//testmod//TécnicoCafaSala.obj"))
