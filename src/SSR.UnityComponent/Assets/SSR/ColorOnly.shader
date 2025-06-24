Shader "Unlit/ColorOnly"
{
    Properties
    {
        _OutlineWidth ("Outline Width", Float) = 0.015625
        _Color ("Color", Color) = (1,1,1,1) 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent-100"}
        LOD 100
        Cull Off

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
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 model : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            float4 _Color;
            sampler2D _DepthTex;
            float4 _DepthTex_ST;

            float Rel2AnimShadow(float rel)
            {
                rel = clamp(rel, 0.0, 1.0);
                return round(rel * 2.0) * 0.3333 + 0.3333;
            }


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _DepthTex);
                o.model = v.vertex;
                o.normal = UnityObjectToWorldNormal(v.normal);
                float l = length(o.normal);
                if(l < 0.001) o.normal = float3(0,1,0);
                else o.normal /= l;
                return o;
            }

            fixed4 frag (v2f i, out float depth : SV_DEPTH) : SV_Target
            {
                // sample the texture
                UNITY_SETUP_INSTANCE_ID(i);
                i.model.y -= tex2D(_DepthTex, i.uv).x - 0.5;
                i.model = UnityObjectToClipPos(i.model);
                depth = i.model.z / i.model.w;

                // apply fog
                return _Color * Rel2AnimShadow(dot(i.normal, float3(0,1,1)) / 1.414);
            }
            ENDCG
        }
    }
}
