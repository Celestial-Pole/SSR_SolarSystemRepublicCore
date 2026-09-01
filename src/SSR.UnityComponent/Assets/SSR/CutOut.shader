Shader "Unlit/CutOut"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MatTex ("Material Texture", 2D) = "white" {}
        _DepthTex ("Depth Texture", 2D) = "gray" {}
        _DepthFactor ("Depth Factor", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
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
                float2 uvDepth : TEXCOORD1;
                float3 viewPos : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                float3 normal : TEXCOORD4;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DepthTex;
            float4 _DepthTex_ST;
            sampler2D _MatTex;
            float4 _MatTex_ST;
            float _DepthFactor;

            float3 GetViewDir(float3 viewPos, out float4 clipPos)
            {
                clipPos = UnityViewToClipPos(viewPos);
                float3 near = viewPos;
                near.z = sign(near.z) * _ProjectionParams.y;
                near.xy *= UnityViewToClipPos(float3(0,0,near.z)).w / clipPos.w;
                float3 far = viewPos;
                far.z = sign(far.z) * _ProjectionParams.z;
                far.xy *= UnityViewToClipPos(float3(0,0,far.z)).w / clipPos.w;
                return far - near;
            }

            float4 ShadingByMatTex(float3 normal, float3 viewDir)
            {
                float3 reflectDir = normalize(reflect(viewDir, normal));
                float d = length(reflectDir.xy);
                reflectDir.xy *= (1 + d - reflectDir.z) / (2 * d * sqrt(1 + d));
                // reflectDir.xy = -2 * reflectDir.xy * reflectDir.z;
                return tex2D(_MatTex, TRANSFORM_TEX((reflectDir.xy * 0.5 + 0.5), _MatTex));
                // return float4(reflectDir.xy, 0, 1);
                // return float4(normal.xy, 0, 1);
            }


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvDepth = TRANSFORM_TEX(v.uv, _DepthTex);
                o.viewPos = UnityObjectToViewPos(v.vertex);
                o.viewDir = GetViewDir(o.viewPos, o.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.normal = mul(UNITY_MATRIX_V, float4(o.normal, 0.0)).xyz;
                float l = length(o.normal);
                if(l < 0.001) o.normal = float3(0,0,1);
                else o.normal /= l;
                return o;
            }

            fixed4 frag (v2f i, out float depth : SV_DEPTH) : SV_Target
            {
                // sample the texture
                UNITY_SETUP_INSTANCE_ID(i);
                float4 col = tex2D(_MainTex, i.uv);
                if(col.a < 0.5) discard;
                i.viewPos.z -= (tex2D(_DepthTex, i.uvDepth).x - 0.5) * _DepthFactor;
                i.vertex = UnityViewToClipPos(i.viewPos);
                depth = i.vertex.z / i.vertex.w;

                float4 outColor = float4(col.rgb * ShadingByMatTex(i.normal, i.viewDir).rgb, col.a);
                // apply fog
                return outColor;
            }
            ENDCG
        }
    }
}
