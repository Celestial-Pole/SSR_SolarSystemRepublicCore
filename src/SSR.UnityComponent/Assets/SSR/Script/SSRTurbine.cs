using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


namespace SSR.UnityComponent
{

    public class SSRTurbine : MonoBehaviour
    {
        public float poleAngle = 55f;
        public float holderLowPos = -0.225f;
        public float holderTopPos = 0.225f;
        public float turbinePos = 0.15f;
        public float turbineRotation = 0;
        public Vector2 turbineSize = new Vector2(1 / 3f,0.5f);
        public Mesh planeMesh;
        public Mesh turbineMesh;
        public Material pole;
        public Material turbine;
        public Material holderLow;
        public Material holderTop;
        private Transform transformCache;
        private Transform poleTransform;
        private Transform turbineTransform;
        private Transform holderLowTransform;
        private Transform holderTopTransform;
        private MeshRenderer poleRenderer;
        private MeshRenderer turbineRenderer;
        private MeshRenderer holderLowRenderer;
        private MeshRenderer holderTopRenderer;

        private int _MaskTransIndex;
        // Start is called before the first frame update
        void Start()
        {
            _MaskTransIndex = Shader.PropertyToID("_MaskTrans");
            //turbineMesh = new Mesh();
            //turbineMesh.name = "Mesh_Turbine";

            //List<Vector3> postions = new List<Vector3>(40);
            //List<Vector2> uvs = new List<Vector2>(40);
            //List<int> index = new List<int>(84);
            //for (int i = 0; i < 4; i++)
            //{
            //    float scaledIndex = (i - 1.5f) * 0.618f + 1.5f;
            //    Vector3 p = new Vector3(Mathf.Cos((scaledIndex + 3) * Mathf.PI / 9f) * 0.5f, -Mathf.Sin((scaledIndex + 3) * Mathf.PI / 9f) * 0.5f);
            //    Vector3 ps = p * 0.9375f;
            //    p.z = 0.5f;
            //    ps.z = 0.5f;
            //    postions.Add(p);
            //    postions.Add(ps);
            //    p.z = -0.5f;
            //    ps.z = -0.5f;
            //    postions.Add(p);
            //    postions.Add(ps);
            //    float uv_x0 = i / 6f;
            //    float uv_x1 = uv_x0 + 0.5f;
            //    uvs.Add(new Vector2(uv_x0, 1));
            //    uvs.Add(new Vector2(uv_x1, 1));
            //    uvs.Add(new Vector2(uv_x0, 0));
            //    uvs.Add(new Vector2(uv_x1, 0));
            //}
            //postions.AddRange(postions);
            //for (int i = 0; i < 4; i++)
            //{
            //    postions.Add(postions[i]);
            //    postions.Add(postions[i + 12]);
            //}

            //for (int i = 0; i < 24; i++)
            //{
            //    uvs.Add(Vector2.zero);
            //}

            //for (int i = 0; i < 3; i++)
            //{
            //    //outside
            //    index.Add(i * 4);
            //    index.Add(i * 4 + 4);
            //    index.Add(i * 4 + 2);
            //    index.Add(i * 4 + 6);
            //    index.Add(i * 4 + 2);
            //    index.Add(i * 4 + 4);
            //    //inside
            //    index.Add(i * 4 + 5);
            //    index.Add(i * 4 + 1);
            //    index.Add(i * 4 + 3);
            //    index.Add(i * 4 + 3);
            //    index.Add(i * 4 + 7);
            //    index.Add(i * 4 + 5);
            //    //top
            //    index.Add(i * 4 + 16);
            //    index.Add(i * 4 + 17);
            //    index.Add(i * 4 + 20);
            //    index.Add(i * 4 + 17);
            //    index.Add(i * 4 + 21);
            //    index.Add(i * 4 + 20);
            //    //low
            //    index.Add(i * 4 + 19);
            //    index.Add(i * 4 + 18);
            //    index.Add(i * 4 + 22);
            //    index.Add(i * 4 + 19);
            //    index.Add(i * 4 + 22);
            //    index.Add(i * 4 + 23);
            //}

            //index.Add(36);
            //index.Add(34);
            //index.Add(32);
            //index.Add(36);
            //index.Add(38);
            //index.Add(34);

            //index.Add(33);
            //index.Add(35);
            //index.Add(37);
            //index.Add(35);
            //index.Add(39);
            //index.Add(37);

            //Mesh mesh_part = new Mesh();
            //mesh_part.vertices = postions.ToArray();
            //mesh_part.uv = uvs.ToArray();
            //mesh_part.triangles = index.ToArray();
            //mesh_part.RecalculateNormals();
            //mesh_part.RecalculateTangents();
            //mesh_part.RecalculateBounds();

            //CombineInstance combineInstance = new CombineInstance();
            //combineInstance.mesh = mesh_part;
            //CombineInstance[] combineInstances = new CombineInstance[3];
            //for (int i = 0; i < combineInstances.Length; i++)
            //{
            //    combineInstance.transform = Matrix4x4.Rotate(Quaternion.Euler(Vector3.forward * 120 * i));
            //    combineInstances[i] = combineInstance;
            //}

            //turbineMesh.CombineMeshes(combineInstances);
            //turbineMesh.UploadMeshData(false);



            transformCache = transform;


            GameObject obj = new GameObject("pole");
            MeshFilter meshFilter = obj.AddComponent<MeshFilter>();
            poleRenderer = obj.AddComponent<MeshRenderer>();
            meshFilter.mesh = planeMesh;
            poleRenderer.material = pole;
            poleTransform = obj.transform;
            poleTransform.SetParent(transformCache);
            poleTransform.localPosition = Vector3.up * 0.5f * Mathf.Tan(Mathf.PI * poleAngle / 180f);
            poleTransform.localScale = new Vector3(1,1,1 / Mathf.Cos(Mathf.PI * poleAngle / 180f));
            poleTransform.localRotation = Quaternion.Euler(-poleAngle, 0, 0);

            obj = new GameObject("turbine");
            meshFilter = obj.AddComponent<MeshFilter>();
            turbineRenderer = obj.AddComponent<MeshRenderer>();
            meshFilter.mesh = turbineMesh;
            turbineRenderer.material = turbine;
            turbineTransform = obj.transform;
            turbineTransform.SetParent(poleTransform);
            turbineTransform.localPosition = Vector3.forward * turbinePos;
            turbineTransform.localScale = new Vector3(turbineSize.x, turbineSize.x, turbineSize.y);
            turbineTransform.localRotation = Quaternion.Euler(0, 0, turbineRotation);

            obj = new GameObject("holderLow");
            meshFilter = obj.AddComponent<MeshFilter>();
            holderLowRenderer = obj.AddComponent<MeshRenderer>();
            meshFilter.mesh = planeMesh;
            holderLowRenderer.material = holderLow;
            holderLowTransform = obj.transform;
            holderLowTransform.SetParent(turbineTransform);
            holderLowTransform.localPosition = Vector3.forward * holderLowPos;
            holderLowTransform.localScale = new Vector3(1f / turbineSize.x, 1f / turbineSize.y, 1f / turbineSize.x);
            holderLowTransform.localRotation = Quaternion.Euler(90, 0, 0);

            obj = new GameObject("holderTop");
            meshFilter = obj.AddComponent<MeshFilter>();
            holderTopRenderer = obj.AddComponent<MeshRenderer>();
            meshFilter.mesh = planeMesh;
            holderTopRenderer.material = holderTop;
            holderTopTransform = obj.transform;
            holderTopTransform.SetParent(turbineTransform);
            holderTopTransform.localPosition = Vector3.forward * holderTopPos;
            holderTopTransform.localScale = new Vector3(1f / turbineSize.x, 1f / turbineSize.y, 1f / turbineSize.x);
            holderTopTransform.localRotation = Quaternion.Euler(90, 0, 0);
        }

        // Update is called once per frame
        void Update()
        {
            if (turbineMesh != null && planeMesh != null)
            {
                poleTransform.localPosition = Vector3.up * 0.5f * Mathf.Tan(Mathf.PI * poleAngle / 180f);
                poleTransform.localScale = new Vector3(1, 1, 1 / Mathf.Cos(Mathf.PI * poleAngle / 180f));
                poleTransform.localRotation = Quaternion.Euler(-poleAngle, 0, 0);

                turbineTransform.localPosition = Vector3.forward * turbinePos;
                turbineTransform.localScale = new Vector3(turbineSize.x, turbineSize.x, turbineSize.y);
                turbineTransform.localRotation = Quaternion.Euler(0, 0, turbineRotation);

                holderLowTransform.localPosition = Vector3.forward * holderLowPos;
                holderLowTransform.localScale = new Vector3(1f / turbineSize.x, 1f / turbineSize.y, 1f / turbineSize.x);
                holderLowTransform.localRotation = Quaternion.Euler(90, 0, 0);

                holderTopTransform.localPosition = Vector3.forward * holderTopPos;
                holderTopTransform.localScale = new Vector3(1f / turbineSize.x, 1f / turbineSize.y, 1f / turbineSize.x);
                holderTopTransform.localRotation = Quaternion.Euler(90, 0, 0);
            }

        }

#if UNITY_EDITOR
        //void OnGUI()
        //{
        //    if (GUI.Button(new Rect(0, 0, 96, 32), "SaveMesh"))
        //    {
        //        AssetDatabase.CreateAsset(turbineMesh, "Assets/SSR/Mesh/Mesh_Turbine.asset");
        //    }

        //}
#endif
    }
}
