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


var current_control =gizmo_control_types.OUTSIDE
var outline_3d_material = load("res://Scenes/Gizmo/Shared/selected_outline.tres")
var outline_planar_material = load("res://Scenes/Gizmo/Shared/selected_outline_planar.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	var camera_position = get_viewport().get_camera_3d().global_position.length()
	var delta_position = camera_position - self.global_position.length()
	
	self.scale = Vector3(delta_position, delta_position, delta_position) * scaling_factor
	
	
	#match current_control:
		#gizmo_control_types.OUTSIDE:
			#print("Mouse is outside of all controls")
		#gizmo_control_types.X:
			#print("Mouse is inside of X at " + str(get_viewport().get_mouse_position()))
		#gizmo_control_types.Y:
			#print("Mouse is inside of Y at " + str(get_viewport().get_mouse_position()))
	pass

func _on_y_mouse_entered() -> void:
	current_control = gizmo_control_types.Y
	print("In Y")


func _on_y_mouse_exited() -> void:
	current_control = gizmo_control_types.OUTSIDE
	print("Out of Y")
