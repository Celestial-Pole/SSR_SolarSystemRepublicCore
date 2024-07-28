Shader "Unlit/DepthMask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "gray" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend Zero One
        ZTest GEqual

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 model : TEXCOORD1;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.model = v.vertex;
                return o;
            }

            float4 frag (v2f i, out float depth : SV_DEPTH) : SV_Target
            {
                // sample the texture
                UNITY_SETUP_INSTANCE_ID(i);
                float4 col = tex2D(_MainTex, i.uv);
                if(col.w <= 0.0) discard;
                i.model.y -= (col.x - 0.5) * col.w;
                i.model = UnityObjectToClipPos(i.model);
                depth = i.model.z / i.model.w;
                // apply fog
                return depth;
            }
            ENDCG
        }
    }
}
