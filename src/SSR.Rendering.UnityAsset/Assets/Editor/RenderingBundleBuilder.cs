using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace SSR.Rendering.Editor
{
    //构建核心独立的后处理资源，不引用战斗预制体、材质或脚本。
    public static class RenderingBundleBuilder
    {
        //为当前 Windows 1.6 开发目标构建资源包。
        public static void BuildWindows() { Build(BuildTarget.StandaloneWindows64, "Windows"); }

        //为 Linux 1.6 发布构建对应平台的 Shader。
        public static void BuildLinux() { Build(BuildTarget.StandaloneLinux64, "Linux"); }

        //为 macOS 1.6 发布构建对应平台的 Shader。
        public static void BuildMacOS() { Build(BuildTarget.StandaloneOSX, "MacOS"); }

        //使用显式清单，阻止资源标签引入其他模组依赖。
        private static void Build(BuildTarget target, string platform)
        {
            if (!UnityEditor.PackageManager.PackageInfo.GetAllRegisteredPackages()
                .Any(package => package.name == "com.unity.modules.assetbundle"))
                throw new InvalidOperationException("资源工程必须启用 com.unity.modules.assetbundle，否则不会生成资源包索引。");
            string[] shaders = AssetDatabase.FindAssets("t:Shader", new[] { "Assets/SSR/Rendering/Shaders" })
                .Select(AssetDatabase.GUIDToAssetPath).OrderBy(path => path).ToArray();
            if (shaders.Length != 4) throw new InvalidOperationException("公共渲染应包含四个 Shader。");
            string output = Path.GetFullPath(Path.Combine(Application.dataPath, "../../../Asset/Rendering", platform));
            Directory.CreateDirectory(output);
            bool buildFailed = false;
            Application.LogCallback captureError = (message, stack, type) =>
            {
                if (type == LogType.Error || type == LogType.Exception || type == LogType.Assert) buildFailed = true;
            };
            AssetBundleManifest result;
            Application.logMessageReceived += captureError;
            try
            {
                result = BuildPipeline.BuildAssetBundles(output, new[]
                {
                    new AssetBundleBuild { assetBundleName = "ssr_rendering", assetNames = shaders }
                //资源包仅包含四个 Shader，完整重建以避免复用缺少模块时生成的无索引缓存。
                }, BuildAssetBundleOptions.ChunkBasedCompression | BuildAssetBundleOptions.StrictMode
                    | BuildAssetBundleOptions.ForceRebuildAssetBundle, target);
            }
            finally { Application.logMessageReceived -= captureError; }
            if (!result || buildFailed) throw new InvalidOperationException("公共渲染资源构建失败，请检查前面的构建错误：" + platform);
            if (result.GetAllDependencies("ssr_rendering").Length != 0)
                throw new InvalidOperationException("公共渲染资源存在外部 AssetBundle 依赖。");
            Debug.Log("SSR_RENDERING_BUILD_OK: " + output);
        }
    }
}
