extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var imported_mesh = ModelParse.generate_obj()
	
	var header_node := Node3D.new()
	header_node.name = "Model"
	
	header_node.name = imported_mesh["model"]["name"]
	
	for object in imported_mesh["model"]["object_list"]:
		var object_node := Node3D.new()
		object_node.name = "Object"
		if not object["object_name"].is_empty():
			object_node.name = object["object_name"]
		
		# TODO: Support mesh-names
		for i in object["meshes"].size():
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = object["meshes"][i]
			mesh_instance.name = ("Mesh " + str(i))
			object_node.add_child(mesh_instance)

		header_node.add_child(object_node)
	
	get_tree().root.add_child.call_deferred(header_node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
