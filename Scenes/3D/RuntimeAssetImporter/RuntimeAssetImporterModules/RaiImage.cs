using Godot;
using System;

namespace RAI {
	namespace RAIImage {
		public partial class RAIImage : Node
		{
			public static ImageTexture TextureLoader(string path, bool isNormal) {
				Image image = new();
				Error err = image.Load(path);

				if (err != Error.Ok) {
					GD.PushError("ERROR::RUNTIME_ASSET_IMPORTER::IMAGE_LOADER::NONEXISTENT_OR_CORRUPT_IMAGE");
					
					return ImageTexture.CreateFromImage(image);
				} else {
					if (isNormal) {
						image.GenerateMipmaps(true);
						
						image.NormalMapToXy();
					} else {
						image.GenerateMipmaps();
					}
					
					return ImageTexture.CreateFromImage(image);
				}
			}
		}
	}
}
