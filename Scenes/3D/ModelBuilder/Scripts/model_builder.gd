extends Node3D

@onready var model: MeshInstance3D = get_node("Mesh")
@onready var collision_shape: CollisionShape3D = get_node("Mesh/StaticBody3D/CollisionShape3D")
@onready var vertex_control: Node3D = load("res://Scenes/3D/Controls/MeshBuilder/VertexControl.tscn").instantiate()
@onready var base_material: StandardMaterial3D = StandardMaterial3D.new()

# Store mesh vertex positions
var vertices: PackedVector3Array = [Vector3(-1, 0, -1), Vector3(1, 0, -1), Vector3(1, 0, 1), Vector3(-1, 0, 1)]

# Store the control nodes, which copy the vertex (non triangulated) positions
var vertex_controls: Array[Node3D] = []
# Hopefully the surfacetool triangle fan thing doesn't break when building meshes in the future

var st: SurfaceTool = SurfaceTool.new()

func _ready() -> void:
	base_material.albedo_color = Color("RED")
	for vtx_pos in vertices:
		var vtx_control: Node3D = vertex_control.duplicate()
		vtx_control.position = vtx_pos
		vertex_controls.append(vtx_control)
		add_child(vtx_control, true)
		
	SceneManager.project_scene_tree.update_tree()
	
func _process(_delta: float) -> void:
	for vtx_idx in vertex_controls.size():
		var vtx_control: Node3D = vertex_controls[vtx_idx]
		vertices[vtx_idx] = vtx_control.position
		
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	st.add_triangle_fan(vertices)
	st.set_material(base_material)
	st.generate_normals()
	#st.generate_tangents()
	
	model.mesh = st.commit()

	collision_shape.shape = model.mesh.create_trimesh_shape()

func _get_item(array: Array, index: int) -> Variant:
	if index >= array.size():
		return array[index % vertices.size()]
	else: if index < 0:
		return array[index % vertices.size() + vertices.size()]
	else:
		return array[index]


	
