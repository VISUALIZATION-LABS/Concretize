extends Node3D

# TODO: Cleanup
# TODO: Make work with multiple gizmos

@export_group("REQUIRED DATA")
@export var camera: Camera3D

@onready var gizmo_move: Node3D = preload("res://Scenes/3D/Controls/Gizmo/LiveGizmo.tscn").instantiate()
@onready var selected_material: Resource = preload("res://Resources/Shaders/3D/SelectionHighlight.tres")

const RAY_LENGHT: float = 99999.0

# COLLISION MASKS

const MESH_COLLISION_MASK: int = 0b0000_0001
const GIZMO_COLLISION_MASK: int = 0b0000_0010

const Z_TRANSFORM_PLANE_COLLISION_MASK: int = 0b0000_0100
const X_TRANSFORM_PLANE_COLLISION_MASK: int = 0b0000_1000
const Y_TRANSFORM_PLANE_COLLISION_MASK: int = 0b0001_0000

var selections: Array = []
var gizmo_selected: bool = false
var previous_mouse_coordinates: Vector3 = Vector3(0,0,0)

enum TRANSFORM_CLASS {
	MOVE,
	ROTATE,
	SCALE,
	UNDEFINED
}

enum TRANSFORM_TYPE{
	X,
	Y,
	Z,
	ALL,
	UNDEFINED
}

var current_transform: TRANSFORM_TYPE = TRANSFORM_TYPE.UNDEFINED
var current_type: TRANSFORM_CLASS = TRANSFORM_CLASS.MOVE 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().current_scene.add_child.call_deferred(gizmo_move)
	gizmo_move.visible = false

	SignalBus.gizmo_type_change.connect(_gizmo_type_change)

# Maybe change the Gizmo to not be created under a selectee, but rather make it globally "there"
# and just hide it when not in use

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("selection_make"):
		if camera == null:
			push_error("ERROR::SELECTION_HANDLER::CAMERA_NULL")
			return
		
		var mouse_position: Vector2 = get_viewport().get_mouse_position()

		# Raycast setup

		var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var raycast_origin: Vector3 = camera.project_ray_origin(mouse_position)
		var raycast_end: Vector3 = raycast_origin + camera.project_ray_normal(mouse_position) * RAY_LENGHT
		var raycast_transform_end: Vector3 = raycast_origin + camera.project_ray_normal(mouse_position) * (RAY_LENGHT / 10)

		# Raycast emit
		
		var raycast_query_meshes: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_end, MESH_COLLISION_MASK)
		var raycast_query_gizmo: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_end, GIZMO_COLLISION_MASK)

		# Raycast results
		
		var raycast_result_gizmo: Dictionary = space_state.intersect_ray(raycast_query_gizmo)
		var raycast_result_meshes: Dictionary = space_state.intersect_ray(raycast_query_meshes)

		#DebugDraw2D.set_text("Raycast result (MESHES): ", raycast_result_meshes, 0, Color("GREEN"), 10)
		#DebugDraw2D.set_text("Raycast result (GIZMO): ", raycast_result_gizmo, 0, Color("RED"), 10)

		if not raycast_result_gizmo and not gizmo_selected:
			if raycast_result_meshes:
				var raycast_position: Vector3 = raycast_result_meshes.position
				
				# Check if we can go farther toplevel
				
				var raycast_node: Node3D = raycast_result_meshes.collider.get_parent_node_3d()
				
				while raycast_node != null:
					raycast_node = raycast_node.get_parent_node_3d()

				# FIXME: Bit of repetition, shouldn't be too bad but maybe take a look
				if not Input.is_action_pressed("modifier_0"):
					# Remove selected materials
					for selection: MeshInstance3D in selections:
						for i in selection.mesh.get_surface_count():
							if selection.get_active_material(i):
								selection.set_surface_override_material(i, null)

					selections.clear()

				if not selections.has(raycast_node):
					selections.append(raycast_node)	
					
					# Apply selected material
					for i: int in raycast_node.mesh.get_surface_count():
						if raycast_node.get_active_material(i):
							var current_material: Material = raycast_node.get_active_material(i).duplicate()
						#raycast_node.get_active_material(i).next_pass = selected_material

							raycast_node.set_surface_override_material(i, current_material)
							raycast_node.get_surface_override_material(i).next_pass = selected_material

				#if gizmo_instance.get_parent():
					#gizmo_instance.get_parent().remove_child(gizmo_instance)

				gizmo_move.visible = true

				#raycast_node.add_child(gizmo_instance)
				#DebugDraw2D.set_text("Collider: ", raycast_node, 1, Color("GREEN"), 10)
				#DebugDraw2D.set_text("Selections: ", selections, 1, Color("GREEN"), 10)
				#DebugDraw3D.draw_square(raycast_position, 0.03, Color("ORANGE"), 10)
			else:
				# Remove selected material
				for selection: MeshInstance3D in selections:
					for i in selection.mesh.get_surface_count():
						if selection.get_active_material(i):
							selection.set_surface_override_material(i, null)
				
				selections.clear()
				
				if gizmo_move.visible:
					gizmo_move.visible = false

				#if gizmo_instance.get_parent():
				#	gizmo_instance.get_parent().remove_child(gizmo_instance)

				#DebugDraw2D.set_text("Selections: ", selections, 1, Color("WHITE"), 0)
		else:
			# Do gizmo movement logic
			var collision_mask: int = Z_TRANSFORM_PLANE_COLLISION_MASK
			var mouse_transform_mask: Vector3 = Vector3(1,1,1)
			var raycast_node: Node3D = null
			var delta_mouse_position: Vector3 = Vector3(0,0,0)
			#var raycast_position: Vector3 = raycast_result_gizmo.position
			if raycast_result_gizmo and not gizmo_selected:
				raycast_node = raycast_result_gizmo.collider.get_parent_node_3d()

				
				match raycast_node.name:
					"X_Axis":
						current_transform = TRANSFORM_TYPE.X
					"Y_Axis":
						current_transform = TRANSFORM_TYPE.Y
					"Z_Axis":
						current_transform = TRANSFORM_TYPE.Z
					"Global_Move":
						ErrorManager.raise_warning("Global movement is not fully implemented", "Due to mouse projection issues, this transformation type will not work properly.")
						current_transform = TRANSFORM_TYPE.ALL


			# TODO: Implement a way to discern which type of col mask to use based on camera facingness
			# Experiment with doing 2 raycasts (one that collides with the floors and one that collides with the walls), then do
			# stuff with the data

			match current_transform:
				TRANSFORM_TYPE.X:
					collision_mask = X_TRANSFORM_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(1,0,0)
				
				TRANSFORM_TYPE.Y:
					collision_mask = Y_TRANSFORM_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(0,1,0)

				TRANSFORM_TYPE.Z:
					collision_mask = Z_TRANSFORM_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(0,0,1)
				
				# FIXME: Doesn't work properly
				TRANSFORM_TYPE.ALL:
					collision_mask = Z_TRANSFORM_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(1,1,1)

			
			
			var mouse_raycast_position_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_transform_end, collision_mask)

			var mouse_raycast_position_result: Dictionary = space_state.intersect_ray(mouse_raycast_position_query)

			if mouse_raycast_position_result:

				var mouse_projected_position: Vector3 = mouse_raycast_position_result.position

				delta_mouse_position = mouse_projected_position - previous_mouse_coordinates

				previous_mouse_coordinates = mouse_projected_position

				#DebugDraw2D.set_text("Delta mouse:", delta_mouse_position)

				if not gizmo_selected:
					delta_mouse_position = Vector3(0,0,0)

				gizmo_selected = true

				match current_type:
					TRANSFORM_CLASS.MOVE:
						for selection: Node3D in selections:
							selection.position += delta_mouse_position * mouse_transform_mask

					TRANSFORM_CLASS.SCALE:
						for selection: Node3D in selections:
							selection.scale += delta_mouse_position * mouse_transform_mask

				
				gizmo_move.position += delta_mouse_position * mouse_transform_mask

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

	gizmo_move.position = average_position

func _gizmo_type_change(type: String) -> void:
	match type:
		"Transform":
			print("Setting type to MOVE")
			current_type = TRANSFORM_CLASS.MOVE
		"Rotate":
			push_warning("Rotation not implemented yet")
		"Scale":
			print("Setting type to SCALE")
			current_type = TRANSFORM_CLASS.SCALE
