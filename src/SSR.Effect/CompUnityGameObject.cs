using System;
using System.Collections.Generic;
using RimWorld;
using UnityEngine;
using UnityEngine.UIElements;
using Verse;

namespace SSR.Effect
{
    public class CompUnityGameObject : ThingComp
    {
        
        private class UnityGameObjectUpdater : MonoBehaviour
        {
            public bool isPlaying = false;
            public float playingSpeed = 1;
            public Transform maskTransform;
            public Transform ownTransform;
            public GameObject ownGameObject;
            public Animator ownAnimator;
            public CompUnityGameObject compUnityGameObject;

            public void SetVisibility(bool visibility)
            {
                foreach(var i in ownTransform.GetComponentsInChildren<MeshRenderer>())
                {
                    i.enabled = visibility;
                }
            }
            void Update()
            {
                if(compUnityGameObject != null)
                {
                    ownAnimator.SetFloat("Speed", Find.TickManager.TickRateMultiplier * (Find.TickManager.Paused ? 0 : 1) * playingSpeed);
                    ownAnimator.SetBool("IsPlaying", isPlaying);
                    if(!compUnityGameObject.parent.Spawned || compUnityGameObject.parent.Map != Find.CurrentMap)
                    {
                        SetVisibility(false);
                    }
                    if(compUnityGameObject.parent.Destroyed)
                    {
                        Destroy(gameObject);
                    }
                }
            }
        }
        
        
        public CompProperties_UnityGameObject Props => (CompProperties_UnityGameObject)props;


        public bool IsPlaying
        {
            get => unityGameObjectUpdater?.isPlaying ?? false;
            set
            {
                if(unityGameObjectUpdater != null)
                    unityGameObjectUpdater.isPlaying = value;
            }
        }
        public float PlaySpeed
        {
            get => unityGameObjectUpdater?.playingSpeed ?? 0;
            set
            {
                if(unityGameObjectUpdater != null)
                    unityGameObjectUpdater.playingSpeed = value;
            }
        }
        public int PerfabIndex 
        {
            get => Math.Max(Math.Min(currentIndex, Props.GameObjects.Count - 1),0);
            set
            {
                value = Math.Min(value, Props.GameObjects.Count - 1);
                if (currentIndex != value && value >= 0)
                {
                    currentIndex = value;
                    GameObject.Destroy(monoBehaviour);
                    monoBehaviour = null;
                }
            }
        }



        private UnityGameObjectUpdater unityGameObjectUpdater
        {
            get
            {
                if(monoBehaviour == null)
                {
                    // Log.Message(ShaderDatabase.Cutout.renderQueue);
                    if (Props.GameObjects.Count > 0)
                    {
                        GameObject obj = GameObject.Instantiate(Props.GameObjects[PerfabIndex]);
                        monoBehaviour = obj.AddComponent<UnityGameObjectUpdater>();
                        monoBehaviour.ownGameObject = obj;
                        monoBehaviour.ownTransform = obj.transform;
                        monoBehaviour.maskTransform = monoBehaviour.ownTransform.Find("FinalMask");
                        monoBehaviour.ownAnimator = obj.GetComponent<Animator>();
                        monoBehaviour.compUnityGameObject = this;
                    }
                }
                return monoBehaviour;
            }
        }

        public GameObject GameObject => unityGameObjectUpdater?.ownGameObject;

        public Transform Transform => unityGameObjectUpdater?.ownTransform;

        public Transform MaskTransform => unityGameObjectUpdater?.maskTransform;
        
        public Animator Animator => unityGameObjectUpdater?.ownAnimator;

        public void SetVisibility(bool visibility) => unityGameObjectUpdater?.SetVisibility(visibility);

        private int currentIndex = 0;
        private UnityGameObjectUpdater monoBehaviour;

    }

    public class CompProperties_UnityGameObject : CompProperties
    {
        
        public CompProperties_UnityGameObject()
        {
            compClass = typeof(CompUnityGameObject);
        }

        internal AssetBundle assetBundle
        {
            get
            {
                if(currentAssetBundle == null)
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
                                    currentAssetBundle = assetBundle;
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
                return currentAssetBundle;
            }
        }

        public List<GameObject> GameObjects
        {
            get
            {
                if(gameObjects == null)
                {
                    gameObjects = new List<GameObject>();
                    if(!perfabPaths.NullOrEmpty())
                    {
                        gameObjects.Capacity = perfabPaths.Count;
                        foreach (string path in perfabPaths)
                        {
                            gameObjects.Add(assetBundle.LoadAsset<GameObject>(path));
                        }
                    }
                }
                return gameObjects;
            }
        }

        public override void ResolveReferences(ThingDef parentDef)
        {
            base.ResolveReferences(parentDef);
        }

        ~CompProperties_UnityGameObject()
        {
            foreach (GameObject gameObject in gameObjects)
            {
                UnityEngine.Object.Destroy(gameObject);
            }
        }

        public List<string> perfabPaths;
        private List<GameObject> gameObjects;
        private AssetBundle currentAssetBundle;
    }
}
