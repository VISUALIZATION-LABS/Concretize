using Godot;
using Godot.NativeInterop;
using Microsoft.Win32;
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Common;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection.Metadata;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks.Dataflow;

public partial class RuntimeAssetImporter : Node3D
{

	public override void _Ready()
	{
		// Needed so numbers use dots instead of
        // commas in decimals

        Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.InvariantCulture;

	}

	// TODO: Investigate if class is the best choise, may eat a lot of memory with a lot of materials
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
				ObjMeshAssembler(ref modelNode, ref path);
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
	
	private static Error ObjMeshAssembler(ref Node3D modelNode, ref string path){
		// Bad, will change original variable. Either remove ref or figure out a better way
		path = path.Replace('\\','/');

		string[] dataLine = FileAccess.Open(path, FileAccess.ModeFlags.Read).GetAsText().Split('\n', StringSplitOptions.None);

		// Mesh data
		List<Vector3> vertexPositions = new();
		List<Vector3> vertexNormals = new();
		List<Vector2> vertexTextureCoordinates = new();

		//List<List<int[]>> indices = new();

		string currentMaterial = "DefaultSurface";

		Dictionary<string, StandardMaterial3D> materials = new();
		Dictionary<string, List<List<int[]>>> surfDict = new();
        //{
        //    { currentMaterial, new List<List<int[]>>() }
        //};

		List<Godot.Collections.Array> surfaces = new();

		ArrayMesh arrayMesh = new();
		Godot.Collections.Array arrayMeshData = new();
		arrayMeshData.Resize((int)Mesh.ArrayType.Max);

		foreach (string line in dataLine) {
			string[] token = line.Split(' ', StringSplitOptions.None);

			switch (token[0]) {
				case "#":
					GD.Print(token[1..].ToArray());
					break;
				case "mtllib":
					string mtllibPath = token[1];
					mtllibPath = path[..path.LastIndexOf("/")] + '/' + mtllibPath;
					GD.Print($"Opening mtllib file at {mtllibPath}");
					ObjMaterialAssembler(ref materials, ref mtllibPath);
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
				
				case "usemtl":
					currentMaterial = token[1];
					surfDict.Add(currentMaterial, new List<List<int[]>>());
					break;

				case "f":
					// Conversion is needed to "reverse" mesh data without mirroring the mesh

					token = token[1..].ToArray();
					List<int[]> facedef = new();

					foreach (string idxGroup in token) {
						string[] idx = idxGroup.Split('/', StringSplitOptions.None);

						int[] idxArray = {int.Parse(idx[0]) - 1, int.Parse(idx[1]) - 1, int.Parse(idx[2]) - 1};
						facedef.Add(idxArray);
					}

					surfDict[currentMaterial].Add(facedef);
					break;
			} // Switch ends here
		} // Foreach ends here		

		int surfIdx = -1;
		foreach(string surfDef in surfDict.Keys) {
			surfIdx++;

			Godot.Collections.Array surfaceArrayData = new();
			AssembleSurfaceMeshData(surfDict[surfDef], ref vertexPositions, ref vertexNormals, ref vertexTextureCoordinates, ref surfaceArrayData);
			arrayMesh.AddSurfaceFromArrays(Mesh.PrimitiveType.Triangles, surfaceArrayData);
			arrayMesh.SurfaceSetName(surfIdx, surfDef);
			arrayMesh.SurfaceSetMaterial(surfIdx, materials[surfDef]);
		}
		
		MeshInstance3D meshObject = new();
		
		meshObject.Mesh = arrayMesh;
		
		modelNode.AddChild(meshObject);
		


        return Error.Ok;
	}


	
	// Assembles meshes with SurfaceTool for mesh triangulation.
	private static Error AssembleSurfaceMeshData(List<List<int[]>> indices, ref List<Vector3> vertexPositions, ref List<Vector3> vertexNormals, ref List<Vector2> vertexTextureCoordinates, ref Godot.Collections.Array arrayMeshData) {
		SurfaceTool surfaceTool = new();
		surfaceTool.Begin(Mesh.PrimitiveType.Triangles);
		foreach (List<int[]> faceDef in indices) {
			if (faceDef.Count  == 3) {
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
				surfMeshPositions.Clear();
				surfMeshNormals.Clear();
				surfMeshTextureCoordinates.Clear();
			} else {
				GD.PushError("ERROR::RUNTIME_ASSET_IMPORTER::OBJ::ASSEMBLE_SURFACE_MESH_DATA::CORRUPTED_MESH_DATA");
				return Error.FileCorrupt;
			}

		}

		arrayMeshData = surfaceTool.CommitToArrays();

		
		return Error.Ok;
	}

	private static Error ObjMaterialAssembler(ref Dictionary<string, StandardMaterial3D> materials, ref string path) {
		Dictionary<string, StandardMaterial3D> internalMaterialDict = new();

		// TODO: Implement a texture lookup database to avoid loading repeats
		// Could work by storing the currentMaterial name and the texture paths it holds, so any subsequent
		// materials can just "steal" from the original without loading from disk

		string[] dataLine = FileAccess.Open(path, FileAccess.ModeFlags.Read).GetAsText().Split('\n', StringSplitOptions.None);
		string currentMaterial = "DefaultMaterial";
		string texturePath = "";
		foreach (string line in dataLine) {
			string[] token = line.Split(' ', StringSplitOptions.None);

			switch (token[0]) {
				case "newmtl":
					GD.Print($"Creating material definition for {token[1]}");
					currentMaterial = token[1];

					internalMaterialDict.Add(currentMaterial, new StandardMaterial3D());

					// TODO: Check if material names (for newmtl) can have spaces

					break;
				case "Ns":
					internalMaterialDict[currentMaterial].Roughness = float.Parse(token[1]);
					break;

				case "Pr":
					internalMaterialDict[currentMaterial].Roughness = float.Parse(token[1]);
					break;
				
				case "Pm":
					internalMaterialDict[currentMaterial].Metallic = float.Parse(token[1]);
					break;
				
				case "Ka":
					//GD.PushWarning("MTL \"Ka\" definition is unused for this renderer.");
					break;
				case "Kd":
					internalMaterialDict[currentMaterial].AlbedoColor = new Color(
						float.Parse(token[1]),
						float.Parse(token[2]),
						float.Parse(token[3])
					);
					break;
				case "Ks":
					float specExp = internalMaterialDict[currentMaterial].Roughness;
                    float specCoeff = float.Parse(token[1]);

                    // FIXME: This approximation is not good enough
                    float approxRough = (float)Mathf.Clamp(specExp/(1000*specCoeff), 0.0, 1.0);
                    internalMaterialDict[currentMaterial].Roughness = approxRough;

                    GD.Print($"Approximated roughness for {currentMaterial} = {internalMaterialDict[currentMaterial].Roughness}");
					GD.PushWarning("Using approximated roughness for non-PBR OBJ materials is not reccomended, re-export the mesh with PBR extensions enabled.");
					break;
				case "d":
					float alpha = float.Parse(token[1]);
					if (alpha < 1.0) {
						internalMaterialDict[currentMaterial].AlbedoColor = new Color(internalMaterialDict[currentMaterial].AlbedoColor, alpha);
						internalMaterialDict[currentMaterial].Transparency = Godot.BaseMaterial3D.TransparencyEnum.Alpha;
					}
					break;
				case "map_Kd":
	
					if (texturePath.IsAbsolutePath()) {
						internalMaterialDict[currentMaterial].AlbedoTexture = TextureLoader(token[1..].ToString(), false);
					} else if (texturePath.IsRelativePath()) {
						texturePath = path.GetBaseDir().PathJoin(texturePath);
						internalMaterialDict[currentMaterial].AlbedoTexture = TextureLoader(path.GetBaseDir().PathJoin(token[1..].ToString()), false);
					}
					break;
				case "map_refl" or "map_Pm":
					if (texturePath.IsAbsolutePath()) {
						internalMaterialDict[currentMaterial].RoughnessTexture = TextureLoader(token[1..].ToString(), false);
					} else if (texturePath.IsRelativePath()) {
						texturePath = path.GetBaseDir().PathJoin(texturePath);
						internalMaterialDict[currentMaterial].RoughnessTexture = TextureLoader(path.GetBaseDir().PathJoin(token[1..].ToString()), false);
					}
					break;
				case "map_Bump":
					ushort tokenIndex = 1;

					if (token.Contains("-bm")) {
						tokenIndex = 3;
						internalMaterialDict[currentMaterial].NormalScale = float.Parse(token[2]);
					}
					if (texturePath.IsAbsolutePath()) {
						internalMaterialDict[currentMaterial].NormalTexture = TextureLoader(token[tokenIndex..].ToString(), true);
					} else if (texturePath.IsRelativePath()) {
						texturePath = path.GetBaseDir().PathJoin(texturePath);
						internalMaterialDict[currentMaterial].NormalTexture = TextureLoader(path.GetBaseDir().PathJoin(token[tokenIndex..].ToString()), true);
					}
					break;
			}
		}

		// Copy
		foreach (string materialName in internalMaterialDict.Keys) {
			materials.Add(materialName, internalMaterialDict[materialName]);
		}
		return Error.Ok;
	}

	private static ImageTexture TextureLoader(string path, bool isNormal) {
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