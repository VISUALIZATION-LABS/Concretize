using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using Godot;		
using RAI.RAIImage;
using RAIManager;
using RAI.RAISurfAssemble;
using System.Security.AccessControl;

namespace RAI {
	namespace RaiOBJ {
		public partial class RaiOBJ : Node
		{

			private static float percentageFileRead = 0;
			private static float totalLines = 1;
			private static int linesRead = 0;

			private static float percentageObject = 0;
			private static float totalObjects = 1;
			private static float objectsAssembled = 0;
			
			private static float finalPercentage = 0;
				

			public static float GetPercentage() {
				percentageFileRead = linesRead / totalLines * 100.0f;
				percentageObject = objectsAssembled / totalObjects * 100f;
				finalPercentage = (percentageFileRead + percentageObject) / 2.0f;
				return finalPercentage;
			}


			private static string[] dataLine;
			public static Error ObjMeshAssembler(ref Node3D modelNode, ref string path){
				path = path.Replace('\\','/');

				dataLine = FileAccess.Open(path, FileAccess.ModeFlags.Read).GetAsText().Split('\n', StringSplitOptions.None);

				// Mesh data
				List<Vector3> vertexPositions = new();
				List<Vector3> vertexNormals = new();
				List<Vector2> vertexTextureCoordinates = new();

				//List<List<int[]>> indices = new();

				string currentMaterial = "DefaultMaterial";
				string currentObject = "DefaultObject";
				//string currentMesh = currentObject + '_' + currentMaterial;

				Dictionary<string, StandardMaterial3D> materials = new();

				//Dictionary<string, List<List<int[]>>> surfDict = new();
				//Dictionary<string, Dictionary<string, List<List<int[]>>>> surfaces = new();

				Dictionary<string, Dictionary<string, List<List<int[]>>>> objects = new();
				//Dictionary<string, List<List<int[]>>> surfaces = new();


				totalLines = dataLine.Length;

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
							currentObject = token[1];
							
							objects.Add(currentObject, new Dictionary<string, List<List<int[]>>>());

							/*
							currentMesh = currentObject + "_DefaultMaterial";

							if (!surfDict.ContainsKey(currentMesh)) {
								surfDict.Add(currentMesh, new List<List<int[]>>());
							}
							*/
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

							objects[currentObject].Add(currentMaterial, new List<List<int[]>>());

							/*
							currentMesh = currentObject + '_' + currentMaterial;
							
							if (surfDict.ContainsKey(currentObject + "_DefaultMaterial")) {
								GD.Print("REPLACING");
								// Replace
								List<List<int[]>> oldSurfDef = surfDict[currentObject + "_DefaultMaterial"];

								surfDict.Remove(currentObject + "_DefaultMaterial");
								surfDict.Add(currentMesh, oldSurfDef);
							}

							if (!surfDict.ContainsKey(currentMesh)) {
								surfDict.Add(currentMesh, new List<List<int[]>>());
							} 
							*/

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

							if (!objects[currentObject].ContainsKey(currentMaterial)) {
								objects[currentObject].Add(currentMaterial, new List<List<int[]>>());
							} 

							objects[currentObject][currentMaterial].Add(facedef);
							
							//surfDict[currentMesh].Add(facedef);
							break;
					} // Switch ends here
					//percentage = (totalLines - dataLine.Length) / totalLines * 100;
					linesRead += 1;
					//dataLine = dataLine.Skip(1).ToArray();
				} // Foreach ends here			

				int surfIdx = -1;

				GD.Print("\n");
				
				totalObjects = objects.Count;
				foreach(string objectDef in objects.Keys) {
					//GD.Print($"Object:\n\n\t{objectDef}\n\nSurfaces:\n");

					// Same hacky fix here
					var AssembleSurfaceMeshData = RAISurfAssemble.RAISurfAssemble.AssembleSurfaceMeshData;
					ArrayMesh arrayMesh = new();
					
					MeshInstance3D meshObject = new();
					
					foreach(string surfaceDef in objects[objectDef].Keys) {
						surfIdx++;
						Godot.Collections.Array arrayMeshData = new();
						arrayMeshData.Resize((int)Mesh.ArrayType.Max);
						AssembleSurfaceMeshData(objects[objectDef][surfaceDef], ref vertexPositions, ref vertexNormals, ref vertexTextureCoordinates, ref arrayMeshData);
						arrayMesh.AddSurfaceFromArrays(Mesh.PrimitiveType.Triangles, arrayMeshData);
						arrayMesh.SurfaceSetName(surfIdx, surfaceDef);
						arrayMesh.SurfaceSetMaterial(surfIdx, materials[surfaceDef]);
						//GD.Print($"\t{surfaceDef}\n\t{objects[objectDef][surfaceDef].Count}\n");
					}

					meshObject.Mesh = arrayMesh;
					meshObject.Name = objectDef;

					
					meshObject.CreateTrimeshCollision();

					modelNode.AddChild(meshObject, true);
					
					surfIdx = -1;
					objectsAssembled += 1;
					//GD.Print("\n");
				}

				return Error.Ok;
			}
			
			private static Error ObjMaterialAssembler(ref Dictionary<string, StandardMaterial3D> materials, ref string path) {
				// FIXME: RAIImage namespace bugs out

				// Hacky fix for a weird issue with the rai image namespace
				var TextureLoader = RAIImage.RAIImage.TextureLoader;
				Dictionary<string, StandardMaterial3D> internalMaterialDict = new();

				// TODO: Implement a texture lookup database to avoid loading repeats
				// Could work by storing the currentMaterial name and the texture paths it holds, so any subsequent
				// materials can just "steal" from the original without loading from disk

				string[] dataLine = FileAccess.Open(path, FileAccess.ModeFlags.Read).GetAsText().Split('\n', StringSplitOptions.None);
				string currentMaterial = "DefaultMaterial";
				string texturePath;
				ushort tokenIndex;

				foreach (string line in dataLine) {
					string[] token = line.Split(' ', StringSplitOptions.None);

					bool containsScaleAttribute = false;
					bool containsBumpNormalScaleAttribute = false;

					if (token.Contains("-s"))
						containsScaleAttribute = true;
					
					if (token.Contains("-bm"))
						containsBumpNormalScaleAttribute = true;

					switch (token[0]) {
						case "newmtl":
							GD.Print($"Creating material definition for {token[1]}");
							currentMaterial = token[1];

							internalMaterialDict.Add(currentMaterial, new StandardMaterial3D());

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
							// FIXME: Gets called even when we have pbr materials
							float specExp = internalMaterialDict[currentMaterial].Roughness;
							float specCoeff = float.Parse(token[1]);

							float approxRough = (float)Mathf.Clamp(specExp/(1000*specCoeff), 0.0, 1.0);
							internalMaterialDict[currentMaterial].Roughness = approxRough;

							GD.Print($"Approximated roughness for {currentMaterial} = {internalMaterialDict[currentMaterial].Roughness}");
							GD.PushWarning("Using approximated roughness for non-PBR OBJ materials is not reccomended, re-export the mesh with PBR extensions enabled.");
							break;
						case "d":
							float alpha = float.Parse(token[1]);
							if (alpha < 1.0) {
								internalMaterialDict[currentMaterial].AlbedoColor = new Color(internalMaterialDict[currentMaterial].AlbedoColor, alpha);
								internalMaterialDict[currentMaterial].Transparency = BaseMaterial3D.TransparencyEnum.Alpha;
							}
							break;
						case "map_Kd":
							tokenIndex = 1;

							if (containsScaleAttribute) {
								tokenIndex = 5;

								// TODO: Test is we always have 3 scale indexes
								internalMaterialDict[currentMaterial].Uv1Scale = new Vector3(float.Parse(token[2]), float.Parse(token[3]), float.Parse(token[4]));
							}
								

							texturePath=token[tokenIndex..].Join(" ");

							if (texturePath.IsRelativePath()) {
								texturePath = path.GetBaseDir().PathJoin(texturePath);
							}

							//internalMaterialDict[currentMaterial].Uv1Scale = new Vector3(30.0f,30.0f,30.0f);
							internalMaterialDict[currentMaterial].AlbedoTexture = TextureLoader(texturePath, false);

							break;
						case "map_refl" or "map_Pr":
							tokenIndex = 1;

							if (containsScaleAttribute) {
								tokenIndex = 5;

								// TODO: Test is we always have 3 scale indexes
								internalMaterialDict[currentMaterial].Uv1Scale = new Vector3(float.Parse(token[2]), float.Parse(token[3]), float.Parse(token[4]));
							}


							texturePath=token[tokenIndex..].Join(" ");

							if (texturePath.IsRelativePath()) {
								texturePath = path.GetBaseDir().PathJoin(texturePath);
							}


							internalMaterialDict[currentMaterial].Roughness = 1.0f;
							internalMaterialDict[currentMaterial].RoughnessTextureChannel = BaseMaterial3D.TextureChannel.Grayscale;
							internalMaterialDict[currentMaterial].RoughnessTexture = TextureLoader(texturePath, false);
							
							break;
						case "map_Bump":
							tokenIndex = 1;

							if (containsScaleAttribute) {
								tokenIndex = 5;

								// TODO: Test is we always have 3 scale indexes
								internalMaterialDict[currentMaterial].Uv1Scale = new Vector3(float.Parse(token[2]), float.Parse(token[3]), float.Parse(token[4]));
							}


							if (containsBumpNormalScaleAttribute) {
								if (containsScaleAttribute) {
									// We do this so we offset the index to make sure the code below runs
									// without a -s arg
									tokenIndex = 7;
								} else {
									tokenIndex = 3;
								}
								
								
								
								GD.Print(tokenIndex);

								internalMaterialDict[currentMaterial].NormalScale = float.Parse(token[tokenIndex - 1]);
							}

							texturePath=token[tokenIndex..].Join(" ");


							if (texturePath.IsRelativePath()) {
								texturePath = path.GetBaseDir().PathJoin(texturePath);
							}

							GD.Print(texturePath);

							internalMaterialDict[currentMaterial].NormalEnabled = true;
							internalMaterialDict[currentMaterial].NormalTexture = TextureLoader(texturePath, false);
							
							break;
					}
				}	


				if (internalMaterialDict.Count > 0) {
					foreach (string materialName in internalMaterialDict.Keys) {
						materials.Add(materialName, internalMaterialDict[materialName]);
					}
				} else {
					// We have no materials

					StandardMaterial3D defaultMaterial = new();
					materials.Add(currentMaterial, defaultMaterial);
				}

				return Error.Ok;
			}


		}
		
	}
}
