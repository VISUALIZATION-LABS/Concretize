extends Node

class _material:
	var name: String
	var albedo_color: Color
	var albedo_texture: Texture3D


func parse_obj() -> void:
	var vertices: PackedVector3Array
	var vertex_normals: PackedVector3Array
	var uv_coordinates: PackedVector2Array
	
	
