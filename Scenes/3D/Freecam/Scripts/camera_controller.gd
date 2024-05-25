extends Node

@export_group("Controls")
@export_range(1, 10, 0.1, "or_greater") var sensitivity: float = 1.0

@onready var camera = $Camera3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Captured relative event
		var relative_motion: Vector2 = event.relative
		
		# Move camera in global Y
		camera.global_rotate(Vector3(0,-1,0), deg_to_rad(relative_motion.x * sensitivity / 10))
		# Move camera in local X
		camera.rotate_object_local(Vector3(-1,0,0), deg_to_rad(relative_motion.y * sensitivity / 10))
