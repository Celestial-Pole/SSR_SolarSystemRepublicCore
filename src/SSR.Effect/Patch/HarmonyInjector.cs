using HarmonyLib;
using System;
using System.Reflection;
using Verse;

namespace SSR.Effect.Patch
{
    [StaticConstructorOnStartup]
    internal static class HarmonyInjector
    {
        static HarmonyInjector()
        {
            patcher.PatchAll();
        }

        public static Harmony patcher = new Harmony("SSR.Effect.Patch");
        // public static Assembly coreAssembly = typeof(Thing).Assembly;
    }
}
