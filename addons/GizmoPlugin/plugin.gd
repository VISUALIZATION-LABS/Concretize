@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("GizmoReceiver", "Node3D", preload("receiverGizmo.gd"),null)
	add_custom_type("GizmoServer", "Node3D", preload("serverGizmo.gd"),null)
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass
