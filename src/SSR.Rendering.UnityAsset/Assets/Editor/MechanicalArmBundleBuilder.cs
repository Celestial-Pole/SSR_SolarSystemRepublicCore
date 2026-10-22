using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace SSR.Rendering.Editor
{
    //导入无动画机械臂，保留刚性蒙皮并生成核心独立资源包。
    public static class MechanicalArmBundleBuilder
    {
        private const string Folder = "Assets/SSR/MechanicalArm";

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
            WriteIcon(root);
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

        //在资源构建期间生成透明建筑图标，不启动游戏场景。
        private static void WriteIcon(GameObject root)
        {
            var cameraObject = new GameObject("图标相机");
            Camera camera = cameraObject.AddComponent<Camera>();
            camera.orthographic = true;
            camera.orthographicSize = 2.5f;
            camera.clearFlags = CameraClearFlags.SolidColor;
            camera.backgroundColor = Color.clear;
            camera.transform.rotation = Quaternion.Euler(60, 0, 0);
            camera.transform.position = new Vector3(0, 2, 0) - camera.transform.forward * 12;
            var target = new RenderTexture(512, 512, 24, RenderTextureFormat.ARGB32);
            camera.targetTexture = target;
            camera.Render();
            RenderTexture.active = target;
            var icon = new Texture2D(512, 512, TextureFormat.RGBA32, false);
            icon.ReadPixels(new Rect(0, 0, 512, 512), 0, 0);
            icon.Apply();
            string path = Path.GetFullPath(Path.Combine(Application.dataPath,
                "../../../1.6/Textures/Things/Building/MechanicalArm/MechanicalArm.png"));
            Directory.CreateDirectory(Path.GetDirectoryName(path));
            File.WriteAllBytes(path, icon.EncodeToPNG());
            RenderTexture.active = null;
            camera.targetTexture = null;
            UnityEngine.Object.DestroyImmediate(icon);
            UnityEngine.Object.DestroyImmediate(target);
            UnityEngine.Object.DestroyImmediate(cameraObject);
        }
    }
}
