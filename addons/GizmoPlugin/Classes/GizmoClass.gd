class_name GizmoClass
extends Node3D

signal gizmo_rotate(x:float, y:float, z:float, is_relative:bool)
signal gizmo_translate(x:float, y:float, z:float, is_relative:bool)
signal gizmo_scaling(x:float, y:float, z:float, is_relative:bool)


@export var is_relative: bool = false
@export var is_translation: bool
@export var is_rotation: bool
@export var is_selfhost: bool = false
@export var target: Node3D = null
@export var current_camera: Camera3D
@export var target_receiver: GizmoReceiver

func _physics_process(delta: float) -> void:
	if target != null:
		#Position of the gizmo
		position.x = target.position.x 
		position.y = target.position.y 
		position.z = target.position.z 
		rotation = target.rotation
		
		var glodist: Vector3 = current_camera.global_position - global_position
		var basesize: float = (glodist.length() * 0.2)
		if basesize < 0.3:
			basesize = 0.3
		scale.x = basesize
		scale.y = basesize
		scale.z = basesize



#---Receive input event ring
#---Receive input event ring
func input_event_axis(event:InputEvent, cur_position: Vector2, old_position: Vector2, clickpos: Vector3, axis: Vector3, transformType, is_global:bool) -> void:
	if target == null:
		return
	
	var oldpos3: Vector3 = current_camera.project_ray_normal(event.position - event.relative)
	var curpos3: Vector3 = current_camera.project_ray_normal(event.position)
	var EnumTrans: Array = ["translate","rotate","scale"]
	
	#print("    click=",clickpos, " <-> curpos=", curpos3)
	
	if transformType == 0: #---translate
		var diff:Vector3
		
		diff = (curpos3) - (oldpos3)
		
		print("**",oldpos3, " -> ", curpos3, " -> ", "diff=",diff)
		if diff.x > 0:
			diff.x = 0.1
		elif diff.x < 0:
			diff.x = -0.1
		if diff.y > 0:
			diff.y = 0.1
		elif diff.y < 0:
			diff.y = -0.1
		if diff.z > 0:
			diff.z = 0.1
		elif diff.z < 0:
			diff.z = -0.1
		
		var res = Vector3.ZERO
		var relXY = 0
		
		var istran = true
		
		res = diff * axis * Vector3(0.5, 0.5, 0.5)

		
		#---set by
#		if axis.x == 1:
#			if diff.x > 0.0:
#				res.x = -clickpos.x - (diff.x) 
#				istran = true
#			elif diff.x < 0.0:
#				res.x = clickpos.x + (diff.x)
#				istran = true
#			res.x = res.x * 0.1
#		else:
#			res.x = 0
#		istran = true
#		res.x = (
#			event.relative.x * forward.x  + 
#			event.relative.x * right.x  + 
#			event.relative.x * up.x  
#			#event.relative.y * forward.x + 
#			#event.relative.y * right.x + 
#			#event.relative.y * up.x
#			) * 0.01 * axis.x
		
#		if axis.y == 1:
#			if diff.y > 0.0:
#				res.y = -clickpos.y - (diff.y) 
#				istran = true
#			elif diff.y < 0.0:
#				res.y = clickpos.y + (diff.y)
#				istran = true
#			res.y = res.y * 0.1
#		else:
#			res.y = 0
#		istran = true
#		res.y = (
#			#event.relative.x * forward.y + 
#			#event.relative.x * right.y + 
#			#event.relative.x * up.y +
#			event.relative.y * forward.y  + 
#			event.relative.y * right.y   + 
#			event.relative.y * up.y 
#			) * 0.01 * axis.y
		
#		if axis.z == 1:
#			if diff.z > 0.0:
#				res.z = -clickpos.z - (diff.z)
#				istran = true
#			elif diff.z < 0.0:
#				res.z = clickpos.z + (diff.z)
#				istran = true
#			res.z = res.z * 0.1
#		else:
#			res.z = 0
#		istran = true
#		res.z = (
#			event.relative.x * forward.z + 
#			event.relative.x * right.z  + 
#			event.relative.x * up.z  +
#			event.relative.y * forward.z  + 
#			event.relative.y * right.z  + 
#			event.relative.y * up.z 
#			) * 0.01 * axis.z
		
		#print("  translate",res)
		if istran == true:
			#target.transform = target.transform.translated_local(res)
			if is_global == true:
				target.global_translate(res)
#				target.global_position.x = target.global_position.x + res.x
#				target.global_position.y = target.global_position.y + res.y
#				target.global_position.z = target.global_position.z + res.z
			else:
				target.translate(res)
#				target.position.x = target.position.x + res.x
#				target.position.y = target.position.y + res.y
#				target.position.z = target.position.z + res.z
			print("target=", target.name, ",  transformed position",target.position)
		
	elif transformType == 1: #---rotation
		var res: Vector3 = Vector3.ZERO
		var relXY: float = event.relative.x + event.relative.y
		if axis.x == 1:
			res.x = -target.rotation.x + relXY * 0.1
		if axis.y == 1:
			res.y = -target.rotation.y + relXY * 0.1
		if axis.z == 1:
			res.z = target.rotation.z + relXY * 0.1
		
		target.transform = target.transform.rotated_local(axis, relXY * 0.01)

func _emit_gizmo_rotate(x, y, z) -> void:
	gizmo_rotate.emit(x, y, z, is_relative)

