extends Node3D

enum TransformClass {
	MOVE,
	ROTATE,
	SCALE,
	UNDEFINED
}

enum Axis {
	X,
	Y,
	Z
}

@export var local_transform: bool = false
@export var update_planes: bool = true

@onready var type: TransformClass = TransformClass.MOVE

@onready var gizmo_move: Node3D = $Gizmo
@onready var gizmo_rotation: Node3D = $Rotation


@onready var camera: Camera3D = SceneManager.current_camera
@onready var Z_PLANE: StaticBody3D = $Gizmo.get_node("%Z_TRANSFORM_PLANE")
@onready var X_PLANE: StaticBody3D = $Gizmo.get_node("%X_TRANSFORM_PLANE")
@onready var Y_PLANE: StaticBody3D = $Gizmo.get_node("%Y_TRANSFORM_PLANE")

@onready var debug_plane_x: MeshInstance3D = MeshInstance3D.new()
@onready var debug_plane_y: MeshInstance3D = MeshInstance3D.new()
@onready var debug_plane_z: MeshInstance3D = MeshInstance3D.new()

@onready var debug_plane_mesh: PlaneMesh = PlaneMesh.new()

func _ready() -> void:
	debug_plane_x.mesh = debug_plane_mesh
	debug_plane_y.mesh = debug_plane_mesh
	debug_plane_z.mesh = debug_plane_mesh
	
	#self.add_child(debug_plane_x)
	#self.add_child(debug_plane_y)
	#self.add_child(debug_plane_z)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not local_transform:
		self.global_rotation = Vector3(0,0,0)
	
	var scale_amount: float = camera.position.distance_to(self.position)
	scale_amount = clampf(scale_amount, 0.1, 99999999.0)
	scale_amount /= 4.0
	
	#DebugDraw2D.set_text("Scale amount: ", scale_amount)

	self.scale = Vector3(scale_amount, scale_amount, scale_amount)
	
	#print(type)
	
	match type:
		TransformClass.MOVE:
			gizmo_move.show()
			gizmo_rotation.hide()
			_align_plane(Axis.X, X_PLANE)
			_align_plane(Axis.Y, Y_PLANE)
			_align_plane(Axis.Z, Z_PLANE)
		
		TransformClass.ROTATE:
			gizmo_move.hide()
			gizmo_rotation.show()
			_align_plane(Axis.Z, X_PLANE)
			_align_plane(Axis.Y, Y_PLANE) # Y needs a new plane of rotation...
			_align_plane(Axis.X, Z_PLANE)
	

func _align_plane(axis: Axis, plane: StaticBody3D, disable_camera_track: bool = false):
	if camera.position != self.position || update_planes != true:
		match axis:
			Axis.X:
				if not disable_camera_track:
					#debug_plane_x.look_at(camera.position, Vector3(1,0,0), false)
					#debug_plane_x.rotate_object_local(Vector3(1,0,0), deg_to_rad(-90))
					#debug_plane_x.rotation.y = 0
					#debug_plane_x.rotation.x = debug_plane_x.rotation.z
					#debug_plane_x.rotation.z = 0
					
					
					plane.look_at(camera.position, Vector3(1,0,0), false)
					plane.rotate_object_local(Vector3(1,0,0), deg_to_rad(-90))
					plane.rotation.y = 0
					plane.rotation.x = X_PLANE.rotation.z
					plane.rotation.z = 0
				else:
					debug_plane_x.rotation = Vector3(deg_to_rad(90), 0, 0)
					plane.rotation = Vector3(deg_to_rad(90), 0, 0)
			Axis.Y:
				if not disable_camera_track:
					#debug_plane_y.look_at(camera.position, Vector3(0,1,0), true)
					#debug_plane_y.rotate_object_local(Vector3(1,0,0), deg_to_rad(90))
					#debug_plane_y.rotation.x = deg_to_rad(90)
					
					plane.look_at(camera.position, Vector3(0,1,0), true)
					plane.rotate_object_local(Vector3(1,0,0), deg_to_rad(90))
					plane.rotation.x = deg_to_rad(90)
				else:
					debug_plane_y.rotation = Vector3(0, deg_to_rad(90), 0)
					plane.rotation = Vector3(0, deg_to_rad(90), 0)
			Axis.Z:
				if not disable_camera_track:
					#debug_plane_z.look_at(camera.position, Vector3(0, 0, 1), false)
					#debug_plane_z.rotate_object_local(Vector3(1,0,0), deg_to_rad(-90))
					#debug_plane_z.rotation.y = 0
					#debug_plane_z.rotation.x = 0
					
					plane.look_at(camera.position, Vector3(0, 0, 1), false)
					plane.rotate_object_local(Vector3(1,0,0), deg_to_rad(-90))
					plane.rotation.y = 0
					plane.rotation.x = 0
				else:
					debug_plane_z.rotation = Vector3(0,0,deg_to_rad(90))
					plane.rotation = Vector3(0,0,deg_to_rad(90))
