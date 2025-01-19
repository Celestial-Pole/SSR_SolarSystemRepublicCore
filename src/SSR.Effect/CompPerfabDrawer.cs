using System;
using System.Collections.Generic;
using RimWorld;
using UnityEngine;
using UnityEngine.UIElements;
using Verse;

namespace SSR.Effect
{
    public class CompPerfabDrawer : ThingComp
    {
        internal class UnityGameObjectUpdater : MonoBehaviour
        {
            public bool showInNextFrame = true;
            public bool isPlaying = false;
            public long expirationTick = 6000;
            public float playingSpeed = 1;
            public Transform maskTransform;
            public Transform ownTransform;
            public GameObject ownGameObject;
            public Animator ownAnimator;
            public CompPerfabDrawer compUnityGameObject;

            public void SetVisibility(bool visibility)
            {
                foreach(var i in ownTransform.GetComponentsInChildren<MeshRenderer>())
                {
                    i.enabled = visibility;
                }
            }

            void Update()
            {
                ownGameObject = ownGameObject ?? base.gameObject;
                if(compUnityGameObject != null)
                {
                    ownAnimator?.SetFloat("Speed", Find.TickManager.TickRateMultiplier * (Find.TickManager.Paused ? 0 : 1) * playingSpeed);
                    ownAnimator?.SetBool("IsPlaying", isPlaying);
                    SetVisibility(showInNextFrame);
                    showInNextFrame = false;
                    if(expirationTick <= 0)
                    {
                        GameObject.Destroy(ownGameObject);
                        compUnityGameObject.monoBehaviour = null;
                    }
                    expirationTick--;
                }
                else
                {
                    GameObject.Destroy(ownGameObject);
                }
            }
        }
        private int currentIndex = 0;
        private UnityGameObjectUpdater monoBehaviour;
        
        
        public CompProperties_PerfabDrawer Props => (CompProperties_PerfabDrawer)props;


        public bool IsPlaying
        {
            get => UnityGameObjectUpdaterComponet?.isPlaying ?? false;
            set
            {
                if(UnityGameObjectUpdaterComponet != null)
                    UnityGameObjectUpdaterComponet.isPlaying = value;
            }
        }
        public float PlaySpeed
        {
            get => UnityGameObjectUpdaterComponet?.playingSpeed ?? 0;
            set
            {
                if(UnityGameObjectUpdaterComponet != null)
                    UnityGameObjectUpdaterComponet.playingSpeed = value;
            }
        }

        public int PerfabLevel
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



        private UnityGameObjectUpdater UnityGameObjectUpdaterComponet
        {
            get
            {
                if(monoBehaviour == null)
                {
                    // Log.Message(ShaderDatabase.Cutout.renderQueue);
                    if (Props.GameObjects.Count > 0)
                    {
                        GameObject obj = GameObject.Instantiate(Props.GameObjects[PerfabLevel]);
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

        public GameObject GameObject => UnityGameObjectUpdaterComponet?.ownGameObject;

        public Transform Transform => UnityGameObjectUpdaterComponet?.ownTransform;

        public Transform MaskTransform => UnityGameObjectUpdaterComponet?.maskTransform;
        
        public Animator Animator => UnityGameObjectUpdaterComponet?.ownAnimator;

        public void ShowInNextFrame()
        {
            UnityGameObjectUpdaterComponet.showInNextFrame = true;
            UnityGameObjectUpdaterComponet.expirationTick = 6000;
        }

    }

    public class CompProperties_PerfabDrawer : CompProperties
    {
        
        public List<string> leveledPerfabPaths;
        internal List<GameObject> leveledPerfabs;
        public CompProperties_PerfabDrawer()
        {
            compClass = typeof(CompPerfabDrawer);
        }

        internal List<GameObject> GameObjects
        {
            get
            {
                if(leveledPerfabs == null)
                {
                    leveledPerfabs = new List<GameObject>();
                    if(!leveledPerfabPaths.NullOrEmpty())
                    {
                        leveledPerfabs.Capacity = leveledPerfabPaths.Count;
                        foreach (string path in leveledPerfabPaths)
                        {
                            leveledPerfabs.Add(AssetBundleHelper.EffectAssetBundle.LoadAsset<GameObject>(path));
                        }
                    }
                }
                return leveledPerfabs;
            }
        }

        public override void ResolveReferences(ThingDef parentDef)
        {
            parentDef.graphicData.graphicClass = typeof(Graphic_Perfab);
            parentDef.graphic = null;
            parentDef.drawerType = DrawerType.RealtimeOnly;
        }

        ~CompProperties_PerfabDrawer()
        {
            foreach (GameObject gameObject in leveledPerfabs)
            {
                UnityEngine.Object.Destroy(gameObject);
            }
        }

    }
}
