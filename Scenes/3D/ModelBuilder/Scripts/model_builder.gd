extends Node3D

@onready var model: MeshInstance3D = get_node("Mesh")


var vertices: PackedVector3Array = [Vector3(-1, -1, 0), Vector3(-1, 1, 0), Vector3(1,1,0), Vector3(0,0,0)]
var triangles: PackedVector3Array = []
var indices: PackedInt32Array = []

func _ready() -> void:
		# Begin draw.
	model.mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	# Prepare attributes for add_vertex.
	model.mesh.surface_set_normal(Vector3(0, 0, 1))
	model.mesh.surface_set_uv(Vector2(0, 0))
	# Call last for each vertex, adds the above attributes.
	model.mesh.surface_add_vertex(Vector3(-1, -1, 0))

	model.mesh.surface_set_normal(Vector3(0, 0, 1))
	model.mesh.surface_set_uv(Vector2(0, 1))
	model.mesh.surface_add_vertex(Vector3(-1, 1, 0))

	model.mesh.surface_set_normal(Vector3(0, 0, 1))
	model.mesh.surface_set_uv(Vector2(1, 1))
	model.mesh.surface_add_vertex(Vector3(1, 1, 0))
	

	# End drawing.
	model.mesh.surface_end()
	
	_ear_clip_triangulation()

	model.create_trimesh_collision()


# https://www.youtube.com/watch?v=hTJFcHutls8
# Quick implementation of a simple triangulation algorithm
# TODO: Either modify this to be more distanced from the original reference or implement delaunay triangulation

func _ear_clip_triangulation() -> void:
	# Check if we have a valid vertices array

	if vertices.is_empty() || vertices.size() < 3 || !_is_simple_polygon():
		return

	indices.resize(vertices.size())

	for i: int in vertices.size():
		indices[i] = i
	
	var triangle_count: int = vertices.size() - 2
	triangles.resize(triangle_count)


	var total_triangle_index_count: int = triangle_count * 3
	var triangle_index_count: int = 0

	while indices.size() > 3:
		for i: int in indices.size():
			var current: int = indices[i]
			var previous: int = _get_item(indices, i - 1)
			var next: int = _get_item(indices, i + 1)

			var vtx_current: Vector2 = Vector2(vertices[indices[current]].x, vertices[indices[current]].y)
			var vtx_previous: Vector2 = Vector2(vertices[indices[previous]].x, vertices[indices[previous]].y)
			var vtx_next: Vector2 = Vector2(vertices[indices[next]].x, vertices[indices[next]].y)

			var vector_current_to_prev: Vector2 = vtx_previous - vtx_current
			var vector_current_to_next: Vector2 = vtx_next- vtx_current

			if vector_current_to_next.cross(vector_current_to_prev) < 0.0:
				pass
			

			for j: int in vertices.size():
				if j == current || j == previous || j == next:
					pass



func _is_point_in_triangle(point: Vector2, vtx_a: Vector2, vtx_b: Vector2, vtx_c: Vector2) -> bool:
	var vector_vtx_a_to_vtx_b: Vector2 = vtx_b - vtx_a
	var vector_vtx_b_to_vtx_c: Vector2 = vtx_c - vtx_b
	var vector_vtx_c_to_vtx_a: Vector2 = vtx_a - vtx_c


	return false

func _is_simple_polygon() -> bool:
	return true

func _contains_colinear_edges() -> bool:
	return false

func _get_item(array: Array, index: int) -> Variant:
	if index >= array.size():
		return array[index % vertices.size()]
	else: if index < 0:
		return array[index % vertices.size() + vertices.size()]
	else:
		return array[index]


	

