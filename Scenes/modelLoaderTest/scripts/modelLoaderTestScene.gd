extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var imported_mesh := MeshInstance3D.new()

	imported_mesh.mesh = ModelParse.generate_obj()
	
	# Use this so we don't have to force thick walls (WILL INTRODUCE PETER-PANNING)
	imported_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	
	get_tree().root.add_child.call_deferred(imported_mesh)
	
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
