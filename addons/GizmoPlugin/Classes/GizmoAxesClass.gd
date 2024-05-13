#class_name GizmoAxesClass
extends Node3D
#
#@export var axis: Vector3
#@export var is_global: bool = false
#enum TransformOperateType{Translate = 0, Rotate = 1, Scale = 2}
#@export var TransformType: TransformOperateType
#@export var basecolor: Color
#@export var selcolor: Color
#
##Initialization shanenigans
#var is_transformtype: String = ""
#var old_position: Vector3 = Vector3.ZERO
#var is_pressed: bool = false
#var old_pressed: bool = false
#var old_mousepos: Vector2 = Vector2.ZERO
#var clickpos: Vector3
#
#
##---fire trigger input event Ring object
#signal input_event_axis(event:InputEvent, position, old_position, clickpos:Vector3, axis: Vector3, operate_type, is_global:bool)
#signal pressing_this_axis(axis: Vector3, is_pressed: bool)
#
#
#func _input(event: InputEvent) -> void:
## Get the gizmo node
	#var tcgpar: Node3D = get_parent_node_3d()
## Get the parent of the gizmo node (Root in this case)
	#var grandpar: Node3D = tcgpar.get_parent_node_3d()
	#
	#if (event is InputEventMouseButton):
	##Moving the mouse logic
		##Get the camera of the gizmo
		#var curcam: Camera3D = get_parent_node_3d().current_camera
		##Check if you got a camera
		#if curcam == null:
			#return
		##Get mouse position
		#var curMousePos: Vector2 = event.position
		##Gets the space state from the world
		#var space_state: PhysicsDirectSpaceState3D = get_world_3d().get_direct_space_state()
		##Gets the origin/start of the ray (being the currentMousePositon)
		#var from: Vector3 = curcam.project_ray_origin(curMousePos)
		##Gets the normal vector from the origin of the ray (direction of where the ray is going)
		#var to: Vector3 = from + curcam.project_ray_normal(curMousePos) * 1000.0
		##---set from position and to position of ray of Camera3D
		#var rayq = PhysicsRayQueryParameters3D.new()
		#rayq.from = from
		#rayq.to = to
		##Creates the actual ray
		#var result: Dictionary = space_state.intersect_ray(rayq)
		##Checkting if the ray collied with anything
		#if "collider" in result:
			##gets who collieded
			#var resultcoll: Object = result.collider  
			##gets where it was clicked on the screen
			#clickpos = result.position
			##Check if the name of the collider is the same as the one selected
			#print(name)
			#print(resultcoll.name)
			#if resultcoll.name == name:
			##Selector for which mode to use
				##Check if Transform type of axis clicked is equal to the one equivalent to rotation
				##Obs: type is declared on the axis itself
				##Also probably there is a better way to do this
				#if TransformType == TransformOperateType.Rotate: #---rotation
					#var meshobj: Object = self
					##Send event information, axis clicked and the transform type
					#mainbody(event, meshobj, "rotation")
				##Check if Transform type of axis clicked is equal to the one equivalent to translation
				#elif TransformType == TransformOperateType.Translate: #---translation
					#var meshobj: Object = self
					##Send event information, axis clicked and the transform type
					#mainbody(event, meshobj, "translate")
			##I still have no fucking idea what this means honestly
			#else:
				#is_pressed = false
				#is_transformtype = ""
		#else:
			##Makes all axis visible
			#toggle_otheraxis_visible(self,true)
			#is_pressed = false
			#is_transformtype = ""
	##Runs when the mouse if moving
	#elif (event is InputEventMouseMotion):
		#var mousepos: Vector2 = event.position
		##Waits until mouse is pressed for the first time
		#if is_pressed :
			##Send signal with mouse moviment and position and everything
			#input_event_axis.emit(event, mousepos, old_mousepos, clickpos, axis, TransformType, is_global)
		##Saves current information in variable
		#old_pressed = is_pressed
		#old_mousepos = mousepos
#
##Recieves the event (information about the mouse) the obj that collided and the transform type
#func mainbody(event, meshobj, typestr: String = ""):
	#if event is InputEventMouseButton:
		#var mouseevent: InputEventMouseButton = event
		#
		##---Grab target axis UI
		#if mouseevent.button_index == MOUSE_BUTTON_LEFT:
			##Sets is pressed to true if mouse if being pressed
			#is_pressed = mouseevent.pressed
			##Sends signal saying which axis is being pressed
			#pressing_this_axis.emit(axis, is_pressed)
			##---start transform
			##mouse is being pressed
			#if mouseevent.pressed:
				##Let only the selected transform type visible
				#toggle_otheraxis_visible(meshobj,false)
				#is_transformtype = typestr
				#print("---start ",typestr)
				#print(name)
			#else:
				##---end transform
				##mouse stop being pressed
				##Makes every axis visible
				#toggle_otheraxis_visible(meshobj,true)
				##Removes the transform type from the variable
				#is_transformtype = ""
				#print("---end ")
#
#func toggle_otheraxis_visible(currentobj:Node3D,flag: bool):
##Get the parent of the currentobj
	#var parobj: Object = currentobj.get_parent_node_3d()
##Get the children of the parent
	#var chobj: Array = parobj.get_children()
	##Loops every node in scene
	#for obj in chobj:
		##Checks if the transform type of that object is the one being selected make it visible
		#if obj.TransformType == TransformType:
			#obj.visible = true
		#else:
			##If its not the same transform type toggle visibility according to what flag says (true or false)
			#obj.visible = flag
#
