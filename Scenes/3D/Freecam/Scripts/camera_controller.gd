extends Node

@export_group("Controls")
@export_range(1, 10, 0.1, "or_greater") var sensitivity: float = 1.0
@export_range(1, 10, 0.1, "or_greater") var camera_speed: float = 1.0

@export_group("Display")
@export_range(1, 179, 0.1) var FOV: float = 90

@onready var camera: Camera3D = $Camera3D

var movement_enabled: bool = true

var camera_lock: bool = true
var previous_mouse_coordinates: Vector2 = Vector2(0,0)
var current_movement: Vector3 = Vector3(0,0,0)

func _ready():
	print("READY")
	SceneManager.current_camera = camera
	SceneManager.current_viewport = self.get_parent()

func _input(event: InputEvent) -> void:
	if movement_enabled:
		if event is InputEventMouseMotion:
			var relative_motion: Vector2 = event.relative
			
			# CAMERA ROTATION ----
			
			if not camera_lock:
				camera.global_rotate(Vector3(0,-1,0), deg_to_rad(relative_motion.x * sensitivity / 10))
				camera.rotate_object_local(Vector3(-1,0,0), deg_to_rad(relative_motion.y * sensitivity / 10))
			
			# CAMERA ROTATION ----
		if event is InputEventMouseButton:
			if event.button_mask == 2:
				camera_lock = false
				previous_mouse_coordinates = get_viewport().get_mouse_position()
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				if not camera_lock:
					camera_lock = true
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					get_viewport().warp_mouse(previous_mouse_coordinates)


# We do movement in process in case the refresh rate is dirrerent to the physics step rate (60HZ)
func _process(_delta: float) -> void:
	camera.fov = FOV
	
	# MOVEMENT SECTION ----
	if movement_enabled:
		var input_vector: Vector2 = Input.get_vector("move_forward", "move_back", "move_left", "move_right")

		var desired_movement: Vector3 = (camera.basis.z * input_vector.x) + (camera.basis.x * input_vector.y)
		current_movement = lerp(current_movement, desired_movement, 0.2)

		# Then transform the camera based on it's basis (global rot matrix in practice)
		camera.global_translate(current_movement * camera_speed / 10)
	# END OF MOVEMENT SECTION ----
