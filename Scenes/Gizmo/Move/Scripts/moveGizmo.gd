extends Node3D

@export var scaling_factor: float = 0.3

enum gizmo_control_types {
	X,
	Y,
	Z,
	GENERAL,
	XZ,
	XY,
	YZ,
	OUTSIDE
}


var current_control = gizmo_control_types.OUTSIDE
var outline_3d_material = load("res://Scenes/Gizmo/Shared/selected_outline.tres")
var outline_planar_material = load("res://Scenes/Gizmo/Shared/selected_outline_planar.tres")
var block_exit_and_enter: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	match current_control:
		gizmo_control_types.OUTSIDE:
			print("Mouse is outside of all controls")
		gizmo_control_types.X:
			print("Mouse is inside of X at " + str(get_viewport().get_mouse_position()))
		gizmo_control_types.Y:
			print("Mouse is inside of Y at " + str(get_viewport().get_mouse_position()))
			
			if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				
				print(event.relative.y * 0.2)
				#translate
				block_exit_and_enter = true
				self.get_parent_node_3d().position += Vector3(0, -event.relative.y * 0.02, 0)
			else:
				block_exit_and_enter = false

func _process(delta: float) -> void:
	var camera_position = get_viewport().get_camera_3d().global_position.length()
	var delta_position = camera_position - self.global_position.length()
	
	self.scale = Vector3(delta_position, delta_position, delta_position) * scaling_factor
	
	
	
	pass

func _on_y_mouse_entered() -> void:
	if block_exit_and_enter: return
	current_control = gizmo_control_types.Y
	print("In Y")


func _on_y_mouse_exited() -> void:
	if block_exit_and_enter: return
	current_control = gizmo_control_types.OUTSIDE
	print("Out of Y")
