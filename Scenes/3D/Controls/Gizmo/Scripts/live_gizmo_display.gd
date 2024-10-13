extends Node3D

@export var local_transform: bool = false

@onready var Z_PLANE: StaticBody3D = $Gizmo.get_node("%Z_TRANSFORM_PLANE")
@onready var X_PLANE: StaticBody3D = $Gizmo.get_node("%X_TRANSFORM_PLANE")
@onready var Y_PLANE: StaticBody3D = $Gizmo.get_node("%Y_TRANSFORM_PLANE")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not local_transform:
		self.global_rotation = Vector3(0,0,0)
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	var scale_amount: float = camera.position.distance_to(self.position)
	scale_amount = clampf(scale_amount, 0.1, 99999999.0)
	scale_amount /= 4.0
	
	#DebugDraw2D.set_text("Scale amount: ", scale_amount)

	self.scale = Vector3(scale_amount, scale_amount, scale_amount)
	
	# TODO: Make this generic (to be used with multiple gizmo types)
	if get_viewport().get_camera_3d().position != self.position:
		
		# This works, but it's ugly...
		# TODO: Make this work with local transformations

		# Make the gizmo X plane always face the camera (locked to its axis)
		X_PLANE.look_at(get_viewport().get_camera_3d().position, Vector3(1,0,0), false)
		X_PLANE.rotate_object_local(Vector3(1,0,0), deg_to_rad(-90))
		X_PLANE.rotation.y = 0
		X_PLANE.rotation.x = X_PLANE.rotation.z
		X_PLANE.rotation.z = 0
		
		# Make the gizmo Y plane always face the camera (locked to its axis)
		Y_PLANE.look_at(get_viewport().get_camera_3d().position, Vector3(0,1,0), true)
		Y_PLANE.rotate_object_local(Vector3(1,0,0), deg_to_rad(90))
		Y_PLANE.rotation.x = deg_to_rad(90)
		
		# Make the gizmo Z plane always face the camera (locked to its axis)
		Z_PLANE.look_at(get_viewport().get_camera_3d().position, Vector3(0, 0, 1), false)
		Z_PLANE.rotate_object_local(Vector3(1,0,0), deg_to_rad(-90))
		Z_PLANE.rotation.y = 0
		Z_PLANE.rotation.x = 0

		
