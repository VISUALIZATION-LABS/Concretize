extends Camera3D

# This is a dirty implementation of a freecam feature, to be rewritten

@onready var capt: bool = false
@onready var sens: float = 5
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && capt:
		self.rotate_x(deg_to_rad(-event.relative.y * 0.2))
		$"..".rotate_y(deg_to_rad(-event.relative.x * 0.2))
	
	if event is InputEventMouseButton:
		# m1
		if event.button_mask == 1:
			if capt == false:
				capt = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				capt = false
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var desired_move_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_dir = ($"..".transform.basis * self.transform.basis)\
	* Vector3(desired_move_vec.x, 0, desired_move_vec.y).normalized() * sens
	$"..".position += move_dir
