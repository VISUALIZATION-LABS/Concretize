extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var mesh_object: IPMDL = ModelParse.generate_obj()
	
	var mesh0 = mesh_object["model"]["object_list"][0]["meshes"][0]
	var mesh1 = mesh_object["model"]["object_list"][0]["meshes"][1]
	var mesh2 = mesh_object["model"]["object_list"][0]["meshes"][2]
	
	print(mesh0)
	print(mesh1)
	print(mesh2)
	
	var meshinstance0 = MeshInstance3D.new()
	var meshinstance1 = MeshInstance3D.new()
	var meshinstance2 = MeshInstance3D.new()
	
	meshinstance0.mesh = mesh0
	meshinstance1.mesh = mesh1
	meshinstance2.mesh = mesh2
	
	get_tree().root.add_child.call_deferred(meshinstance0)
	get_tree().root.add_child.call_deferred(meshinstance1)
	get_tree().root.add_child.call_deferred(meshinstance2)
	
	#var InternalModel = Node3D.new()
	#InternalModel.name = "InternalModel"
	#
	#
	#for object in mesh_object:
		#print("Creating object for: " + object)
		#var object_node = Node3D.new()
		#object_node.name = String(object)
#
		#for model in mesh_object[object]:
			#print("Creating facegroup for: " + model)
			#var model_instance = MeshInstance3D.new()
			#model_instance.name = model
			#model_instance.mesh = mesh_object[object][model]["mesh"]
			#model_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
			#
			#object_node.add_child(model_instance)
		#InternalModel.add_child(object_node)
		#
	## Use this so we don't have to force thick walls (WILL INTRODUCE PETER-PANNING)
	#
	#get_tree().root.add_child.call_deferred(InternalModel)
	
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
