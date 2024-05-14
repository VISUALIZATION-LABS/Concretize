class_name IPMDL

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

class modelObject:
	var object_name: String = "Object"
	var meshes: Array[ArrayMesh] = []
	var positions: PackedVector3Array = []
	

class model:
	var model_name: String = "Model"
	var object_list: Array[modelObject] = []
	
	func get_object_index(object_name: String) -> int:
		var object_index: int = -1
		
		for current_object in object_list:
			if current_object.object_name == object_name:
				object_index = object_list.bsearch(current_object, true)
				break
		
		return object_index
	
	func add_object(object_name: String) -> int:
		var object_to_add: modelObject = modelObject.new()
		object_to_add.object_name = object_name
		object_list.append(object_to_add)
		return OK
	
	func add_mesh(object_name: String, mesh: ArrayMesh) -> int:
		var object_index: int = get_object_index(object_name)
		
		if object_index > -1:
			object_list[object_index].meshes.append(mesh)
			return OK
		
		return ERR_DOES_NOT_EXIST
	
	func remove_object(object_name: String) -> int:
		var object_to_remove: int = get_object_index(object_name)
		
		if object_to_remove > -1:
			object_list.remove_at(object_to_remove)
			return OK
	
		return ERR_DOES_NOT_EXIST

var compiled_model: model = model.new()
