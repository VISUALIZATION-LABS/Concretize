using Godot;
using RAI.RaiOBJ;
using System.Threading;
using System.Threading.Tasks;

// FIXME: This code has some ugly hacks, but perfect code doesnt ship...
// Consider fixing in the distant future


namespace RAIManager {


	public partial class RuntimeAssetImporter : Node3D
	{

		Resource objImportModule = null;
		Resource gltfImportModule = null;
		Resource imgImportModule = null;


		public override void _Ready()
		{
			// Returns some data about the importer when it finished importing a mesh
			// Filename
			// The importer node instance
			// The imported object
			AddUserSignal("ImporterFinished", new Godot.Collections.Array(){new StringName(), new Node3D(), new Node3D()});

			// Needed so numbers use dots instead of
			// commas in decimals
			Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.InvariantCulture;

		}

		// https://stackoverflow.com/questions/414981/directly-modifying-listt-elements
		private class Material {
			// General stuff for finding the material
			
			// Texture assignment

			public bool useTextures = false;
			public Color albedoColor = new(1,1,1,1);
			public ImageTexture albedoTexture = null;
			public ImageTexture normalTexture = null;
			public ImageTexture roughnessTexture = null;
			public ImageTexture metallicTexture = null;
			public float normalStrength = 1.0f;
			public float roughness = 0.5f;
			public float metallic = 0.0f;
			public float alpha = 1.0f;
		}

		private struct FileType{
			public const string obj = "obj";
			public const string glb = "glb";
			public const string gltf = "gltf";
		}

		static float Get_importer_percentage() {
			return RaiOBJ.GetPercentage();
		}
		async void Compile_mesh(string path, bool addToTree = true) {
			Node3D modelNode = new() {Name = "modelNode"};
			// First check if the path is valid

			if (!FileAccess.FileExists(path)) {
				GD.PrintErr("ERROR::RUNTIME_ASSET_IMPORTER::NON_EXISTENT_FILE");
				QueueFree();
				//return Error.FileNotFound;
			}

			modelNode.Name = path.GetFile().Split(".", false)[0];

			switch (path.GetFile().Split(".", false)[1]) {
				
				case FileType.obj:
					GD.Print("Compiling for obj");
					await Task.Run(() => { RaiOBJ.ObjMeshAssembler(ref modelNode, ref path); });
					break;
				case FileType.glb:	
					GD.Print("Compiling for glb");
					GLTFImporter(ref modelNode, ref path);
					break;
				case FileType.gltf:
					GD.Print("Compiling for gltf");
					break;
			}


			//modelNode.AddChild(m);

			if (addToTree)
				GetParent().AddChild(modelNode, true);

			//VoxelGI vgi = (VoxelGI)modelNode.GetNode("VOXELGI-AREA");	
			//vgi.Bake();


			EmitSignal("ImporterFinished", path.GetFile(), this, modelNode);

			
			//ReflectionProbe rfl = (ReflectionProbe)modelNode.GetNode("REFLECTION-AREA");
			//rfl.Position = new Vector3(rfl.Position.X, rfl.Position.Y + 0.0001f, rfl.Position.Z);
			QueueFree();
			//return Error.Ok;	
		}


		// FIXME: Doesn't load mip-maps, there are 3 possible course of actions:
		// Leave-as-is and ask for help in the Godot discord server;
		// Leave-as-is and reccomend using OBJ for now
		// Write custom implementation
		private static Error GLTFImporter(ref Node3D modelnode, ref string path) {
			GltfDocument gltfDocumentLoad = new();
			GltfState gltfStateLoad = new();
			
			Error error = gltfDocumentLoad.AppendFromFile(path, gltfStateLoad);
			if (error == Error.Ok) {
				Node gltfSceneRootNode = gltfDocumentLoad.GenerateScene(gltfStateLoad);
				
				// TODO: Investigate if this can cause problems
				modelnode = (Node3D)gltfSceneRootNode;
			} else {
				// TODO: Add better error reporting
				GD.PushError("ERROR::RUNTIME_ASSET_IMPORTER::GLTF_IMPORTER::ERROR");
				return error;
			}

			return Error.Ok;
		}
	}
}
