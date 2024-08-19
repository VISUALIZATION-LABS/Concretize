extends Node3D

# TODO: Cleanup

@export_group("REQUIRED DATA")
@export var camera: Camera3D

@onready var gizmo_instance: Node3D = preload("res://Scenes/3D/SelectionModule/LiveGizmo.tscn").instantiate()

const RAY_LENGHT: float = 9999.0
const MESH_COLLISION_MASK: int = 0b0000_0001
const GIZMO_COLLISION_MASK: int = 0b0000_0010

const XZ_PLANE_COLLISION_MASK: int = 0b0000_0100
const XY_PLANE_COLLISION_MASK: int = 0b0000_1000
const YZ_PLANE_COLLISION_MASK: int = 0b0001_0000

var selections: Array = []
var gizmo_selected: bool = false
var previous_mouse_coordinates: Vector3 = Vector3(0,0,0)

enum TRANSFORM_TYPE{
	X,
	Y,
	Z,
	UNDEFINED
}

var current_transform: TRANSFORM_TYPE = TRANSFORM_TYPE.UNDEFINED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().current_scene.add_child.call_deferred(gizmo_instance)
	gizmo_instance.visible = false

# Maybe change the Gizmo to not be created under a selectee, but rather make it globally "there"
# and just hide it when not in use

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("selection_make"):
		if camera == null:
			push_error("ERROR::SELECTION_HANDLER::CAMERA_NULL")
			return
		
		var mouse_position: Vector2 = get_viewport().get_mouse_position()

		var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var raycast_origin: Vector3 = camera.project_ray_origin(mouse_position)
		var raycast_end: Vector3 = raycast_origin + camera.project_ray_normal(mouse_position) * RAY_LENGHT
		var raycast_transform_end: Vector3 = raycast_origin + camera.project_ray_normal(mouse_position) * (RAY_LENGHT / 10)

		var raycast_query_meshes: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_end, MESH_COLLISION_MASK)
		var raycast_query_gizmo: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_end, GIZMO_COLLISION_MASK)


		var raycast_result_gizmo: Dictionary = space_state.intersect_ray(raycast_query_gizmo)
		var raycast_result_meshes: Dictionary = space_state.intersect_ray(raycast_query_meshes)
		
		

		DebugDraw2D.set_text("Raycast result (MESHES): ", raycast_result_meshes, 0, Color("GREEN"), 10)
		DebugDraw2D.set_text("Raycast result (GIZMO): ", raycast_result_gizmo, 0, Color("RED"), 10)

		if not raycast_result_gizmo and not gizmo_selected:
			if raycast_result_meshes:
				var raycast_position: Vector3 = raycast_result_meshes.position
				var raycast_node: Node3D = raycast_result_meshes.collider.get_parent_node_3d()


				if not Input.is_action_pressed("modifier_0"):
					selections.clear()

				if not selections.has(raycast_node):
					selections.append(raycast_node)	
				
				#if gizmo_instance.get_parent():
					#gizmo_instance.get_parent().remove_child(gizmo_instance)
				
				
				
				
				gizmo_instance.visible = true
				

				#raycast_node.add_child(gizmo_instance)
				DebugDraw2D.set_text("Collider: ", raycast_node, 1, Color("GREEN"), 10)
				DebugDraw2D.set_text("Selections: ", selections, 1, Color("GREEN"), 10)
				DebugDraw3D.draw_square(raycast_position, 0.03, Color("ORANGE"), 10)
			else:		
				selections.clear()
				
				if gizmo_instance.visible:
					gizmo_instance.visible = false

				#if gizmo_instance.get_parent():
				#	gizmo_instance.get_parent().remove_child(gizmo_instance)

				DebugDraw2D.set_text("Selections: ", selections, 1, Color("WHITE"), 0)
		else:
			# Do gizmo movement logic
			var collision_mask: int = XZ_PLANE_COLLISION_MASK
			var mouse_transform_mask: Vector3 = Vector3(1,1,1)
			var raycast_node: Node3D = null
			var delta_mouse_position: Vector3 = Vector3(0,0,0)
			#var raycast_position: Vector3 = raycast_result_gizmo.position
			if raycast_result_gizmo:
				raycast_node = raycast_result_gizmo.collider.get_parent_node_3d()

				
				match raycast_node.name:
					"X_Axis":
						current_transform = TRANSFORM_TYPE.X
					"Y_Axis":
						current_transform = TRANSFORM_TYPE.Y
					"Z_Axis":
						current_transform = TRANSFORM_TYPE.Z

			match current_transform:
				TRANSFORM_TYPE.X:
					collision_mask = XZ_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(1,0,0)
				
				TRANSFORM_TYPE.Y:
					collision_mask = YZ_PLANE_COLLISION_MASK | XY_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(0,1,0)

				TRANSFORM_TYPE.Z:
					collision_mask = XZ_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(0,0,1)

			
			# FIXME: Crashes when choosing infinitely far away point and/or missing world boundary
			var mouse_raycast_position_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_transform_end, collision_mask)

			var mouse_raycast_position_result: Dictionary = space_state.intersect_ray(mouse_raycast_position_query)

			var mouse_projected_position: Vector3 = mouse_raycast_position_result.position


			delta_mouse_position = mouse_projected_position - previous_mouse_coordinates

			previous_mouse_coordinates = mouse_projected_position

			DebugDraw2D.set_text("Delta mouse:", delta_mouse_position)

			if not gizmo_selected:
				delta_mouse_position = Vector3(0,0,0)

			gizmo_selected = true

			for selection: Node3D in selections:
				gizmo_instance.position += delta_mouse_position * mouse_transform_mask
				selection.position += delta_mouse_position * mouse_transform_mask

			
			DebugDraw2D.set_text("Collider: ", raycast_node, 1, Color("RED"), 10)
			#DebugDraw3D.draw_square(raycast_position, 0.03, Color("RED"), 10)
			DebugDraw3D.draw_square(mouse_projected_position, 0.03, Color("GREEN"), 10)
	else:
		gizmo_selected = false
	

	var average_position: Vector3 = Vector3(0,0,0)

	if selections.size() > 0:
		for selection: Node3D in selections:
			average_position += selection.position	

		average_position /= selections.size()

	gizmo_instance.position = average_position