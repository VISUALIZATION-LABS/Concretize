extends Node3D

# This file is responsible for handling object picking, selection handling and gizmo moving

# -- Data section --

# Since this is a component, the camera will not be gotten from the viewport
@export var camera: Camera3D

@onready var gizmo_move: Node3D = preload("res://Scenes/3D/Controls/Gizmo/LiveGizmo.tscn").instantiate()
@onready var selected_material: Resource = preload("res://Resources/Shaders/3D/SelectionHighlight.tres")

# -- Raycast parameters --

const RAY_LENGHT: float = 99_999.0

# -- Collision masks --

const MESH_COLLISION_MASK: int = 0b0000_0001
const GIZMO_COLLISION_MASK: int = 0b0000_0010

# Gizmo specific stuff
# TODO: Change the collision masks in editor

const X_TRANSFORM_PLANE_COLLISION_MASK: int = 0b0000_1000
const Y_TRANSFORM_PLANE_COLLISION_MASK: int = 0b0001_0000
const Z_TRANSFORM_PLANE_COLLISION_MASK: int = 0b0000_0100
const VIEW_TRANSFORM_PLANE_COLLISION_MASK: int = 0b0010_000

# -- Selection handler --

var selections: Array[Selection] = []
var selected_meshes: Array[MeshInstance3D] = []
var gizmo_selected: bool = false

class Selection:
	var top_level: Node3D
	var last_level_selected: Node3D
	var lowest_level: Node3D
	var selection: Node3D

# This is used for calculating a delta_mouse parameter for transformations
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

func _ready() -> void:
	# Add all gizmos at 0,0,0
	
	SceneManager.scene_tree.current_scene.add_child.call_deferred(gizmo_move)
	#SceneManager.scene_tree.current_scene.add_child.call_deferred(gizmo_rotate)
	#SceneManager.scene_tree.current_scene.add_child.call_deferred(gizmo_scale)

	gizmo_move.hide()
	#gizmo_rotate.hide()
	#gizmo_scale.hide()

	SignalBus.gizmo_type_change.connect(_change_gizmo_type)



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("selection_make"):
		if camera == null:
			push_error("ERROR::SELECTION_MODULE::CAMERA_NULL")
			return
		
		# -- Selection handling --

		var mouse_position: Vector2 = get_viewport().get_mouse_position()

		# Raycasting

		var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var raycast_origin: Vector3 = camera.project_ray_origin(mouse_position)
		var raycast_end: Vector3 = raycast_origin + camera.project_ray_normal(mouse_position) * RAY_LENGHT

		# Raycast query
		
		# We have 2 raycast queries (one for scene objects and one for the gizmo) because we need to check if we've
		# selected the gizmo later so we don't accidetally select something else when we want to move an object


		var raycast_query_scene_objects: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			raycast_origin,
			raycast_end,
			MESH_COLLISION_MASK
		)

		var raycast_query_gizmo: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			raycast_origin,
			raycast_end,
			GIZMO_COLLISION_MASK
		)

		# Raycast results

		var raycast_query_results_scene_objects: Dictionary = space_state.intersect_ray(raycast_query_scene_objects)
		var raycast_query_results_gizmo: Dictionary = space_state.intersect_ray(raycast_query_gizmo)

		# Handle scene object selection

		if not raycast_query_results_gizmo and not gizmo_selected:
			if not raycast_query_results_scene_objects:
				print("remove")
				selections.clear()
				_remove_highlighted_meshes()

				return
			
			# Used for debug
			var selection_position: Vector3 = raycast_query_results_scene_objects.position
			var raycast_result_object: Node3D = raycast_query_results_scene_objects.collider.get_parent_node_3d()

			#print(raycast_result_object.name)
			
			

			if selections.is_empty():
				# Select the top node
				var selection: Selection = _make_selection_in_tree(raycast_result_object)
				#print(selection.top_level.name)
				#print(selection.selection.name)
				#print(selection.lowest_level.name)
				selections.append(selection)
			
			else:
				# Move down the selection tree if the root selection is still the same
				for selection_index: int in selections.size():
					if selections[selection_index].lowest_level == raycast_result_object:
						# Move down on the selection tree
						var new_selection: Selection = _make_selection_in_tree(
							raycast_result_object,
							selections[selection_index].top_level,
							selections[selection_index].last_level_selected
							)
						

						selections[selection_index] = new_selection
					
					else:
						
						selections.clear()
						selections.append(_make_selection_in_tree(raycast_result_object))

			for selection: Selection in selections:
				print("\n--------------")
				print("Top level: " + selection.top_level.name)
				print("Lowest level: " + selection.lowest_level.name)
				print("Last level selected: " + selection.last_level_selected.name)
				print("Selection: " + selection.selection.name)
				print("--------------")
			# Check if we've already made this specific selection
			# If we haven't pressed shift, if we already have a top_level that's equal to ours, select deeper into the tree
			# If we have pressed shift, check if we have a selection that's equal to ours
			# last_level_selected will only be used to define which node we can select further down


			
			#print(selections)


			#print(selection_object.name)
			#DebugDraw2D.set_text(raycast_query_results_scene_objects.collider.get_parent_node_3d().name)


# Still has a few issues but it's shippable, kinda...
func _make_selection_in_tree(selected_node: Node3D = null, top_level_node: Node3D = null, last_level_selected: Node3D = null) -> Selection:
	if selected_node == null:
		return null
	
	_remove_highlighted_meshes()
	var selection: Selection = Selection.new()
	if top_level_node == null:
		# Just find the top level and return that
		selection.top_level = selected_node
		selection.lowest_level = selected_node
		while selection.top_level.get_parent_node_3d() != null\
		&& selection.top_level.get_parent_node_3d() != SceneManager.scene_tree.current_scene:
			selection.top_level = selection.top_level.get_parent_node_3d()
			selection.last_level_selected = selection.top_level
			selection.selection = selection.top_level
	else:
		selection.top_level = top_level_node
		selection.last_level_selected = last_level_selected
		selection.lowest_level = selected_node
		selection.selection = selected_node

		while selection.selection.get_parent_node_3d() != null\
		&& selection.selection.get_parent_node_3d() != selection.last_level_selected\
		&& selection.selection.get_parent_node_3d() != SceneManager.scene_tree.current_scene:
			selection.selection = selection.selection.get_parent_node_3d()
		
		selection.last_level_selected = selection.selection
	
	# Highlight selected Meshinstance nodes with materials

	var selection_children: Array[Node] = selection.selection.find_children("*", "MeshInstance3D", true, false)
	#print(selection_children)

	# This is fucking stupid
	if selection.selection.get_class() == "MeshInstance3D":
		for i: int in selection.selection.mesh.get_surface_count():
			if selection.selection.get_active_material(i):
				var current_material: Material = selection.selection.get_active_material(i).duplicate()

				selection.selection.set_surface_override_material(i, current_material)
				selection.selection.get_surface_override_material(i).next_pass = selected_material

				selected_meshes.append(selection.selection)
			else:
				print("Mesh has no material")
	else:
		for meshes: MeshInstance3D in selection_children:
			for i: int in meshes.mesh.get_surface_count():
				if meshes.get_active_material(i):
					var current_material: Material = meshes.get_active_material(i).duplicate()

					meshes.set_surface_override_material(i, current_material)
					meshes.get_surface_override_material(i).next_pass = selected_material

					selected_meshes.append(meshes)
				else:
					print("Mesh has no material")

	return selection



func _remove_highlighted_meshes() -> void:
	for mesh_instance in selected_meshes:
		for surface: int in mesh_instance.mesh.get_surface_count():
			if mesh_instance.get_active_material(surface):
				mesh_instance.set_surface_override_material(surface, null)
	
	selected_meshes.clear()
				

func _change_gizmo_type(_type: String) -> void:
	pass
