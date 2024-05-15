extends Node3D

# TODO: Make this script be generic for all types of gizmoes

@export var scaling_factor: float = 0.2


var current_control = Shared.gizmo_control_types.OUTSIDE
var gizmo_sensitivity: float = 0.015
var gizmo_distance_to_camera: float = 0
# var outline_3d_material = load("res://Scenes/Gizmo/Shared/selected_outline.tres")
# var outline_planar_material = load("res://Scenes/Gizmo/Shared/selected_outline_planar.tres")
var block_exit_and_enter: bool = false


# FIXME: Whenever grabbing the gizmo from the back it inverts all controls
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.physical_keycode == KEY_BACKSPACE:
			print("Deleted " + str(self.get_parent_node_3d()))
			self.get_parent_node_3d().queue_free()
			self.queue_free()
		if event.physical_keycode == KEY_R and event.is_pressed():
			self.get_parent_node_3d().rotation += Vector3(0,deg_to_rad(90),0)
			self.rotation -= Vector3(0,deg_to_rad(90),0)
	match current_control:
		# Todo: make sensitivity work better, maybe offload the sens value into the Shared autoload
		Shared.gizmo_control_types.OUTSIDE:
			pass
		Shared.gizmo_control_types.X:
			if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				block_exit_and_enter = true
				self.get_parent_node_3d().position += Vector3(event.relative.x * gizmo_sensitivity, 0, 0)
			else:
				block_exit_and_enter = false
				current_control = Shared.gizmo_control_types.OUTSIDE
			
		Shared.gizmo_control_types.Y:
			if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				block_exit_and_enter = true
				self.get_parent_node_3d().position += Vector3(0, -event.relative.y * gizmo_sensitivity, 0)
			else:
				block_exit_and_enter = false
				current_control = Shared.gizmo_control_types.OUTSIDE
		Shared.gizmo_control_types.Z:
			if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				block_exit_and_enter = true
				self.get_parent_node_3d().position += Vector3(0, 0, -event.relative.x * gizmo_sensitivity)
			else:
				block_exit_and_enter = false
				current_control = Shared.gizmo_control_types.OUTSIDE

func _process(delta: float) -> void:
	var camera_position = get_viewport().get_camera_3d().global_position.length()
	gizmo_distance_to_camera = camera_position - abs(self.position.length())
	
	self.scale = Vector3(gizmo_distance_to_camera, gizmo_distance_to_camera, gizmo_distance_to_camera) * scaling_factor
	
	pass

func set_control_as_selected(control_type: Shared.gizmo_control_types):
	current_control = control_type
