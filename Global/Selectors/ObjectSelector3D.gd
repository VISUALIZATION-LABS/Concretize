class_name  ObjectSelector3D

var selected_object: Node3D = null
var depth_counted: int = 0
var recursing: bool = false
var gizmo_object: gizmo = null

@export var enable_debug: bool = false

signal gizmo_selected(axis: int)

# TODO: Make different types of gizmos
func make_selection(projected_ray_origin: Vector3,projected_ray_normal: Vector3, selection_distance: float,scene_tree: SceneTree,space_state: PhysicsDirectSpaceState3D):
	
	var query := PhysicsRayQueryParameters3D.create(projected_ray_origin, projected_ray_normal * selection_distance)
	query.hit_back_faces = true
	var raycast_result = space_state.intersect_ray(query)
	if raycast_result:
		if enable_debug: DebugDraw3D.draw_line(projected_ray_origin, raycast_result.position, Color.RED, 90)
		# TODO: Make the tree walkable
		var header_node:Node3D = null
		var use_editor_object: bool = false
		
		if raycast_result.collider.name.begins_with("_editor"): use_editor_object = true
		if raycast_result.collider.get_parent().has_meta("header_node") or use_editor_object:
			if not use_editor_object: header_node = raycast_result.collider.get_parent().get_meta("header_node")
			else: header_node = raycast_result.collider.get_parent().get_parent()
			
			if header_node != selected_object:
				
				# Make sure to cleanup the gizmo or else we have a memory leak
				if gizmo_object:
					gizmo_object.cleanup()
					gizmo_object.free()
					gizmo_object = null
				
				gizmo_object = gizmo.new()
				gizmo_object.add_gizmo_to_scene(gizmo.selected_gizmo.MOVE, header_node)
				selected_object = header_node
			else:
				# Recursion is used so we can keep clicking on the same object and keep having it selected,
				# maybe in the future we can have it so every 2 clicks we'll walk down one node
				recursing = true
				depth_counted += 1
				
				if depth_counted >= 50:
					depth_counted = 0
					push_warning("Recurse steps greater than or equal to 50!")
					return
				make_selection(raycast_result.position, projected_ray_normal, selection_distance, scene_tree, space_state)
		else: if raycast_result.collider.get_parent().get_parent().name == "Gizmo":
			var gizmo_object_header: Node3D = raycast_result.collider.get_parent().get_parent()
			
			match raycast_result.collider.get_parent().name:
				"+Y":
					gizmo_object_header.set_control_as_selected(Shared.gizmo_control_types.Y)
				"+X":
					gizmo_object_header.set_control_as_selected(Shared.gizmo_control_types.X)
				"+Z":
					gizmo_object_header.set_control_as_selected(Shared.gizmo_control_types.Z)
	# Cleanup for a non recursive null raycast_result
	else: if not recursing:
		if gizmo_object:
			gizmo_object.cleanup()
			gizmo_object.free()
			gizmo_object = null
			selected_object = null
			
	# Recursive steps have resulted in a null raycast_result, stop recursing
	else:
		recursing = false

