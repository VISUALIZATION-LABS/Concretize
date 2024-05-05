class_name IPMDL

# IPMDL IS STRUCTURED LIKE SO:

#{
	#"name": "name:String"
	#"object_list": [
		#{
			#"object_name": "name:String"
			#"meshes": [{"material:" "material:Material", "mesh": "mesh"}]
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
	model["object_list"].append({"object_name": name, "meshes": []})
	return 0

func remove_object(object_name: String) -> int:
	model["object_list"].remove_at(get_object_index(object_name))
	return 0

#func set_material(object_name: String, material: Material) -> int:
	## This is used to change the material in an existing material
	## If you need to create an object refrain from using this and just pass the
	## material in the object creator (add_object)
	#model["object_list"][get_object_index(object_name)]["material"] = material
	#return 0

func set_name(model_name:String) -> int:
	model["name"] = model_name
	return 0

# TODO: Add functions to get a mesh (cmp input mesh with arr mesh maybe) 
# and mesh deletion

func add_mesh(object_name: String, mesh: ArrayMesh) -> int:
	model["object_list"][get_object_index(object_name)]["meshes"].append(mesh)
	return 0
