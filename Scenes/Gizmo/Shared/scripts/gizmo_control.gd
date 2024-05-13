class_name gizmo
extends Node3D

var move_gizmo: Node3D = null
var rotate_gizmo: Node3D = null
var scale_gizmo: Node3D = null
var screen_manip: Node3D = null

enum selected_gizmo {
	MOVE,
	ROTATE,
	SCALE,
	SCREEN_MANIP
}

func _init() -> void:
	# Load all of the gizmo scene files in memory
	move_gizmo = preload("res://Scenes/Gizmo/Move/moveGizmo.tscn").instantiate()
	
	# Assign the scenes into each gizmo variable
	pass

func add_gizmo_to_scene(gizmo_type: selected_gizmo, parent_node: Node3D) -> int:
	match gizmo_type:
		selected_gizmo.MOVE:
			parent_node.add_child(move_gizmo)
	
	return OK


func cleanup():
	if move_gizmo:
		move_gizmo.queue_free()
