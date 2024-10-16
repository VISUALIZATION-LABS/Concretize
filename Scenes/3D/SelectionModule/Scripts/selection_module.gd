class_name SelectionModule
extends Node3D
# This file is responsible for handling object picking, selection handling and gizmo moving

# TODO: Work on making nodes that have names that start with "_" unselecable
# FIXME: Transform position doesn't update for children, add the top_level node's position to the transform to fix this
# FIXME: Properly document and plan out the selection algorithm (few bugs)

# -- Data section --

# Since this is a component, the camera will not be gotten from the viewport
@export var camera: Camera3D

@onready var gizmo_move: Node3D = preload("res://Scenes/3D/Controls/Gizmo/LiveGizmo.tscn").instantiate()
@onready var selected_material: Resource = preload("res://Resources/Shaders/3D/SelectionHighlight.tres")

# -- Raycast parameters --

const RAY_LENGHT: float = 9_999.0

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

# hack
var select_action_pressed: bool = false

class Selection:
	var selected_node: Node = null
	var child_meshes: Array[MeshInstance3D]

var selections: Array[Selection] = []
var selection_group_start: Node3D = null
var selection_group_end: Node3D = null
var last_selected_object: Node3D = null
var selected_meshes: Array[MeshInstance3D] = []
var gizmo_selected: bool = false



# This is used for calculating a delta_mouse parameter for transformations
var previous_mouse_coordinates: Vector3 = Vector3(0,0,0)

enum TransformClass {
	MOVE,
	ROTATE,
	SCALE,
	UNDEFINED
}

enum TransformType {
	X,
	Y,
	Z,
	ALL,
	UNDEFINED
}

var current_transform: TransformType = TransformType.UNDEFINED
var current_type: TransformClass = TransformClass.MOVE 

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
	SceneManager.project_scene_tree.selections = selections
	if Input.is_action_pressed("selection_make"):
		if camera == null:
			push_error("ERROR::SELECTION_MODULE::CAMERA_NULL")
			return
		
		# -- Selection handling --

		var mouse_position: Vector2 = SceneManager.current_viewport.get_mouse_position()
		
		# Block mouse inputs outside of current viewport
		if mouse_position.x < 0 || mouse_position.y < 0 || mouse_position.x > SceneManager.current_viewport.size.x || mouse_position.y > SceneManager.current_viewport.size.y - 32:
			if not gizmo_selected:
				print("I MUST RENTUTTUTU")
				return

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
			if not select_action_pressed:
				select_action_pressed = true
				if not raycast_query_results_scene_objects:
					for selection: Selection in selections:
						_unhighlight_meshes(selection.child_meshes)
					
					selections.clear()
					#_unhighlight_meshes(selected_meshes)
					#selected_meshes.clear()

					selection_group_start = null
					selection_group_end = null
					last_selected_object = null

					gizmo_move.hide()
					return

				if not Input.is_action_pressed("modifier_0"):
					for selection: Selection in selections:
						_unhighlight_meshes(selection.child_meshes)
						
					selections.clear()
					#_unhighlight_meshes(selected_meshes)
					#selected_meshes.clear()

				selection_group_end = raycast_query_results_scene_objects.collider.get_parent_node_3d()
				
				if not Input.is_action_pressed("modifier_1"):
					selection_group_start = null

				var selection_data: Dictionary = _make_selection(selection_group_start, selection_group_end, last_selected_object)
				
				selection_group_start = selection_data.selection_group_start
				last_selected_object = selection_data.last_selection

				selections.append(selection_data.selection_object)
				
				#SceneManager.set_selected_items(selections)
				
				SceneManager.project_scene_tree.set_selections(selections)
				
				gizmo_move.show()
		else:
			# -- Gizmo control --
			var collision_mask: int = 0
			var mouse_transform_mask: Vector3 = Vector3(1,1,1)
			var raycast_gizmo_object: Node3D = null
			var delta_mouse_position: Vector3 = Vector3(0,0,0)

			# Get selected gizmo axis
			if raycast_query_results_gizmo and not gizmo_selected:
				raycast_gizmo_object = raycast_query_results_gizmo.collider.get_parent_node_3d()

				match raycast_gizmo_object.name:
					"X_Axis":
						current_transform = TransformType.X

					"Y_Axis":
						current_transform = TransformType.Y

					"Z_Axis":
						current_transform = TransformType.Z

					"Global_Move":
						current_transform = TransformType.ALL

			
			match current_transform:
				TransformType.X:
					collision_mask = X_TRANSFORM_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(1,0,0)
				TransformType.Y:
					collision_mask = Y_TRANSFORM_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(0,1,0)
				TransformType.Z:
					collision_mask = Z_TRANSFORM_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(0,0,1)
				TransformType.ALL:
					collision_mask = VIEW_TRANSFORM_PLANE_COLLISION_MASK
					mouse_transform_mask = Vector3(1,1,1)

			# Project mouse to move gizmo in 3D
			var mouse_raycast_position_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
				raycast_origin,
				raycast_end,
				collision_mask
			)

			var mouse_raycast_position_query_result: Dictionary = space_state.intersect_ray(mouse_raycast_position_query)

			if mouse_raycast_position_query_result:
				var mouse_projected_position: Vector3 = mouse_raycast_position_query_result.position

				delta_mouse_position = mouse_projected_position - previous_mouse_coordinates
				previous_mouse_coordinates = mouse_projected_position

				if not gizmo_selected:
					delta_mouse_position = Vector3(0,0,0)

				gizmo_selected = true

				DebugDraw2D.set_text("Delta mouse:", delta_mouse_position)

				match current_type:
					TransformClass.MOVE:
						for selection: Selection in selections:
							selection.selected_node.position += delta_mouse_position * mouse_transform_mask

					TransformClass.SCALE:
						for selection: Selection in selections:
							selection.selected_node.scale += delta_mouse_position * mouse_transform_mask	
					
					TransformClass.ROTATE:
						for selection: Selection in selections:
							selection.selected_node.rotation += delta_mouse_position * mouse_transform_mask
							
				gizmo_move.position += delta_mouse_position * mouse_transform_mask
				#DebugDraw3D.draw_square(mouse_projected_position, 0.03, Color("GREEN"), 10)
	else:
		# -- if Input.is_action_pressed("selection_make"): --
		gizmo_selected = false
		select_action_pressed = false
	
	if not selections.is_empty() && Input.is_action_just_pressed("delete"):
		var selections_to_be_removed: Array[Selection] = [] 
		for selection: Selection in selections:
			# First clean all mesh children and unhighlight them
			_unhighlight_meshes(selection.child_meshes)
			selection.child_meshes.clear()
			
			# Then kill the selected node
			selection.selected_node.free()
			selections_to_be_removed.append(selection)
		
		for selection: Selection in selections_to_be_removed:
			selections.erase(selection)
		
		last_selected_object = null
		
		SceneManager.project_scene_tree.update_tree()
		
		# If we have no more selections, hide the active gizmo
		if selections.is_empty():
			gizmo_selected = false
			gizmo_move.hide()
	
	if not selections.is_empty() && Input.is_action_just_pressed("duplicate"):
		for selection: Selection in selections:
			selection.selected_node.add_sibling(selection.selected_node.duplicate(), true)
		
		SceneManager.project_scene_tree.update_tree()
	
	
	# Position gizmo to middle of all selections

	var average_position: Vector3 = Vector3(0,0,0)

	if not selections.is_empty():
		for selection: Selection in selections:
			if selection != null:
				average_position += selection.selected_node.position
		
		average_position /= selections.size()

	gizmo_move.position = average_position
				
func _make_selection(sel_group_start: Node3D = null, sel_group_end: Node3D = null, last_sel: Node3D = null) -> Dictionary:	
	var selection_data: Dictionary = {
		"selection_group_start": null,
		"last_selection": null,
		"selected_object": null,
		"selection_object": null
	}

	if sel_group_end == null:
		push_error("ERROR::SELECTION_MODULE::NO_AVAILABLE_SELECTION_DATA")
		return selection_data

	var selection_object: Selection = Selection.new()

	# Go up the scene tree
	if sel_group_start == null || last_sel == null:
		# Go up until scene node
		sel_group_start = sel_group_end

		while sel_group_start.get_parent_node_3d() != SceneManager.scene_tree.current_scene && sel_group_start.get_parent_node_3d() != null:
			sel_group_start = sel_group_start.get_parent_node_3d()

		selection_data.selection_group_start = sel_group_start
		selection_data.last_selection = sel_group_start
		selection_data.selected_object = sel_group_start
	else:
		# Go up until the child of last selection
		# We go up from the selection end node because branching is a possibility
		var selected_object: Node3D = sel_group_end

		while selected_object.get_parent_node_3d() != last_sel && selected_object.get_parent_node_3d() != sel_group_start && selected_object.get_parent_node_3d() != null:
			selected_object = selected_object.get_parent_node_3d()
			
		selection_data.selection_group_start = sel_group_start
		selection_data.last_selection = selected_object
		selection_data.selected_object = selected_object
	
	selection_object.selected_node = selection_data.selected_object
	selection_data.selection_object = selection_object
	# Highlight any meshinstance 3D nodes under selected_object

	_find_mesh_children(selection_object)

	_highlight_meshes(selection_object.child_meshes)

	return selection_data

func _find_mesh_children(selection: Selection) -> void:
	var mesh_instances: Array[Node] = selection.selected_node.find_children("*", "MeshInstance3D", true, false)

	for mesh_instance in mesh_instances:
		selection.child_meshes.append(mesh_instance)

	if selection.selected_node.get_class() == "MeshInstance3D":
		selection.child_meshes.append(selection.selected_node)

func _highlight_meshes(meshes: Array[MeshInstance3D]) -> void:
	for mesh_instance: MeshInstance3D in meshes:
		for surface: int in mesh_instance.mesh.get_surface_count():
			if mesh_instance.get_active_material(surface):
					var current_material: Material = mesh_instance.get_active_material(surface).duplicate()

					mesh_instance.set_surface_override_material(surface, current_material)
					mesh_instance.get_surface_override_material(surface).next_pass = selected_material

func _unhighlight_meshes(meshes: Array[MeshInstance3D]) -> void:
	for mesh_instance: MeshInstance3D in meshes:
		for surface: int in mesh_instance.mesh.get_surface_count():
			if mesh_instance.get_active_material(surface):
				mesh_instance.set_surface_override_material(surface, null)

func _change_gizmo_type(type: String) -> void:
	match type:
		"Translate":
			current_type = TransformClass.MOVE
		"Rotate":
			current_type = TransformClass.ROTATE
