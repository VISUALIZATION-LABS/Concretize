extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var imported_mesh: IPMDL = Shared.import_model
	
	# Node tree build
	var header_node := Node3D.new()
	#var gizmo : Node3DGizmo
	#header_node.add_gizmo(gizmo)
	header_node.name = "Model"
	
	header_node.name = imported_mesh["model"]["name"]
	
	for object in imported_mesh["model"]["object_list"]:
		var object_node := Node3D.new()
		object_node.name = "Object"
		if not object["object_name"].is_empty():
			object_node.name = object["object_name"]
		
		# TODO: Support mesh-names
		
		if object["positions"].size() > 0:
			for i in object["meshes"].size():
				var mesh_instance = MeshInstance3D.new()
				mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
				mesh_instance.mesh = object["meshes"][i]
				mesh_instance.name = ("Mesh " + str(i))
				mesh_instance.position = object["positions"][i]
				
				# Needed for raycasts
				mesh_instance.create_trimesh_collision()
				
				object_node.add_child(mesh_instance)
		else:
			for i in object["meshes"].size():
				var mesh_instance = MeshInstance3D.new()
				mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
				mesh_instance.mesh = object["meshes"][i]
				mesh_instance.name = ("Mesh " + str(i))
				
				# Needed for raycasts
				mesh_instance.create_trimesh_collision()
				
				object_node.add_child(mesh_instance)
		header_node.add_child(object_node)
	
	get_tree().root.add_child.call_deferred(header_node)
