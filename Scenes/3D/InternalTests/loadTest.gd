extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	
	get_tree().root.add_child.call_deferred(mesh)
	
	mesh.mesh = ModelParse.generate_obj()
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
