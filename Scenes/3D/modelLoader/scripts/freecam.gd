extends Camera3D

var mouse_position: Vector2 = Vector2(0.0,0.0)

@onready var capt: bool = false
@onready var sens: float = 5
@onready var gizmo_object: gizmo = null
@onready var selector: ObjectSelector3D = ObjectSelector3D.new()


func _input(event: InputEvent) -> void:
	# TODO: Remove
	# This is only here for the presentation on the 14th, remove after
	
	if event is InputEventKey:
		if event.physical_keycode == KEY_1 and event.is_released():
			print("Spawning light")
			var spot_light: Node3D = load("res://Global/BuiltInModels/3D/Spot3D/Spot3D.tscn").instantiate()
			get_tree().root.add_child.call_deferred(spot_light)
		if event.physical_keycode == KEY_2 and event.is_released():
			print("Spawning light (omni)")
			var omni_light: Node3D = load("res://Global/BuiltInModels/3D/Omni3D/Omni3D.tscn").instantiate()
			get_tree().root.add_child.call_deferred(omni_light)
	
	if event is InputEventMouseMotion && capt:
		self.rotate_x(deg_to_rad(-event.relative.y * 0.2))
		$"..".rotate_y(deg_to_rad(-event.relative.x * 0.2))
	
	if event is InputEventMouseButton:
		if event.button_mask == 1 and event.pressed:
			selector.make_selection(
				self.project_ray_origin(event.position), 
				self.project_ray_normal(event.position), 
				1000,
				get_tree(),
				get_world_3d().direct_space_state)
		if event.button_mask == 2:
				capt = true
				mouse_position = get_viewport().get_mouse_position()
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else: 
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if capt: get_viewport().warp_mouse(mouse_position)
			capt = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var desired_move_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_dir = ($"..".transform.basis * self.transform.basis)\
	* Vector3(desired_move_vec.x, 0, desired_move_vec.y).normalized() * sens * delta
	$"..".position += move_dir
