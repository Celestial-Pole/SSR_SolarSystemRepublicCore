using UnityEditor;
using UnityEngine;


namespace SSR.UnityComponent
{

    public class SSRBlackHole : MonoBehaviour
    {
        private Material material;
        private Renderer _renderer;
        private Transform _transform;
        public Shader shader;
        public Texture2D warpMap;
        public float sizeIn = 0.125f;
        public float sizeOut = 0.25f;

        static int sizeIn_PropID = Shader.PropertyToID("sizeIn");
        static int sizeOut_PropID = Shader.PropertyToID("sizeOut");
        static int warpMap_PropID = Shader.PropertyToID("warpMap");

        // Start is called before the first frame update
        void Start()
        {
            if(shader != null)
            {
                _transform = base.transform;
                material = new Material(shader);
                material.renderQueue = 3002;
                _renderer = GetComponent<Renderer>();
                if(_renderer != null) _renderer.material = material;
            }
        }

        // Update is called once per frame
        void Update()
        {
            if(material != null && _renderer != null && warpMap != null)
            {
                material.SetFloat(sizeIn_PropID, sizeIn * _transform.lossyScale.x);
                material.SetFloat(sizeOut_PropID, sizeOut * _transform.lossyScale.x);
                material.SetTexture(warpMap_PropID, warpMap);
            }
        }

#if UNITY_EDITOR
        // void OnGUI()
        // {
        //     if(GUI.Button(new Rect(0,0,96,32),"SaveMesh"))
        //     {
        //         Mesh mesh = new Mesh();
        //         mesh.name = "Mesh_Plane";
        //         mesh.vertices = new Vector3[4]
        //         {
        //             new Vector3(-0.5f,0,0.5f),new Vector3(0.5f,0,0.5f),new Vector3(0.5f,0,-0.5f),new Vector3(-0.5f,0,-0.5f)
        //         };
        //         mesh.uv = new Vector2[4]
        //         {
        //             new Vector2(0,1),new Vector2(1,1),new Vector2(1,0),new Vector2(0,0)
        //         };
        //         mesh.triangles = new int[6]
        //         {
        //             0,1,2,
        //             0,2,3
        //         };
        //         // mesh.bounds = new Bounds(Vector3.zero, Vector3.one);
        //         mesh.RecalculateBounds();
        //         mesh.RecalculateNormals();
        //         mesh.RecalculateTangents();
        //         mesh.UploadMeshData(false);
        //         AssetDatabase.CreateAsset(mesh, "Assets/SSR/Mesh/Mesh_Plane.asset");
        //     }

        // }
#endif
    }
}
