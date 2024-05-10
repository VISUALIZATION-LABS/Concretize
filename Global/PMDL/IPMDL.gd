class_name IPMDL

# IPMDL IS STRUCTURED LIKE SO:

#{
	#"name": "name:String"
	#"object_list": [
		#{
			#"object_name": "name:String"
			#"meshes": []
			#"positions": []
		#}
	#]
#}

# PMDL IS STRUCTURED LIKE SO:
#{
	#import_mtl: xxx.PMTL	
	#objInit
	#name name:String
	#material: xxx.material0
	#verts []
	#idx []
	#objEnd
#}

# TODO: Document and add proper error values

var model: Dictionary = {"name": null, "object_list": []}:
	get:
		return model
	set(value):
		push_error("Can't modify the model data structure without the use of helper functions.")

func get_object_index(name: String) -> int:
	var object_index: int = -1
	
	# Find the index of the desired object
	for i in model["object_list"].size():
		if model["object_list"][i]["object_name"] == name:
			object_index = i
			break
	return object_index

func add_object(name: String) -> int:
	model["object_list"].append({"object_name": name, "meshes": [], "positions": []})
	return OK

func remove_object(object_name: String) -> int:
	model["object_list"].remove_at(get_object_index(object_name))
	return OK

func set_name(model_name:String) -> int:
	model["name"] = model_name
	return OK

# TODO: Add functions to get a mesh (cmp input mesh with arr mesh maybe) 
# and mesh deletion

func set_position(object_name: String, position: Vector3) -> int:
	model["object_list"][get_object_index(object_name)]["positions"].append(position)
	return OK

func add_mesh(object_name: String, mesh: ArrayMesh) -> int:
	model["object_list"][get_object_index(object_name)]["meshes"].append(mesh)
	return OK
