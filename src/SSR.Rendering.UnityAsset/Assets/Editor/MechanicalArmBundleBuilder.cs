using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Xml.Linq;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace SSR.Rendering.Editor
{
    //导入无动画机械臂，保留刚性蒙皮并生成核心独立资源包。
    public static class MechanicalArmBundleBuilder
    {
        private const string Folder = "Assets/SSR/MechanicalArm";
        private const string TexturePath = "Things/Building/MechanicalArm/MechanicalArm_Isometric";
        private const string BlueprintPath = "Things/Building/MechanicalArm/MechanicalArm_Blueprint";

        //构建 Windows 模型资源和建筑图标。
        public static void BuildWindows()
        {
            AssetDatabase.Refresh();
            var importer = (ModelImporter)AssetImporter.GetAtPath(Folder + "/MechanicalArm.fbx");
            importer.importAnimation = false;
            importer.animationType = ModelImporterAnimationType.Generic;
            importer.optimizeGameObjects = false;
            importer.isReadable = true;
            importer.materialImportMode = ModelImporterMaterialImportMode.None;
            importer.SaveAndReimport();
            var texture = AssetDatabase.LoadAssetAtPath<Texture2D>(Folder + "/MechanicalArm_BaseColor.png");
            var material = AssetDatabase.LoadAssetAtPath<Material>(Folder + "/MechanicalArm.mat");
            if (!material)
            {
                material = new Material(Shader.Find("SSR/MechanicalArm/Surface"));
                AssetDatabase.CreateAsset(material, Folder + "/MechanicalArm.mat");
            }
            material.mainTexture = texture;
            var root = new GameObject("MechanicalArm");
            var model = UnityEngine.Object.Instantiate(AssetDatabase.LoadAssetAtPath<GameObject>(Folder + "/MechanicalArm.fbx"), root.transform);
            model.name = "Model";
            var animator = model.GetComponent<Animator>();
            if (animator) UnityEngine.Object.DestroyImmediate(animator);
            foreach (Renderer renderer in model.GetComponentsInChildren<Renderer>())
            {
                renderer.sharedMaterial = material;
                if (renderer is SkinnedMeshRenderer skin) skin.updateWhenOffscreen = true;
            }
            Transform[] transforms = model.GetComponentsInChildren<Transform>(true);
            string[] bones = { "Root", "BaseYaw", "Shoulder", "Elbow", "WristPitch", "WristRoll", "Jaw_L", "Jaw_R" };
            foreach (string name in bones)
            {
                Transform bone = transforms.Single(t => t.name == name && !t.GetComponent<Renderer>());
                Debug.Log("SSR_ARM_BONE " + name + " position=" + bone.position.ToString("F6")
                    + " localRotation=" + bone.localEulerAngles.ToString("F3"));
            }
            Renderer baseRenderer = model.GetComponentsInChildren<Renderer>().Single(r => r.name == "Base");
            Bounds baseBounds = baseRenderer.bounds;
            float scale = 0.9f / Mathf.Max(baseBounds.size.x, baseBounds.size.z);
            model.transform.localPosition = new Vector3(-baseBounds.center.x, -baseBounds.min.y, -baseBounds.center.z) * scale;
            model.transform.localScale = Vector3.one * scale;
            Transform wrist = transforms.Single(t => t.name == "WristRoll");
            var grip = new GameObject("Grip").transform;
            grip.SetParent(wrist, false);
            //原模型两爪中部距腕滚转关节约 0.4074 模型单位。
            grip.localPosition = Vector3.up * 0.4074f;
            Debug.Log("SSR_ARM_SCALE " + scale + " GRIP " + grip.position.ToString("F6"));
            PrefabUtility.SaveAsPrefabAsset(root, Folder + "/MechanicalArm.prefab");
            ExportIcons(root);
            UnityEngine.Object.DestroyImmediate(root);
            AssetDatabase.SaveAssets();
            string output = Path.GetFullPath(Path.Combine(Application.dataPath, "../../../1.6/Asset/MechanicalArm/Windows"));
            Directory.CreateDirectory(output);
            string[] names = { Folder + "/MechanicalArm.prefab", Folder + "/Shaders/HeldThing.shader" };
            var result = BuildPipeline.BuildAssetBundles(output, new[]
            {
                new AssetBundleBuild { assetBundleName = "ssr_mechanicalarm", assetNames = names }
            }, BuildAssetBundleOptions.StrictMode | BuildAssetBundleOptions.ChunkBasedCompression
                | BuildAssetBundleOptions.ForceRebuildAssetBundle, BuildTarget.StandaloneWindows64);
            if (!result || result.GetAllDependencies("ssr_mechanicalarm").Length != 0)
                throw new InvalidOperationException("机械臂模型资源包构建失败或包含外部依赖。");
            Debug.Log("SSR_ARM_BUILD_OK " + output);
        }

        //只更新图标和蓝图，不重建模型资源包。
        [MenuItem("SSR/机械臂资源/导出折叠图标与蓝图")]
        public static void ExportIcons()
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>("Assets/SSR/MechanicalArm/MechanicalArm.prefab");
            if (!prefab) throw new InvalidOperationException("缺少机械臂预制体。");
            var root = UnityEngine.Object.Instantiate(prefab);
            try { ExportIcons(root); }
            finally { UnityEngine.Object.DestroyImmediate(root); }
        }

        //蓝图使用地图中的待机姿势和投影，菜单保留炮塔式斜视图。
        private static void ExportIcons(GameObject root)
        {
            var blueprint = UnityEngine.Object.Instantiate(root);
            try
            {
                blueprint.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);
                MechanicalArmBlueprintPose.Apply(blueprint);
                ExportTexture(blueprint, Quaternion.Euler(60, 0, 0), BlueprintPath, true);
            }
            finally { UnityEngine.Object.DestroyImmediate(blueprint); }

            Fold(root);
            ExportTexture(root, Quaternion.Euler(55, 55, 0), TexturePath, false);
        }

        //按模型真实尺寸取景，记录底座投影以便蓝图对齐建造格。
        private static void ExportTexture(GameObject root, Quaternion view, string texturePath, bool blueprint)
        {
            var cameraObject = new GameObject("机械臂图标相机");
            var output = new RenderTexture(512, 512, 24, RenderTextureFormat.ARGB32) { antiAliasing = 4 };
            var icon = new Texture2D(512, 512, TextureFormat.RGBA32, false);
            RenderTexture previous = RenderTexture.active;
            try
            {
                root.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);
                foreach (Transform child in root.GetComponentsInChildren<Transform>(true)) child.gameObject.layer = 31;
                Camera camera = cameraObject.AddComponent<Camera>();
                camera.orthographic = true;
                camera.aspect = 1;
                camera.clearFlags = CameraClearFlags.SolidColor;
                camera.backgroundColor = Color.clear;
                camera.cullingMask = 1 << 31;
                camera.transform.rotation = view;
                Bounds bounds = ViewBounds(root, camera.transform.rotation);
                Vector3 center = camera.transform.rotation * bounds.center;
                camera.orthographicSize = Mathf.Max(bounds.extents.x, bounds.extents.y) * 1.12f;
                camera.transform.position = center - camera.transform.forward * (bounds.extents.z + 10);
                camera.nearClipPlane = .01f;
                camera.farClipPlane = bounds.size.z + 20;
                camera.targetTexture = output;
                Capture(camera, output, icon);
                RectInt visible = VisibleRect(icon);
                Vector3 shift = (camera.transform.right * (visible.center.x / 512f - .5f)
                    + camera.transform.up * (visible.center.y / 512f - .5f)) * (camera.orthographicSize * 2);
                center += shift;
                camera.transform.position += shift;
                camera.orthographicSize *= Mathf.Max(visible.width, visible.height) / 512f * 1.12f;
                Capture(camera, output, icon);

                string projectRoot = Path.GetFullPath(Path.Combine(Application.dataPath, "../../.."));
                string path = Path.Combine(projectRoot, "1.6/Textures", texturePath + ".png");
                Directory.CreateDirectory(Path.GetDirectoryName(path));
                File.WriteAllBytes(path, icon.EncodeToPNG());
                Vector3 offset = new Vector3(Vector3.Dot(center, camera.transform.right), 0,
                    Vector3.Dot(center, camera.transform.up));
                if (blueprint) UpdateBlueprint(projectRoot, camera.orthographicSize * 2, offset);
                Debug.Log("SSR_ARM_ICON_OK " + path + " size=" + camera.orthographicSize * 2 + " offset=" + offset);
            }
            finally
            {
                RenderTexture.active = previous;
                UnityEngine.Object.DestroyImmediate(cameraObject);
                output.Release();
                UnityEngine.Object.DestroyImmediate(output);
                UnityEngine.Object.DestroyImmediate(icon);
            }
        }

        //读取当前模型的透明影像。
        private static void Capture(Camera camera, RenderTexture output, Texture2D icon)
        {
            camera.Render();
            RenderTexture.active = output;
            icon.ReadPixels(new Rect(0, 0, 512, 512), 0, 0);
            icon.Apply();
        }

        //以可见轮廓居中取景，蒙皮包围盒中的空白不占用建造按钮。
        private static RectInt VisibleRect(Texture2D icon)
        {
            Color32[] pixels = icon.GetPixels32();
            int minX = icon.width, minY = icon.height, maxX = -1, maxY = -1;
            for (int y = 0; y < icon.height; y++)
            {
                for (int x = 0; x < icon.width; x++)
                {
                    if (pixels[y * icon.width + x].a == 0) continue;
                    minX = Mathf.Min(minX, x);
                    minY = Mathf.Min(minY, y);
                    maxX = Mathf.Max(maxX, x);
                    maxY = Mathf.Max(maxY, y);
                }
            }
            if (maxX < 0) throw new InvalidOperationException("机械臂图标导出结果为空。");
            return new RectInt(minX, minY, maxX - minX + 1, maxY - minY + 1);
        }

        //肩肘收拢、夹爪向下，所有转角均位于运行时的关节限制内。
        private static void Fold(GameObject root)
        {
            Transform[] transforms = root.GetComponentsInChildren<Transform>(true);
            Transform Bone(string name) => transforms.Single(t => t.name == name && !t.GetComponent<Renderer>());
            Bone("BaseYaw").localRotation *= Quaternion.AngleAxis(90, Vector3.up);
            Bone("Shoulder").localRotation *= Quaternion.AngleAxis(45, Vector3.forward);
            Bone("Elbow").localRotation *= Quaternion.AngleAxis(-135, Vector3.forward);
            Bone("WristPitch").localRotation *= Quaternion.AngleAxis(-90, Vector3.forward);
        }

        //使用折叠后的网格顶点取景，避免蒙皮原始包围盒留下大片空白。
        private static Bounds ViewBounds(GameObject root, Quaternion rotation)
        {
            List<Vector3> points = new List<Vector3>();
            Quaternion inverse = Quaternion.Inverse(rotation);
            foreach (Renderer renderer in root.GetComponentsInChildren<Renderer>())
            {
                if (renderer is SkinnedMeshRenderer skin)
                {
                    var mesh = new Mesh();
                    try
                    {
                        skin.BakeMesh(mesh);
                        foreach (Vector3 vertex in mesh.vertices) points.Add(inverse * skin.transform.TransformPoint(vertex));
                    }
                    finally { UnityEngine.Object.DestroyImmediate(mesh); }
                }
                else
                {
                    Mesh mesh = renderer.GetComponent<MeshFilter>().sharedMesh;
                    foreach (Vector3 vertex in mesh.vertices) points.Add(inverse * renderer.transform.TransformPoint(vertex));
                }
            }
            if (points.Count == 0) throw new InvalidOperationException("机械臂模型没有可导出的网格。");
            Bounds bounds = new Bounds(points[0], Vector3.zero);
            foreach (Vector3 point in points) bounds.Encapsulate(point);
            return bounds;
        }

        //蓝图按相机实际取景比例显示，并将底座投影对齐建筑所在格。
        private static void UpdateBlueprint(string projectRoot, float size, Vector3 offset)
        {
            string path = Path.Combine(projectRoot, "1.6/Defs/ThingDefs/Bulidings/Buildings_MechanicalArm.xml");
            XDocument document = XDocument.Load(path, LoadOptions.PreserveWhitespace);
            XElement definition = document.Root.Elements("ThingDef")
                .Single(element => element.Element("defName")?.Value == "SSR_Building_MechanicalArm");
            XElement blueprint = definition.Element("building").Element("blueprintGraphicData");
            blueprint.Element("texPath").Value = BlueprintPath;
            blueprint.Element("drawSize").Value = "(" + Number(size) + "," + Number(size) + ")";
            blueprint.Element("drawOffset").Value = "(" + Number(offset.x) + ",0," + Number(offset.z) + ")";
            File.WriteAllText(path, document.Declaration + Environment.NewLine
                + document.ToString(SaveOptions.DisableFormatting).TrimStart('\r', '\n'), new UTF8Encoding(false));
        }

        //以统一小数格式写入 XML。
        private static string Number(float value) => value.ToString("0.######", CultureInfo.InvariantCulture);
    }
}
