class_name GizmoServer
extends Node3D

#Decides what gizmo to show
var gizmo_template = preload("res://Scenes/Gizmo/Move/moveGizmo.tscn")

#Variable that holds the gizmo when its been loaded in to the scene (Class declared on tcgizmo_main)
@export var controller: GizmoClass
#---target node to operate
@export var target: Node3D = null
#---Camera node
@export var MainCamera: Camera3D
#Decides if gizmo funcitonality is enabled
@export var enable_detect: bool = true

func _ready() -> void:
#Cheks if functionality is active
	if enable_detect == true:
		#Initiates the gizmo from the scene
		controller = gizmo_template.instantiate()
		#Makes gizmo invisible
		controller.visible = false
		#Sets the camera on the gizmo class as the one on the scene
		controller.current_camera = MainCamera
		#Get how many childs there are on the scene
		var cnt = get_tree().root.get_child_count()
		#Adds gizmo to the root of the scene
		get_tree().root.get_child(cnt-1).add_child.call_deferred(controller)
	
	
	if MainCamera == null:
		MainCamera = get_parent()


#We use input here to not have to check every frame for mouse clicks
func _input(event: InputEvent) -> void:
	#Check first if gizmo is enabled
	if enable_detect != true:
		return
	
	if event is InputEventMouseButton:
		#Check if its left click
		if event.button_index == MOUSE_BUTTON_LEFT:
			#---Start drag Gizmo
			if event.pressed:
				#---Moving mouse
				var curMousePos: Vector2 = event.position
				var space_state: PhysicsDirectSpaceState3D = get_world_3d().get_direct_space_state()
				#Gets the origin/start of the ray (being the currentMousePositon)
				var from: Vector3 = MainCamera.project_ray_origin(curMousePos)
				#Gets the normal vector from the origin of the ray (direction of where the ray is going)
				var to: Vector3 = from + MainCamera.project_ray_normal(curMousePos) * 1000.0
				#---set from position and to position of ray of Camera3D
				var rayq = PhysicsRayQueryParameters3D.new()
				rayq.from = from
				rayq.to = to
				#Creates the actual ray
				var result: Dictionary = space_state.intersect_ray(rayq)
				#Checkting if the ray collied with anything
				if "collider" in result:
					#---pattern
					# 1: Node3D
					#      -> StaticBody3D                     <== detect
					#           -> Collision****3D  
					# 2: Node3D (geometry) 's "use collision"  <== detect
					# 
					var resultcoll: Object = result.collider
					var collparent: Node3D = resultcoll.get_parent_node_3d()
					
					#---collider object is same with current, skip function.
					if controller.target != null:
						if controller.target == collparent:
							return
							
					#---check parent of hit object has TransformCtrlGizmoReceiver 
					if check_TCGizmo(collparent) == false:
						#---hit object own has TransformCtrlGizmoReceiver 
						check_TCGizmo(resultcoll)

func check_TCGizmo(collparent):
	var ret: bool = false
	var ishit: int = 0 #collparent.find_children("*","TransformCtrlGizmoSelfHost",true)
	var ishit_receiver = 0
	var ccld = collparent.get_children()
	var objreceiver = null
	for cc in ccld:
		if cc.name == "TransformCtrlGizmoReceiver":
			#---node has Receiver version ?
			ishit_receiver = 1
			objreceiver = cc
		if ishit_receiver > 0:
			#--- synclonize position and rotation
			controller.position.x = collparent.position.x
			controller.position.y = collparent.position.y
			controller.position.z = collparent.position.z
			controller.rotation.x = collparent.rotation.x
			controller.rotation.y = collparent.rotation.y
			controller.rotation.z = collparent.rotation.z
			controller.current_camera = MainCamera
			controller.target = collparent
			controller.target_receiver = objreceiver
			controller.visible = true
			ret = true
	
	return ret

