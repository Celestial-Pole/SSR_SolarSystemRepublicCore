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
                material.renderQueue = 2002;
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
