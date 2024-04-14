extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("This is: LoadTest -> Felipe Sena Costa and Visualization Labs")
	#
	#print("\nInternalModelVertexes: ")
	#print(InternalModel.vertex_array)
##
	## Initialize the ArrayMesh.
	#var temp_array: PackedVector3Array
	#var arr_mesh = ArrayMesh.new()
	#var arrays = []
	#arrays.resize(Mesh.ARRAY_MAX)
##
	## Create the Mesh.
	#for i in range(0, arrays.size()):
		#if ((i - 3) % 3 == 0):
			#for j in range(0,3):
				#temp_array.append(InternalModel.vertex_array[j])
				#arrays[Mesh.ARRAY_VERTEX] = temp_array
		#arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	#
		#
		#print()
	#
	#var m = MeshInstance3D.new()
	#m.mesh = arr_mesh
	#
	#get_tree().root.add_child(m)
	var m := MeshInstance3D.new()
	m.mesh = ModelParse.generate_obj()
	
	get_tree().root.add_child.call_deferred(m)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
