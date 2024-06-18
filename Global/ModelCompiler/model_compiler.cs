using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using Godot;


public partial class model_compiler : Node
{
    private class _material {
        internal string name;
        internal bool useTextures = false;
        internal Color albedoColor = new Color(1, 1, 1, 1);
        internal ImageTexture albedoTexture = null;
        internal ImageTexture normalTexture = null;
        internal ImageTexture roughnessTexture = null;
        internal ImageTexture metallicTexture = null;
        internal float normalStrength = 1.0f;
        internal float roughness = 0.5f;
        internal float metallic = 0f;
        internal float alpha = 1.0f;
    }

    private Dictionary<string, _material> _materials = new Dictionary<string, _material>();

    Node3D compile_mesh(string path) {
        // This is here just so strings arent broken when doing Parse
        Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.InvariantCulture;
        double start_time = Time.GetUnixTimeFromSystem();

       
        MeshInstance3D currentMesh = new MeshInstance3D();
        string currentMaterialGroup = "";
        Node3D finalMeshTree = new Node3D();
        Node3D currentObject = null;
        
        // Mesh data

        SurfaceTool surfaceTool = new SurfaceTool();
        
        // Is this as memory optimized as packed arrays?
        List<Vector3> vertices = new List<Vector3>();
        List<Vector3> vertexNormals = new List<Vector3>();
        List<Vector2> uvCoordinates = new List<Vector2>();

        //Vector3[] vertices = new Vector3[0];
        //Vector3[] vertexNormals = new Vector3[0];
        //Vector2[] uvCoordinates = new Vector2[0];

        // Here for debug, replace when implementing GLTF and others

        FileAccess objFile = FileAccess.Open(path, FileAccess.ModeFlags.Read);

        if (objFile == null) {
            GD.Print($"Path {path} is invalid or nonexistent");
            return finalMeshTree;
        }

        ulong fileLength = objFile.GetLength();


        surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

        while (objFile.GetPosition() < fileLength) {
            string[] currentLine = objFile.GetLine().Split(" ", false);
            
            switch (currentLine[0]) {
                case "#":
                    GD.Print(currentLine);
                    break;

                case "mtllib":
                    _obj_compile_materials(path.GetBaseDir().PathJoin(currentLine[1]));
                    break;

                case "v":
                    vertices.Add(new Vector3(
                        float.Parse(currentLine[1]),
                        float.Parse(currentLine[2]),
                        float.Parse(currentLine[3])
                        ));
                    break;

                case "vn":
                    vertexNormals.Add(new Vector3(
                        float.Parse(currentLine[1]),
                        float.Parse(currentLine[2]),
                        float.Parse(currentLine[3])
                        ));
                    break;
                
                case "vt":
                    uvCoordinates.Add(new Vector2(
                        float.Parse(currentLine[1]),
                        float.Parse(currentLine[2])
                        ) * new Vector2(1,-1));
                    break;
                
                case "o":
                    currentObject = new Node3D {
                        Name = currentLine[1]
                    };
                    GD.Print($"Created new object \"{currentObject.Name}\"");
                    finalMeshTree.AddChild(currentObject);
                    break;

                case "usemtl":
                    if (currentMaterialGroup != "") {
                        currentMesh.Name = currentMaterialGroup;
                        currentMesh.Mesh = surfaceTool.Commit();
                        currentObject.AddChild(currentMesh);

                        currentMesh = new MeshInstance3D();

                        surfaceTool.Clear();
                        surfaceTool.Begin(Mesh.PrimitiveType.Triangles);
                    }

                    currentMaterialGroup = $"{currentLine[1]}";

                    StandardMaterial3D material = new StandardMaterial3D() {
                        AlbedoColor = _materials[currentLine[1]].albedoColor,
                        Roughness = _materials[currentLine[1]].roughness,
                        Metallic = _materials[currentLine[1]].metallic,
                    };

                    // Texture handling

                    if (_materials[currentLine[1]].useTextures) {
                        if (_materials[currentLine[1]].albedoTexture != null) {
                            material.AlbedoTexture = _materials[currentLine[1]].albedoTexture;
                        }

                        if (_materials[currentLine[1]].roughnessTexture != null) {
                            material.RoughnessTextureChannel = BaseMaterial3D.TextureChannel.Grayscale;
                            material.RoughnessTexture = _materials[currentLine[1]].roughnessTexture;
                            material.Roughness = 1.0f;
                        }

                        if (_materials[currentLine[1]].metallicTexture != null) {
                            material.MetallicTextureChannel = BaseMaterial3D.TextureChannel.Grayscale;
                            material.MetallicTexture = _materials[currentLine[1]].metallicTexture;
                            //material.Metallic = 1.0f;
                        }

                        if (_materials[currentLine[1]].normalTexture != null) {
                            material.NormalEnabled = true;
                            material.NormalTexture = _materials[currentLine[1]].normalTexture;
                        }
                    }

                    surfaceTool.SetMaterial(material);

                    break;
                
                case "f":
                    if (currentLine.Length <= 4) {
                        for (ushort index = 3; index > 0; index--) {
                            string[] splitIndexes = currentLine[index].Split("/", false);

                            surfaceTool.SetNormal(
                                vertexNormals[int.Parse(splitIndexes[2]) - 1]
                            );

                            surfaceTool.SetUV(
                                uvCoordinates[int.Parse(splitIndexes[1]) - 1]
                            );

                            surfaceTool.AddVertex(
                                vertices[int.Parse(splitIndexes[0]) - 1]
                            );
                        }
                    }
                    break;
                
            }
        }

        // TODO: Work on a better way to do this instead of commiting a leftover mesh section

        currentMesh.Name = currentMaterialGroup;
        currentMesh.Mesh = surfaceTool.Commit();
        currentObject.AddChild(currentMesh);
        
        surfaceTool.Clear();

        GD.Print($"Elapsed time = {Time.GetUnixTimeFromSystem() - start_time}");
        return finalMeshTree;
    }

    private void _obj_compile_materials(string mtlPath) {
        GD.Print($"Loading material library at: {mtlPath}");

        FileAccess mtlFile = FileAccess.Open(mtlPath, FileAccess.ModeFlags.Read);
        _material currentMaterial = null;
        ulong fileLength = mtlFile.GetLength();

        while (mtlFile.GetPosition() < fileLength) {
            string[] mtlLine = mtlFile.GetLine().Split(" ", true);
            switch (mtlLine[0]) {
                case "newmtl":
                    // This is here for initializing the material (first run)
                    if (currentMaterial != null) {
                        _materials.Add(currentMaterial.name, currentMaterial);
                    }

                    currentMaterial = new _material {
                        name = mtlLine[1]
                    };
                    break;
                
                // Non PBR cases

                // Specular
                case "Ns":
                    currentMaterial.roughness = float.Parse(mtlLine[1]);
                    break;
                
                // Ambient color
                case "Ka":
                    GD.PushWarning("Wavefront MTL \"Ka\" parameter is unused.");
                    break;
                
                // Diffuse color
                case "Kd":
                    currentMaterial.albedoColor = new Color(
                        float.Parse(mtlLine[1]),
                        float.Parse(mtlLine[2]),
                        float.Parse(mtlLine[3])
                    );
                    break;
                
                // Specular weigth
                case "Ks":
                    float specExp = currentMaterial.roughness;
                    float specCol = float.Parse(mtlLine[1]);

                    // FIXME: This approximation is not good enough
                    float approxRough = (float)Mathf.Clamp(specExp/(1000*specCol), 0.0, 1.0);
                    currentMaterial.roughness = approxRough;

                    GD.Print($"Approximated roughness for {currentMaterial.name} = {currentMaterial.roughness}");

                    break;

                // Alpha
                case "d":
                    currentMaterial.alpha = float.Parse(mtlLine[1]);
                    break;
                
                // PBR cases

                case "Pr":
                    currentMaterial.roughness = float.Parse(mtlLine[1]);
                    break;
                
                // Metallic
                case "Pm":
                    currentMaterial.metallic = float.Parse(mtlLine[1]);
                    break;
                
                // Textures

                // Diffuse texture
                case "map_Kd":
                    currentMaterial.useTextures = true;
                    if (mtlLine[1].IsAbsolutePath()) {
                        currentMaterial.albedoTexture = _obj_texture_assembler(mtlLine[1]);
                    } else if (mtlLine[1].IsRelativePath()) {
                        currentMaterial.albedoTexture = _obj_texture_assembler(mtlPath.GetBaseDir().PathJoin(mtlLine[1]));
                    }
                    
                    break;

                // Metallic texture
                case "map_refl" or "map_Pm":
                currentMaterial.useTextures = true;

                if (mtlLine[1].IsAbsolutePath()) {
                    currentMaterial.albedoTexture = _obj_texture_assembler(mtlLine[1]);
                } else if (mtlLine[1].IsRelativePath()) {
                    currentMaterial.albedoTexture = _obj_texture_assembler(mtlPath.GetBaseDir().PathJoin(mtlLine[1]));
                }

                break;
                
                case "map_Bump":
                    currentMaterial.useTextures = true;

                    ushort pathIndex = 1;

                    if (mtlLine.Contains("-bm")) {
                        pathIndex = 3;
                        currentMaterial.normalStrength = float.Parse(mtlLine[2]);
                    }

                    if (mtlLine[pathIndex].IsAbsolutePath()) {
                        currentMaterial.albedoTexture = _obj_texture_assembler(mtlLine[pathIndex], true);
                    } else if (mtlLine[pathIndex].IsRelativePath()) {
                        currentMaterial.albedoTexture = _obj_texture_assembler(mtlPath.GetBaseDir().PathJoin(mtlLine[pathIndex]), true);
                    }

                    break;
            }
        }
        _materials.Add(currentMaterial.name, currentMaterial);
    }

    private ImageTexture _obj_texture_assembler(string imagePath, bool isNormal = false) {
        Image image = new Image();
        Error err = Error.FileNotFound;

        err = image.Load(imagePath);

        if (err != Error.Ok) {
            GD.PushError($"Image at {imagePath} could not be loaded, texture map won't be created.");
            return ImageTexture.CreateFromImage(image);
        } else {
            if (isNormal) {
                // Enable renormalization
                image.GenerateMipmaps(true);

                image.NormalMapToXy();
            } else {
                image.GenerateMipmaps();
            }
    
            return ImageTexture.CreateFromImage(image);
        }
    }

}
