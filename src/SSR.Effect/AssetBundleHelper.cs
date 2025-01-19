using System;
using System.Collections.Generic;
using System.Reflection;
using System.Reflection.Emit;
using UnityEngine;
using Verse;

namespace SSR.Effect
{
    [StaticConstructorOnStartup]
    internal static class AssetBundleHelper
    {
        public static readonly AssetBundle EffectAssetBundle;
        static AssetBundleHelper()
        {
            List<ModContentPack> runningModsListForReading = LoadedModManager.RunningModsListForReading;
            foreach (ModContentPack pack in runningModsListForReading)
            {
                if (pack.PackageId.Equals("ssr.core") && !pack.assetBundles.loadedAssetBundles.NullOrEmpty())
                {
                    foreach (AssetBundle assetBundle in pack.assetBundles.loadedAssetBundles)
                    {
                        Shader shader = assetBundle.LoadAsset<Shader>(@"Assets/SSR/DepthMaskForce.shader");
                        if (shader != null && shader.isSupported)
                        {
                            // Log.Message($"pass {assetBundle.name}.{shader.name}");
                            EffectAssetBundle = assetBundle;
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }
}