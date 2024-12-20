extends Node3D

@export var local_transform: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not local_transform:
		self.global_rotation = Vector3(0,0,0)
	
	var camera: Camera3D = get_viewport().get_camera_3d()

	var scale_amount: float = camera.position.distance_to(self.position)

	

	scale_amount /= 4.0

	DebugDraw2D.set_text("Scale amount: ", scale_amount)

	self.scale = Vector3(scale_amount, scale_amount, scale_amount)