extends Node3D

@onready var viewport: SubViewport = $Viewport
@onready var asset_container = $AssetContainer
@onready var camera_3d = $Viewport/Camera3D


func render() -> ImageTexture:
	return ImageTexture.create_from_image(camera_3d.get_viewport().get_texture().get_image())

func add_asset(asset: Node3D) -> void:
	asset_container.add_child(asset)
	
