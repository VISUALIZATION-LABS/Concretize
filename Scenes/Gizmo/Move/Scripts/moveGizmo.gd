extends Node3D

enum controlTypes {
	X,
	Y,
	Z,
	GENERAL,
	XZ,
	XY,
	YZ,
	OUTSIDE
}

var current_control = controlTypes.OUTSIDE

var outline_3d_material = load("res://Scenes/Gizmo/Shared/selected_outline.tres")
var outline_planar_material = load("res://Scenes/Gizmo/Shared/selected_outline_planar.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	match current_control:
		#controlTypes.OUTSIDE:
			#print("Mouse is outside of all controls")
		#controlTypes.X:
			#print("Mouse is inside of X at " + str(get_viewport().get_mouse_position()))
		controlTypes.Y:
			print("Mouse is inside of Y at " + str(get_viewport().get_mouse_position()))
	pass

func _on_y_mouse_entered() -> void:
	current_control = controlTypes.Y
	print("In Y")


func _on_y_mouse_exited() -> void:
	current_control = controlTypes.OUTSIDE
	print("Out of Y")
