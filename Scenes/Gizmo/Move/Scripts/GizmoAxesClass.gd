class_name GizmoAxes
extends Node3D

@export var axis: Vector3
@export var is_global: bool = false
enum TransformOperateType{Translate = 0, Rotate = 1, Scale = 2}
@export var TransformType: TransformOperateType
@export var basecolor: Color
@export var selcolor: Color

#Initialization shanenigans
var is_transformtype: String = ""
var old_position: Vector3 = Vector3.ZERO
var is_pressed: bool = false
var old_pressed: bool = false
var old_mousepos: Vector2 = Vector2.ZERO

var clickpos: Vector3


#---fire trigger input event Ring object
signal input_event_axis(event:InputEvent, position, old_position, clickpos:Vector3, axis: Vector3, operate_type, is_global:bool)
signal pressing_this_axis(axis: Vector3, is_pressed: bool)

func _input(event: InputEvent) -> void:
	var tcgpar = get_parent_node_3d()
	var grandpar = tcgpar.get_parent_node_3d()
	
	if (event is InputEventMouseButton):
		#---Moving mouse
		var curcam = get_parent_node_3d().current_camera
		if curcam == null:
			return
		var curMousePos = event.position
		var space_state = get_world_3d().get_direct_space_state()
		var from = curcam.project_ray_origin(curMousePos)
		var to = from + curcam.project_ray_normal(curMousePos) * 1000.0
		#---set from position and to position of ray of Camera3D
		var rayq = PhysicsRayQueryParameters3D.new()
		rayq.from = from
		rayq.to = to
		#Send a ray from mouse position
		var result = space_state.intersect_ray(rayq)
		#Checkting if the ray collied with anything
		if "collider" in result:
			var rcoll = result.collider  
			clickpos = result.position
			if rcoll.name == name:
				if TransformType == TransformOperateType.Rotate: #---rotation
					var meshobj = self
					#print(meshobj)
					mainbody(event, meshobj, "rotation")
				elif TransformType == TransformOperateType.Translate: #---translation
					var meshobj = self
					mainbody(event, meshobj, "translate")
			else:
				self.material_override.set("albedo_color",basecolor)
				#toggle_otheraxis_visible(self,true)
				is_pressed = false
				is_transformtype = ""
		else:
			self.material_override.set("albedo_color",basecolor)
			toggle_otheraxis_visible(self,true)
			is_pressed = false
			is_transformtype = ""
	
	elif (event is InputEventMouseMotion):
		var mousepos = event.position
		if is_pressed :
			#---fire input ring
			#print(event)
			input_event_axis.emit(event, mousepos, old_mousepos, clickpos, axis, TransformType, is_global)
		
		##print("event after position=",position)
		#old_position = position
		old_pressed = is_pressed
		
		old_mousepos = mousepos

func mainbody(event, meshobj, typestr: String = ""):
	if event is InputEventMouseButton:
		var mouseev: InputEventMouseButton = event
		
		#---Grab target axis UI
		if mouseev.button_index == MOUSE_BUTTON_LEFT:
			is_pressed = mouseev.pressed
			#print(is_pressed)
			
			pressing_this_axis.emit(axis, is_pressed)
			#---start transform
			if mouseev.pressed:
				meshobj.material_override.set("albedo_color",selcolor)
				toggle_otheraxis_visible(meshobj,false)
				is_transformtype = typestr
				print("---start ",typestr)
				print(name)
			else:
				#---end transform
				meshobj.material_override.set("albedo_color",basecolor)
				toggle_otheraxis_visible(meshobj,true)
				is_transformtype = ""
				print("---end ")
				

func toggle_otheraxis_visible(currentobj:Node3D,flag: bool):
#Get the parent of the currentobj
	var parobj = currentobj.get_parent_node_3d()
#Get the children of the parent
	var chobj = parobj.get_children()
	
	for obj in chobj:
		if obj.TransformType == TransformType:
			obj.visible = true
		else:
			obj.visible = flag
