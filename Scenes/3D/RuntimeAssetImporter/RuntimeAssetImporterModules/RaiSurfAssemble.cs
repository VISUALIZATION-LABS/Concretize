using System.Collections.Generic;
using Godot;


namespace RAI {
	namespace RAISurfAssemble {
		public partial class RAISurfAssemble : Node {
			public static Error AssembleSurfaceMeshData(List<List<int[]>> indices, ref List<Vector3> vertexPositions, ref List<Vector3> vertexNormals, ref List<Vector2> vertexTextureCoordinates, ref Godot.Collections.Array arrayMeshData) {
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
						//surfMeshPositions.Clear();
						//surfMeshNormals.Clear();
						//surfMeshTextureCoordinates.Clear();
					} else {
						GD.PushError("ERROR::RUNTIME_ASSET_IMPORTER::OBJ::ASSEMBLE_SURFACE_MESH_DATA::CORRUPTED_MESH_DATA");
						return Error.FileCorrupt;
					}

				}

				arrayMeshData = surfaceTool.CommitToArrays();

				
				return Error.Ok;
			}
		}
	}
}
