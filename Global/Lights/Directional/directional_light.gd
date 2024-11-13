class_name DirectionalLight
extends DirectionalLight3D


var static_body: StaticBody3D = StaticBody3D.new()
var collider: CollisionShape3D = CollisionShape3D.new()
var icon_mesh: MeshInstance3D = MeshInstance3D.new()

# WARNING: NAME WILL BE CHANGED
var icon: Texture2D = preload("res://Art/Icons/nimbus--lightbulb.svg")
var icon_material: StandardMaterial3D = StandardMaterial3D.new()

var directional_helper: MeshInstance3D = MeshInstance3D.new()
var directional_helper_material: StandardMaterial3D = preload("res://Resources/Materials/light_helper_material.tres").duplicate()
var directional_helper_collision_shape: CollisionShape3D = CollisionShape3D.new()
#var spot_helper_static_body: StaticBody3D = StaticBody3D.new()

@export var show_help: bool = false

func _ready() -> void:
	
	# HACK
	if self.get_child_count() > 0:
		for child: Node3D in self.get_children():
			child.queue_free()
		
	self.set_meta("selectable_children", 0)
	directional_helper.set_meta("highlightable", 0)
	icon_mesh.set_meta("highlightable", 0)
	
	self.light_energy = 3.0
	
	# TODO: Convert the color string to rgb
	
	self.light_color = Color("fff1dc")
	self.shadow_enabled = true
	
	collider.shape = BoxShape3D.new()
	collider.shape.size = Vector3(1, 1, 1)
	
	static_body.add_child(collider)
	
	icon_mesh.mesh = PlaneMesh.new()
	icon_mesh.mesh.size /= 2
	icon_mesh.mesh.surface_set_material(0, icon_material)
	icon_material.albedo_texture = icon
	icon_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	icon_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	icon_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	
	directional_helper.mesh = BoxMesh.new()
	directional_helper.mesh.size = Vector3(0.2,2,0.2)
	directional_helper.position.z = -1
	directional_helper.rotate_x(deg_to_rad(90))
	directional_helper.mesh.surface_set_material(0, directional_helper_material)
	#spot_helper.add_child(spot_helper_static_body)
	#spot_helper_static_body.add_child(spot_helper_collision_shape)
	#spot_helper_collision_shape.shape = spot_helper.mesh.create_trimesh_shape()
	
	self.add_child(static_body)
	self.add_child(icon_mesh)
	self.add_child(directional_helper)

func _process(delta: float) -> void:
	if show_help:
		directional_helper.show()
		#diectional_helper.position.z = -directional_helper.mesh.height / 2
		
		directional_helper_material.albedo_color = Color(self.light_color, directional_helper_material.albedo_color.a)
		
		#spot_helper_collision_shape.shape = spot_helper.mesh.create_trimesh_shape()
	else:
		directional_helper.hide()
	
	icon_material.albedo_color = Color(self.light_color, 1)
	
	# Make icon face the camera
	if SceneManager.current_camera.position != self.position:
		icon_mesh.look_at(SceneManager.current_camera.position, Vector3(0,-1,0), false)
		icon_mesh.rotate_object_local(Vector3(1,0,0), deg_to_rad(-90))

func deselected() -> void:
	show_help = false

func selected() -> void:
	show_help = true
