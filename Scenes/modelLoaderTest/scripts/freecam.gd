extends Camera3D

# This is a dirty implementation of a freecam feature, to be rewritten

var mouse_position: Vector2 = Vector2(0.0,0.0)

@onready var capt: bool = false
@onready var sens: float = 5
@onready var gizmo_object = gizmo.new()
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && capt:
		self.rotate_x(deg_to_rad(-event.relative.y * 0.2))
		$"..".rotate_y(deg_to_rad(-event.relative.x * 0.2))
	
	if event is InputEventMouseButton:
		
		if event.button_mask == 1 and event.pressed:
			var from = self.project_ray_origin(event.position)
			var to = from + self.project_ray_normal(event.position) * 1000
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			
			var result := space_state.intersect_ray(query)
			
			if result:
				DebugDraw3D.draw_line(from, result.position, Color("Red"), 90)
				print(result.collider.get_parent().get_meta("model_header"))
				gizmo_object.add_gizmo_to_scene(
					gizmo.selected_gizmo.MOVE, 
					result.collider.get_parent().get_meta("model_header"))
			
			
		# m2
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
