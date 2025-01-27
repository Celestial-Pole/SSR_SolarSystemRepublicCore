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
        //custom drawer componet for unity perfab opration
        public class UnityGameObjectUpdater : MonoBehaviour
        {
            public uint level; //current level of perfab
            public Rot4 rot; //current rotation of perfab
            public bool showInNextFrame = true; //show in next frame, avoid the object showing when graphic object not invoke draw function
            public bool isPlaying = false; //animation playing
            public long expirationTick = 6000; //delet condataion, when this object not update by `Graphic_Perfab_Single` or `Graphic_Perfab_Multi` for 10 seconds
            public float playingSpeed = 1; //animation speed
            public Transform maskTransform; //cached mask transform
            public Transform ownTransform; //cached behaviour ownner transform
            public GameObject ownGameObject; //cached behaviour ownner gameobject
            public Animator ownAnimator; //cached behaviour ownner animator
            public CompPerfabDrawer compUnityGameObject; //controler of this gameobject

            private void SetVisibility(bool visibility)
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
                    //standard animation parameters, please ensure the animator use thoes parameters
                    ownAnimator?.SetFloat("Speed", Find.TickManager.TickRateMultiplier * (Find.TickManager.Paused ? 0 : 1) * playingSpeed);
                    ownAnimator?.SetBool("IsPlaying", isPlaying);
                    SetVisibility(showInNextFrame);
                    showInNextFrame = false;
                    //delet condataion, when this object not update by `Graphic_Perfab_Single` or `Graphic_Perfab_Multi` for 10 seconds
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
        private uint currentIndex = 0;
        private UnityGameObjectUpdater monoBehaviour;
        
        public uint PerfabLevel
        {
            get => currentIndex;
            set
            {
                if (currentIndex != value && value >= 0)
                {
                    currentIndex = value;
                    GameObject.Destroy(monoBehaviour);
                    monoBehaviour = null;
                }
            }
        }

        
        public CompProperties_PerfabDrawer Props => props as CompProperties_PerfabDrawer;

        public UnityGameObjectUpdater UnityGameObjectUpdaterComponet(Rot4 rot)
        {
            if(monoBehaviour == null || monoBehaviour.level != PerfabLevel || monoBehaviour.rot != rot)
            {
                // Log.Message(ShaderDatabase.Cutout.renderQueue);
                GameObject perfab = Props.GetGameObjects(PerfabLevel, rot);
                if (perfab != null)
                {
                    GameObject obj = GameObject.Instantiate(perfab);
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

    public abstract class CompProperties_PerfabDrawer : CompProperties
    {
        public CompProperties_PerfabDrawer()
        {
            compClass = typeof(CompPerfabDrawer);
        }

        internal abstract GameObject GetGameObjects(uint level, Rot4 rot);

    }

    //single view perfab drawer
    public class CompProperties_SinglePerfabDrawer : CompProperties_PerfabDrawer
    {
        
        //do not use this class in xml def file, it will setting automatically when you use this comp
        private class Graphic_Perfab_Single : Graphic_Single
        {
            public override void DrawWorker(Vector3 loc, Rot4 rot, ThingDef thingDef, Thing thing, float extraRotation)
            {
                CompPerfabDrawer.UnityGameObjectUpdater obj = thing.TryGetComp<CompPerfabDrawer>()?.UnityGameObjectUpdaterComponet(rot);
                if(obj)
                {
                    loc += DrawOffset(rot);
                    if(obj.maskTransform)
                    {
                        obj.maskTransform.localPosition = new Vector3(0,loc.y / thingDef.staticSunShadowHeight,0);
                        obj.ownTransform.position = new Vector3(loc.x,0,loc.z);
                    }
                    else
                    {
                        obj.ownTransform.position = loc;
                    }
                    obj.ownTransform.localScale = new Vector3(drawSize.x, thingDef.staticSunShadowHeight, drawSize.y);
                    obj.ownTransform.rotation = Quaternion.Euler(0,extraRotation + rot.AsAngle,0);
                    obj.expirationTick = 6000;
                    obj.showInNextFrame = true;
                }
                else base.DrawWorker(loc, rot, thingDef, thing, extraRotation);
            }

            public override Graphic GetColoredVersion(Shader newShader, Color newColor, Color newColorTwo)
            {
                return this;
            }
        }
        public List<string> leveledPerfabPaths;
        private List<GameObject> leveledPerfabs;

        internal override GameObject GetGameObjects(uint level, Rot4 rot)
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
                return leveledPerfabs[(int)level];
        }

        public override void ResolveReferences(ThingDef parentDef)
        {
            parentDef.graphicData.graphicClass = typeof(Graphic_Perfab_Single);
            parentDef.graphic = null;
            parentDef.drawerType = DrawerType.RealtimeOnly;
            if(parentDef.staticSunShadowHeight < 1) parentDef.staticSunShadowHeight = 1; 
        }

        ~CompProperties_SinglePerfabDrawer()
        {
            foreach (GameObject gameObject in leveledPerfabs)
            {
                UnityEngine.Object.Destroy(gameObject);
            }
        }
    }

    //multi view perfab drawer
    public class CompProperties_MultiPerfabDrawer : CompProperties_PerfabDrawer
    {
        public struct PerfabPathInfo
        {
            public string north;
            public string south;
            public string west;
            public string east;
        }
        public struct PerfabInfo
        {
            public GameObject north;
            public GameObject south;
            public GameObject west;
            public GameObject east;
        }
        //do not use this class in xml def file, it will setting automatically when you use this comp
        private class Graphic_Perfab_Multi : Graphic_Multi
        {
            public override void DrawWorker(Vector3 loc, Rot4 rot, ThingDef thingDef, Thing thing, float extraRotation)
            {
                CompPerfabDrawer.UnityGameObjectUpdater obj = thing.TryGetComp<CompPerfabDrawer>()?.UnityGameObjectUpdaterComponet(rot);
                if(obj)
                {
                    loc += DrawOffset(rot);
                    if(obj.maskTransform)
                    {
                        obj.maskTransform.localPosition = new Vector3(0,loc.y / thingDef.staticSunShadowHeight,0);
                        obj.ownTransform.position = new Vector3(loc.x,0,loc.z);
                    }
                    else
                    {
                        obj.ownTransform.position = loc;
                    }
                    obj.ownTransform.localScale = new Vector3(drawSize.x, thingDef.staticSunShadowHeight, drawSize.y);
                    obj.ownTransform.rotation = Quaternion.Euler(0,extraRotation + rot.AsAngle,0);
                    obj.expirationTick = 6000;
                    obj.showInNextFrame = true;
                }
                else base.DrawWorker(loc, rot, thingDef, thing, extraRotation);
            }

            public override Graphic GetColoredVersion(Shader newShader, Color newColor, Color newColorTwo)
            {
                return this;
            }
        }
        public List<PerfabPathInfo> leveledPerfabPaths;
        private List<PerfabInfo> leveledPerfabs;

        internal override GameObject GetGameObjects(uint level, Rot4 rot)
        {
            if(leveledPerfabs == null)
            {
                leveledPerfabs = new List<PerfabInfo>();
                if(!leveledPerfabPaths.NullOrEmpty())
                {
                    leveledPerfabs.Capacity = leveledPerfabPaths.Count;
                    foreach (PerfabPathInfo path in leveledPerfabPaths)
                    {
                        PerfabInfo info = new PerfabInfo();
                        info.north = AssetBundleHelper.EffectAssetBundle.LoadAsset<GameObject>(path.north);
                        info.south = AssetBundleHelper.EffectAssetBundle.LoadAsset<GameObject>(path.south);
                        info.west = AssetBundleHelper.EffectAssetBundle.LoadAsset<GameObject>(path.west);
                        info.east = AssetBundleHelper.EffectAssetBundle.LoadAsset<GameObject>(path.east);
                        leveledPerfabs.Add(info);
                    }
                }
            }
            PerfabInfo targetLevel = leveledPerfabs[(int)level];
            switch(rot.AsInt)
            {
                case Rot4.NorthInt:
                return targetLevel.north;
                case Rot4.SouthInt:
                return targetLevel.south;
                case Rot4.WestInt:
                return targetLevel.west;
                case Rot4.EastInt:
                return targetLevel.east;
                default:
                return targetLevel.north;
            }
        }

        public override void ResolveReferences(ThingDef parentDef)
        {
            parentDef.graphicData.graphicClass = typeof(Graphic_Perfab_Multi);
            parentDef.graphic = null;
            parentDef.drawerType = DrawerType.RealtimeOnly;
            if(parentDef.staticSunShadowHeight < 1) parentDef.staticSunShadowHeight = 1; 
        }

        ~CompProperties_MultiPerfabDrawer()
        {
            foreach (PerfabInfo gameObject in leveledPerfabs)
            {
                if(gameObject.north) UnityEngine.Object.Destroy(gameObject.north);
                if(gameObject.south) UnityEngine.Object.Destroy(gameObject.south);
                if(gameObject.west) UnityEngine.Object.Destroy(gameObject.west);
                if(gameObject.east) UnityEngine.Object.Destroy(gameObject.east);
            }
        }
    }
}
