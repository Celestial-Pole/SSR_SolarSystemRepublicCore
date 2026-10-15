#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;

namespace Assets.Editor
{
    public class AssetBundles
    {
        /// <summary>被打包的资源根目录，该文件夹上已指定 AssetBundle 名。</summary>
        const string BundleSourceRoot = "Assets/SSR";

        /// <summary>Bundle 名前缀，实际文件名为 <c>ssr_&lt;平台后缀&gt;</c>。</summary>
        const string BundleNamePrefix = "ssr";

        sealed class BundlePlatform
        {
            public BuildTarget Target;
            public string Suffix;
            public string Folder;

            public string BundleName
            {
                get { return BundleNamePrefix + "_" + Suffix; }
            }

            public string OutputDirectory
            {
                get { return Path.Combine(OutputRoot, Folder); }
            }
        }

        /// <summary>
        /// 仓库根目录下的 Asset 输出目录。不再用相对路径定位，因为构建进程的工作目录并不固定
        /// （从命令行启动时就是启动目录）。
        /// </summary>
        static string OutputRoot
        {
            get
            {
                string projectDirectory = Path.GetDirectoryName(Application.dataPath);
                string repositoryDirectory = Path.GetDirectoryName(Path.GetDirectoryName(projectDirectory));
                return Path.Combine(repositoryDirectory, "Asset");
            }
        }

        static readonly BundlePlatform[] Platforms =
        {
            new BundlePlatform { Target = BuildTarget.StandaloneWindows64, Suffix = "windows", Folder = "Windows" },
            new BundlePlatform { Target = BuildTarget.StandaloneLinux64, Suffix = "linux", Folder = "Linux" },
            new BundlePlatform { Target = BuildTarget.StandaloneOSX, Suffix = "macos", Folder = "MacOS" },
        };

        /// <summary>
        /// 打包生成所有的AssetBundles（包）
        /// </summary>
        [MenuItem("Assets/Build All Asset Bundles")]
        public static void BuildAllAB()
        {
            foreach (BundlePlatform platform in Platforms)
            {
                BuildPlatform(platform);
            }
        }

        /// <summary>
        /// 命令行/CI 入口：只打包 <c>-buildTarget</c> 指定的平台，不切换 Active Build Target。
        /// BuildAssetBundles 会因为目标不同而切换 Active Build Target，而切换会重建编辑器窗口的
        /// 图形上下文（GUIView::RecreateContext），在 Vulkan 编辑器上这一步会崩溃；批处理模式没有
        /// 编辑器窗口，因此不会走到这条路径。
        /// </summary>
        public static void BuildFromCommandLine()
        {
            try
            {
                BundlePlatform platform = FindPlatform(EditorUserBuildSettings.activeBuildTarget);
                if (platform == null)
                {
                    Debug.LogErrorFormat("不支持的构建目标：{0}", EditorUserBuildSettings.activeBuildTarget);
                    EditorApplication.Exit(1);
                    return;
                }

                BuildPlatform(platform);
                EditorApplication.Exit(0);
            }
            catch (Exception exception)
            {
                Debug.LogError(exception);
                EditorApplication.Exit(1);
            }
        }

        static BundlePlatform FindPlatform(BuildTarget target)
        {
            return Platforms.FirstOrDefault(platform => platform.Target == target);
        }

        static void BuildPlatform(BundlePlatform platform)
        {
            string[] assets = ResolveBundleAssets();
            if (assets.Length == 0)
            {
                throw new InvalidOperationException(
                    "没有找到可打包的资源，请确认 " + BundleSourceRoot + " 上的 AssetBundle 名已设置。");
            }

            Directory.CreateDirectory(platform.OutputDirectory);

            var build = new AssetBundleBuild
            {
                assetBundleName = platform.BundleName,
                assetNames = assets,
            };

            AssetBundleManifest manifest = BuildPipeline.BuildAssetBundles(
                platform.OutputDirectory, new[] { build }, BuildAssetBundleOptions.None, platform.Target);

            if (manifest == null)
            {
                throw new InvalidOperationException("BuildAssetBundles 失败：" + platform.BundleName);
            }

            RemoveStrayFiles(platform);
            Debug.LogFormat("[AssetBundles] {0} -> {1} （{2} 个资源）",
                platform.BundleName, platform.OutputDirectory, assets.Length);
        }

        /// <summary>
        /// BuildAssetBundles 还会写出以输出目录命名的清单文件，这里只保留
        /// <c>ssr_&lt;平台&gt;</c> 及其 .manifest，避免把刚构建出来的包删掉。
        /// </summary>
        static void RemoveStrayFiles(BundlePlatform platform)
        {
            string bundleName = platform.BundleName.ToLowerInvariant();
            foreach (string file in Directory.GetFiles(platform.OutputDirectory))
            {
                string fileName = Path.GetFileName(file).ToLowerInvariant();
                if (fileName == bundleName || fileName == bundleName + ".manifest")
                {
                    continue;
                }

                Debug.Log("[AssetBundles] 删除多余文件：" + Path.GetFileName(file));
                File.Delete(file);
            }
        }

        /// <summary>取 <see cref="BundleSourceRoot"/> 下需要打包的资源。</summary>
        static string[] ResolveBundleAssets()
        {
            AssetImporter importer = AssetImporter.GetAtPath(BundleSourceRoot);
            string bundleName = importer == null ? null : importer.assetBundleName;
            if (!string.IsNullOrEmpty(bundleName))
            {
                string[] assigned = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName);
                if (assigned.Length > 0)
                {
                    return Normalize(assigned);
                }
            }

            return Normalize(AssetDatabase.FindAssets(string.Empty, new[] { BundleSourceRoot })
                .Select(AssetDatabase.GUIDToAssetPath));
        }

        static string[] Normalize(IEnumerable<string> paths)
        {
            return paths.Where(IsBundleableAsset)
                .Distinct()
                .OrderBy(path => path, StringComparer.Ordinal)
                .ToArray();
        }

        /// <summary>文件夹和 Editor-only 资源（.asmdef 等）不能进 AssetBundle。</summary>
        static bool IsBundleableAsset(string path)
        {
            if (string.IsNullOrEmpty(path) || AssetDatabase.IsValidFolder(path))
            {
                return false;
            }

            if (path.EndsWith(".asmdef", StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            return !path.Split('/').Any(segment => segment.Equals("Editor", StringComparison.OrdinalIgnoreCase));
        }
    }

    class MyWindow : EditorWindow
    {
        static List<string> text;


        [MenuItem("Window/List All Built-in Icons")]
        public static void ShowWindow()
        {
            EditorWindow.GetWindow(typeof(MyWindow));
            text = new List<string>();
            Texture2D[] t = Resources.FindObjectsOfTypeAll<Texture2D>();
            foreach(Texture2D texture in t)
            {
                Debug.unityLogger.logEnabled = false;
                GUIContent gc = EditorGUIUtility.IconContent(texture.name);
                Debug.unityLogger.logEnabled = true;
                if(gc != null)
                {
                    text.Add(texture.name);
                }
            }
        }
        public Vector2 scrollPosition;
        void OnGUI()
        {

            scrollPosition = GUILayout.BeginScrollView(scrollPosition);

            //鼠标放在按钮上的样式
            foreach (MouseCursor item in Enum.GetValues(typeof(MouseCursor)))
            {
                GUILayout.Button(Enum.GetName(typeof(MouseCursor), item));
                EditorGUIUtility.AddCursorRect(GUILayoutUtility.GetLastRect(), item);
                GUILayout.Space(10);
            }


            //内置图标
            for (int i = 0; i < text.Count; i += 8)
            {
                GUILayout.BeginHorizontal();
                for (int j = 0; j < 8; j++)
                {
                    int index = i + j;
                    if (index < text.Count)
                    {
                        Texture2D texture = (Texture2D)EditorGUIUtility.IconContent(text[index]).image;
                        if(texture != null)
                        {
                            if(GUILayout.Button(texture, GUILayout.Width(128), GUILayout.Height(128)))
                            {
                                RenderTexture rt = new RenderTexture(texture.width, texture.height, 0);
                                RenderTexture.active = rt;
                                Graphics.Blit(texture,rt,Vector2.one,Vector2.zero);
                                texture = new Texture2D(texture.width, texture.height, TextureFormat.RGBA32, false);
                                texture.ReadPixels(new Rect(0, 0, texture.width, texture.height), 0, 0);
                                texture.Apply();
                                RenderTexture.active = null;
                                rt.Release();
                                byte[] bytes = texture.EncodeToPNG();
                                string path = Application.dataPath + "/textureOutput/";
                                if(!Directory.Exists(path))
                                {
                                    Directory.CreateDirectory(path);
                                }
                                path += text[index] + ".png";
                                FileStream file = File.Open(path, FileMode.OpenOrCreate);
                                file.Write(bytes, 0, bytes.Length);
                                file.Flush();
                                file.Close();
                            }
                        }
                    }
                }
                GUILayout.EndHorizontal();
            }




            GUILayout.EndScrollView();
        }
    }
}
#endif