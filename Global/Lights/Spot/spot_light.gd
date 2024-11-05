class_name SpotLight
extends SpotLight3D


var static_body: StaticBody3D = StaticBody3D.new()
var collider: CollisionShape3D = CollisionShape3D.new()
var icon_mesh: MeshInstance3D = MeshInstance3D.new()

# WARNING: NAME WILL BE CHANGED
var icon: Texture2D = preload("res://Art/Icons/nimbus--lightbulb.svg")
var icon_material: StandardMaterial3D = StandardMaterial3D.new()

var spot_helper: MeshInstance3D = MeshInstance3D.new()
var spot_helper_material: StandardMaterial3D = preload("res://Resources/Materials/light_helper_material.tres")
var spot_helper_collision_shape: CollisionShape3D = CollisionShape3D.new()
#var spot_helper_static_body: StaticBody3D = StaticBody3D.new()

@export var show_spot: bool = false

func _enter_tree() -> void:
	self.set_meta("selectable_children", 0)
	spot_helper.set_meta("highlightable", 0)
	icon_mesh.set_meta("highlightable", 0)
	
	self.spot_range = 5
	self.spot_attenuation = 2
	self.shadow_enabled = true
	self.light_energy = 2
	
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
	
	spot_helper.mesh = CylinderMesh.new()
	spot_helper.mesh.top_radius = 0.0
	spot_helper.rotate_x(deg_to_rad(90))
	spot_helper.mesh.surface_set_material(0, spot_helper_material)
	#spot_helper.add_child(spot_helper_static_body)
	#spot_helper_static_body.add_child(spot_helper_collision_shape)
	#spot_helper_collision_shape.shape = spot_helper.mesh.create_trimesh_shape()
	
	self.add_child(static_body)
	self.add_child(icon_mesh)
	self.add_child(spot_helper)

func _process(delta: float) -> void:
	self.spot_angle = clampf(spot_angle, 0.1, 89)
	if show_spot:
		spot_helper.show()
		spot_helper.mesh.height = self.spot_range
		spot_helper.mesh.bottom_radius = self.spot_range * tan(deg_to_rad(self.spot_angle))
		spot_helper.position.z = -spot_helper.mesh.height / 2
		
		spot_helper_material.albedo_color = Color(self.light_color, spot_helper_material.albedo_color.a)
		
		#spot_helper_collision_shape.shape = spot_helper.mesh.create_trimesh_shape()
	else:
		spot_helper.hide()
	
	icon_material.albedo_color = Color(self.light_color, 1)
	
	# Make icon face the camera
	if SceneManager.current_camera.position != self.position:
		icon_mesh.look_at(SceneManager.current_camera.position, Vector3(0,-1,0), false)
		icon_mesh.rotate_object_local(Vector3(1,0,0), deg_to_rad(-90))

func deselected() -> void:
	show_spot = false

func selected() -> void:
	show_spot = true
