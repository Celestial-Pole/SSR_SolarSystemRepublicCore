﻿using System.Collections.Generic;
using RimWorld;
using UnityEngine;
using Verse;

namespace SSR.Effect
{
    public class CompUnityGameObject : ThingComp
    {
        
        private class UnityGameObjectUpdater : MonoBehaviour
        {
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


        private UnityGameObjectUpdater unityGameObjectUpdater
        {
            get
            {
                if(monoBehaviour == null)
                {
                    // Log.Message(ShaderDatabase.Cutout.renderQueue);
                    GameObject obj = GameObject.Instantiate(Props.GameObject);
                    monoBehaviour = obj.AddComponent<UnityGameObjectUpdater>();
                    monoBehaviour.ownGameObject = obj;
                    monoBehaviour.ownTransform = obj.transform;
                    monoBehaviour.maskTransform = monoBehaviour.ownTransform.Find("FinalMask");
                    monoBehaviour.ownAnimator = obj.GetComponent<Animator>();
                    monoBehaviour.compUnityGameObject = this;
                }
                return monoBehaviour;
            }
        }

        public GameObject GameObject => unityGameObjectUpdater.ownGameObject;

        public Transform Transform => unityGameObjectUpdater.ownTransform;

        public Transform MaskTransform => unityGameObjectUpdater.maskTransform;
        
        public Animator Animator => unityGameObjectUpdater.ownAnimator;

        public void SetVisibility(bool visibility) => unityGameObjectUpdater.SetVisibility(visibility);
        //直接调整播放速度
        public void AdjustPlaySpeed(float speed)
        {
            if (speed < 0) speed = 0;
            unityGameObjectUpdater.playingSpeed = speed;
        }

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

        public GameObject GameObject
        {
            get
            {
                if(gameObject == null)
                {
                    gameObject = assetBundle.LoadAsset<GameObject>(perfabPath);
                }
                return gameObject;
            }
        }

        public override void ResolveReferences(ThingDef parentDef)
        {
            base.ResolveReferences(parentDef);
        }

        ~CompProperties_UnityGameObject()
        {
            UnityEngine.Object.Destroy(gameObject);
        }

        public string perfabPath;
        private GameObject gameObject;
        private AssetBundle currentAssetBundle;
    }
}
