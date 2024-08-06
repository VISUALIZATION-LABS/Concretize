using Godot;
using Godot.NativeInterop;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;

public partial class RuntimeAssetImporter : Node3D
{

	public override void _Ready()
	{
		// Needed so numbers use dots instead of
        // commas in decimals

        Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.InvariantCulture;

	}

	private struct Material {
        // General stuff for finding the material

        string name = "";
        
        // Texture assignment

        bool useTextures = false;
        Color albedoColor = new(1,1,1,1);
        ImageTexture albedoTexture = null;
        ImageTexture normalTexture = null;
        ImageTexture roughnessTexture = null;
        ImageTexture metallicTexture = null;
        float normalStrength = 1.0f;
        float roughness = 0.5f;
        float metallic = 0.0f;
        float alpha = 1.0f;

        // Material constructor

        public Material() {}
    }

	private struct FileType{
		public const string obj = "obj";
		public const string glb = "glb";
		public const string gltf = "gltf";
	}

	
    Error Compile_mesh(string path) {
        Node3D modelNode = new() {Name = "modelNode"};
		// First check if the path is valid

		if (!FileAccess.FileExists(path)) {
			GD.PrintErr("ERROR::RUNTIME_ASSET_IMPORTER::NON_EXISTENT_FILE");
			return Error.FileNotFound;
		}



		switch (path.GetFile().Split(".", false)[1]) {
			case FileType.obj:
				GD.Print("Compiling for obj");
				string data = FileAccess.Open(path, FileAccess.ModeFlags.Read).GetAsText();
				ObjMeshAssembler(ref modelNode, ref data);
				break;
			case FileType.glb:	
				GD.Print("Compiling for glb");
				break;
			case FileType.gltf:
				GD.Print("Compiling for gltf");
				break;
		}



		//var m = new MeshInstance3D() {
		//	Mesh = arrayMesh
		//};


		//modelNode.AddChild(m);

		


		GetParent().AddChild(modelNode);
		QueueFree();
		return Error.Ok;
    }
	
	private static Error ObjMeshAssembler(ref Node3D modelNode, ref String data) {
		// Philosophy this time will be: use more memory and avoid disk reads
		// avoid duplicating memory and a few more CPU cycles are ok, this is
		// not run often enough where this'll be an issue
		// -F

		// Mesh data
		List<Vector3> vertexPositions = new();
		List<Vector3> vertexNormals = new();
		List<Vector2> vertexTextureCoordinates = new();

		List<List<int[]>> indices = new();

		ArrayMesh arrayMesh = new();
		Godot.Collections.Array arrayMeshData = new();
		arrayMeshData.Resize((int)Mesh.ArrayType.Max);

		string[] dataLine = data.Split('\n', StringSplitOptions.None);
		foreach (string line in dataLine) {
			string[] token = line.Split(' ', StringSplitOptions.None);

			switch (token[0]) {
				case "#":
					GD.Print(token.Skip(1).ToArray());
					break;
				case "o":
					GD.Print($"Creating object for {token[1]}");
					break;
				case "v":
                    vertexPositions.Add(new Vector3(
                        float.Parse(token[1]),
                        float.Parse(token[2]),
                        float.Parse(token[3])
					));
					break;
				case "vn":
					vertexNormals.Add(new Vector3(
						float.Parse(token[1]),
                        float.Parse(token[2]),
                        float.Parse(token[3])
					));
					break;
				case "vt":
					vertexTextureCoordinates.Add(new Vector2(
						float.Parse(token[1]),
                        -float.Parse(token[2])
					));
					break;
				case "s":

					// FIXME: This actually means "smooth" in the OBJ standard

					
					break;
				case "f":
					// Conversion is needed to "reverse" mesh data without mirroring the mesh

					token = token.Skip(1).ToArray();
					List<int[]> facedef = new();

					foreach (string idxGroup in token) {
						// We add nf to the end of every single idxGroup
						// so we know when a face declaration ends

						string[] idx = idxGroup.Split('/', StringSplitOptions.None);

						int[] idxArray = {int.Parse(idx[0]) - 1, int.Parse(idx[1]) - 1, int.Parse(idx[2]) - 1};
						facedef.Add(idxArray);
					}

					indices.Add(facedef);
					break;
			} // Switch ends here
		} // Foreach ends here		

		//arrayMeshData[(int)Mesh.ArrayType.Vertex] = currentVertices.ToArray();
		//indices.Reverse();

		AssembleSurfaceMeshData(ref indices, ref vertexPositions, ref vertexNormals, ref vertexTextureCoordinates, ref arrayMeshData);

		Image uvCheckerboardImage = new();

		uvCheckerboardImage.Load("res://Art/Debug/3D/uvgrid.png");

		Texture2D uvCheckerboardTexture = ImageTexture.CreateFromImage(uvCheckerboardImage);
		
		arrayMesh.AddSurfaceFromArrays(Mesh.PrimitiveType.Triangles, arrayMeshData);
		arrayMesh.SurfaceSetMaterial(0, new StandardMaterial3D() {AlbedoTexture = uvCheckerboardTexture});			
		
		MeshInstance3D meshObject = new();
		
		meshObject.Mesh = arrayMesh;
		
		modelNode.AddChild(meshObject);


        return Error.Ok;
	}


	
	// Assembles meshes with SurfaceTool for mesh triangulation.
	private static Error AssembleSurfaceMeshData(ref List<List<int[]>> indices, ref List<Vector3> vertexPositions, ref List<Vector3> vertexNormals, ref List<Vector2> vertexTextureCoordinates, ref Godot.Collections.Array arrayMeshData) {
		SurfaceTool surfaceTool = new();
		surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

		foreach (List<int[]> faceDef in indices) {
			if (faceDef.Count < 4) {
				for (int i = faceDef.Count - 1; i >= 0; i--) {
					surfaceTool.SetUV(vertexTextureCoordinates[faceDef[i][1]]);
					surfaceTool.SetNormal(vertexNormals[faceDef[i][2]]);
					surfaceTool.AddVertex(vertexPositions[faceDef[i][0]]);
					
				}
			} else if (faceDef.Count > 3) {
				List<Vector3> surfMeshPositions = new();
				List<Vector3> surfMeshNormals = new();
				List<Vector2> surfMeshTextureCoordinates = new();
				for (int i = faceDef.Count - 1; i >= 0; i--) {
					surfMeshPositions.Add(vertexPositions[faceDef[i][0]]);
					surfMeshNormals.Add(vertexNormals[faceDef[i][2]]);
					surfMeshTextureCoordinates.Add(vertexTextureCoordinates[faceDef[i][1]]);
				}
				surfaceTool.AddTriangleFan(surfMeshPositions.ToArray(), surfMeshTextureCoordinates.ToArray(), null, null, surfMeshNormals.ToArray());
				//surfaceTool.AddTriangleFan(fullMeshPositions.ToArray(), fullMeshVertexTextures.ToArray(), null, null, fullMeshNormals.ToArray());
				surfMeshPositions.Clear();
				surfMeshNormals.Clear();
				surfMeshTextureCoordinates.Clear();
			}

		}

		arrayMeshData = surfaceTool.CommitToArrays();

		
		return Error.Ok;
	}

	private static Error ObjMaterialAssembler(ref Material material) {

		return Error.Ok;
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		
	}
}