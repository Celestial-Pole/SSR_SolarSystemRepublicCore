using HarmonyLib;
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Reflection.Emit;
using UnityEngine;
using Verse;

namespace SSR.Effect.Patch
{
    [HarmonyPatch(typeof(ShaderDatabase))]
    internal static partial class ShaderDatabase_Patcher
    {
        [HarmonyTranspiler]
        [HarmonyPatch(
            typeof(ShaderDatabase),
            "LoadShader"
        )]
        private static IEnumerable<CodeInstruction> TranspilPawnRenderer_DrawEquipmentAiming(IEnumerable<CodeInstruction> instructions)
        {
            foreach (CodeInstruction instruction in instructions)
            {
                if(instruction.Calls(Resources_Load))
                {
                    yield return new CodeInstruction(OpCodes.Call, ShaderDatabase_Load);
                }
                else yield return instruction;
            }
            yield break;
        }

        //反复调用性能开销大，记得加个缓存
        private static Shader Load(string path, Type systemTypeInstance)
        {
            Shader result = (Shader)Resources.Load(path, typeof(Shader));
            if(result == null)
            {
                if(path.StartsWith("Materials/")) path = path.Substring(10);
                
                List<ModContentPack> runningModsListForReading = LoadedModManager.RunningModsListForReading;
                foreach (ModContentPack pack in runningModsListForReading)
                {
                    foreach (AssetBundle assetBundle in pack.assetBundles.loadedAssetBundles)
                    {
                        result = assetBundle.LoadAsset<Shader>(path);
                        if (result != null && result.isSupported)
                        {
                            break;
                        }
                    }
                    if (result != null && result.isSupported)
                    {
                        break;
                    }
                }
            }
            return result;
        }

        private static MethodInfo Resources_Load = typeof(Resources).GetMethod("Load", new Type[] { typeof(string), typeof(Type) });
        private static MethodInfo ShaderDatabase_Load = typeof(ShaderDatabase_Patcher).GetMethod("Load", AccessTools.all);
    }
}