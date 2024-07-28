using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


namespace SSR.UnityComponent
{

    public class SSRLiffter : MonoBehaviour
    {
        public float width = 0.02001953125f;
        public Vector2[] cableStarts = new Vector2[] { new Vector2(0.114013671875f, 0.27490234375f), new Vector2(-0.00048828125f, 0.206298828125f) };
        public Vector2 cableEnd = new Vector2(-0.00048828125f, 0.09521484375f);
        public Vector2 cableEndDefault = new Vector2(-0.00048828125f, 0.09521484375f);
        public Mesh mesh;
        public Material depthMask;
        public Material liftter;
        public Material cableA;
        public Material cableB;
        public Material hookA;
        public Material hookB;
        private Transform transformCache;
        private Transform liftterTransform;
        private Transform depthMaskTransform;
        private Transform hookATransform;
        private Transform hookBTransform;
        private List<Transform> cableATransforms = new List<Transform>();
        private List<Transform> cableBTransforms = new List<Transform>();
        private MeshRenderer depthMaskRenderer;
        private MeshRenderer liftterRenderer;
        private MeshRenderer hookARenderer;
        private MeshRenderer hookBRenderer;
        private List<MeshRenderer> cableARenderers = new List<MeshRenderer>();
        private List<MeshRenderer> cableBRenderers = new List<MeshRenderer>();

        private int _MaskTransIndex;
        // Start is called before the first frame update
        void Start()
        {
            _MaskTransIndex = Shader.PropertyToID("_MaskTrans");
            //mesh = new Mesh();
            //mesh.name = "Mesh_Plane";
            //mesh.vertices = new Vector3[]
            //{
            //new Vector3( 0.5f,0.0f, 0.5f),
            //new Vector3(-0.5f,0.0f, 0.5f),
            //new Vector3(-0.5f,0.0f,-0.5f),
            //new Vector3( 0.5f,0.0f,-0.5f)
            //};
            //mesh.uv = new Vector2[]
            //{
            //new Vector2(1.0f,1.0f),
            //new Vector2(0.0f,1.0f),
            //new Vector2(0.0f,0.0f),
            //new Vector2(1.0f,0.0f),
            //};
            //mesh.triangles = new int[]
            //{
            //0, 2, 1,
            //2, 0, 3,
            //};
            transformCache = transform;
            Vector3 postion;



            MeshRenderer meshRenderer;
            GameObject obj = new GameObject("liftter");
            MeshFilter meshFilter = obj.AddComponent<MeshFilter>();
            liftterRenderer = obj.AddComponent<MeshRenderer>();
            meshFilter.mesh = mesh;
            liftterRenderer.material = liftter;
            liftterTransform = obj.transform;
            liftterTransform.SetParent(transformCache);
            liftterTransform.localPosition = Vector3.up * 0.05f;
            liftterTransform.localRotation = Quaternion.identity;
            liftterTransform.localScale = Vector3.one;


            obj = new GameObject("depthMask");
            meshFilter = obj.AddComponent<MeshFilter>();
            depthMaskRenderer = obj.AddComponent<MeshRenderer>();
            meshFilter.mesh = mesh;
            depthMaskRenderer.material = depthMask;
            depthMaskTransform = obj.transform;
            depthMaskTransform.SetParent(transformCache);
            depthMaskTransform.localPosition = Vector3.zero;
            depthMaskTransform.localRotation = Quaternion.identity;
            depthMaskTransform.localScale = Vector3.one;

            postion = new Vector3(cableEnd.x - cableEndDefault.x, 0, cableEnd.y - cableEndDefault.y);
            postion.y = (postion.z + 0.5f) * 0.45f - 0.5f;
            obj = new GameObject("hookA");
            meshFilter = obj.AddComponent<MeshFilter>();
            hookARenderer = obj.AddComponent<MeshRenderer>();
            meshFilter.mesh = mesh;
            hookARenderer.material = hookA;
            hookATransform = obj.transform;
            hookATransform.SetParent(transformCache);
            hookATransform.localPosition = postion;
            hookATransform.localRotation = Quaternion.LookRotation(new Vector3(0, 0.45f, 1), Vector3.up);
            hookATransform.localScale = new Vector3(1, 1, Mathf.Sqrt(1 + 0.45f * 0.45f));

            postion = new Vector3(cableEnd.x - cableEndDefault.x, 0, cableEnd.y - cableEndDefault.y);
            postion.y = (postion.z + 0.5f) * 0.35f - 0.5f;
            obj = new GameObject("hookB");
            meshFilter = obj.AddComponent<MeshFilter>();
            hookBRenderer = obj.AddComponent<MeshRenderer>();
            meshFilter.mesh = mesh;
            hookBRenderer.material = hookB;
            hookBTransform = obj.transform;
            hookBTransform.SetParent(transformCache);
            hookBTransform.localPosition = postion;
            hookBTransform.localRotation = Quaternion.LookRotation(new Vector3(0, 0.35f, 1), Vector3.up);
            hookBTransform.localScale = new Vector3(1, 1, Mathf.Sqrt(1 + 0.35f * 0.35f));

            cableATransforms.Capacity = cableStarts.Length;
            cableBTransforms.Capacity = cableStarts.Length;
            cableARenderers.Capacity = cableStarts.Length;
            cableBRenderers.Capacity = cableStarts.Length;

            GameObject cableAHolder = new GameObject("cableAHolder");
            Transform cableAHolderTransform = cableAHolder.transform;
            cableAHolderTransform.SetParent(transformCache);
            cableAHolderTransform.localPosition = new Vector3(0, 0.5f * 0.4f - 0.5f, 0);
            cableAHolderTransform.localRotation = Quaternion.LookRotation(new Vector3(0, 0.4f, 1), Vector3.up);
            cableAHolderTransform.localScale = new Vector3(1, 1, Mathf.Sqrt(1 + 0.4f * 0.4f));

            GameObject cableBHolder = new GameObject("cableBHolder");
            Transform cableBHolderTransform = cableBHolder.transform;
            cableBHolderTransform.SetParent(transformCache);
            cableBHolderTransform.localPosition = new Vector3(0, 0.5f * 0.3f - 0.5f, 0);
            cableBHolderTransform.localRotation = Quaternion.LookRotation(new Vector3(0, 0.3f, 1), Vector3.up);
            cableBHolderTransform.localScale = new Vector3(1, 1, Mathf.Sqrt(1 + 0.3f * 0.3f));

            for (int i = 0; i < cableStarts.Length; i++)
            {
                Vector2 start = cableStarts[i];

                obj = new GameObject($"cableA_{i}");
                meshFilter = obj.AddComponent<MeshFilter>();
                meshRenderer = obj.AddComponent<MeshRenderer>();
                meshFilter.mesh = mesh;
                meshRenderer.material = cableA;
                Transform cableATransform = obj.transform;
                cableATransforms.Add(cableATransform);
                cableARenderers.Add(meshRenderer);
                cableATransform.SetParent(cableAHolderTransform);
                cableATransform.localPosition = new Vector3((cableEnd.x + start.x) * 0.5f, 0, (cableEnd.y + start.y) * 0.5f);
                cableATransform.localRotation = Quaternion.LookRotation(new Vector3(cableEnd.x - start.x, 0, cableEnd.y - start.y), Vector3.up);
                cableATransform.localScale = new Vector3(width, 1.0f, (start - cableEnd).magnitude);

                obj = new GameObject($"cableB_{i}");
                meshFilter = obj.AddComponent<MeshFilter>();
                meshRenderer = obj.AddComponent<MeshRenderer>();
                meshFilter.mesh = mesh;
                meshRenderer.material = cableB;
                Transform cableBTransform = obj.transform;
                cableBTransforms.Add(cableBTransform);
                cableBRenderers.Add(meshRenderer);
                cableBTransform.SetParent(cableBHolderTransform);
                cableBTransform.localPosition = new Vector3((cableEnd.x + start.x) * 0.5f, 0, (cableEnd.y + start.y) * 0.5f);
                cableBTransform.localRotation = Quaternion.LookRotation(new Vector3(cableEnd.x - start.x, 0, cableEnd.y - start.y), Vector3.up);
                cableBTransform.localScale = new Vector3(width, 1.0f, (start - cableEnd).magnitude);
            }
            meshFilter = GetComponent<MeshFilter>();
            meshFilter.mesh = mesh;
        }

        // Update is called once per frame
        void Update()
        {
            if (mesh != null)
            {
                Vector3 postion;


                depthMaskRenderer.material = depthMask;
                liftterRenderer.material = liftter;
                hookARenderer.material = hookA;
                hookBRenderer.material = hookB;

                postion = new Vector3(cableEnd.x - cableEndDefault.x, 0, cableEnd.y - cableEndDefault.y);
                postion.y = (postion.z + 0.5f) * 0.45f - 0.5f;
                hookATransform.SetParent(transformCache);
                hookATransform.localPosition = postion;
                hookATransform.localRotation = Quaternion.LookRotation(new Vector3(0, 0.45f, 1), Vector3.up);
                hookATransform.localScale = new Vector3(1, 1, Mathf.Sqrt(1 + 0.45f * 0.45f));

                postion = new Vector3(cableEnd.x - cableEndDefault.x, 0, cableEnd.y - cableEndDefault.y);
                postion.y = (postion.z + 0.5f) * 0.35f - 0.5f;
                hookBTransform.SetParent(transformCache);
                hookBTransform.localPosition = postion;
                hookBTransform.localRotation = Quaternion.LookRotation(new Vector3(0, 0.35f, 1), Vector3.up);
                hookBTransform.localScale = new Vector3(1, 1, Mathf.Sqrt(1 + 0.35f * 0.35f));

                for (int i = 0; i < cableStarts.Length; i++)
                {
                    Vector2 start = cableStarts[i];
                    Transform cableATransform = cableATransforms[i];
                    Transform cableBTransform = cableBTransforms[i];
                    MeshRenderer cableARenderer = cableARenderers[i];
                    MeshRenderer cableBRenderer = cableBRenderers[i];

                    cableATransform.localPosition = new Vector3((cableEnd.x + start.x) * 0.5f, 0, (cableEnd.y + start.y) * 0.5f);
                    cableATransform.localRotation = Quaternion.LookRotation(new Vector3(cableEnd.x - start.x, 0, cableEnd.y - start.y), Vector3.up);
                    cableATransform.localScale = new Vector3(width, 1.0f, (start - cableEnd).magnitude);
                    cableARenderer.material = cableA;

                    cableBTransform.localPosition = new Vector3((cableEnd.x + start.x) * 0.5f, 0, (cableEnd.y + start.y) * 0.5f);
                    cableBTransform.localRotation = Quaternion.LookRotation(new Vector3(cableEnd.x - start.x, 0, cableEnd.y - start.y), Vector3.up);
                    cableBTransform.localScale = new Vector3(width, 1.0f, (start - cableEnd).magnitude);
                    cableBRenderer.material = cableB;

                }
            }

        }

#if UNITY_EDITOR
        //void OnGUI()
        //{
        //    if(GUI.Button(new Rect(0,0,96,32),"SaveMesh"))
        //    {
        //        AssetDatabase.CreateAsset(mesh, "Assets/SSR/Mesh/Mesh_Plane.asset");
        //    }

        //}
#endif
    }
}
