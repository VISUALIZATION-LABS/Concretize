extends SubViewport



func render() -> ImageTexture:
	await RenderingServer.frame_post_draw
	var viewport_texture: Image = get_texture().get_image()
	return ImageTexture.create_from_image(viewport_texture)
	

func add_asset(asset: Node3D) -> void:
	$AssetContainer.add_child(asset.duplicate())
	
