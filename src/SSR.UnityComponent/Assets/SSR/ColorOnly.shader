Shader "Unlit/ColorOnly"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MatTex ("Material Texture", 2D) = "white" {}
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
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float3 normal : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            float4 _Color;
            sampler2D _MatTex;
            float4 _MatTex_ST;

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
                o.viewDir = GetViewDir(UnityObjectToViewPos(v.vertex), o.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.normal = mul(UNITY_MATRIX_V, float4(o.normal, 0.0)).xyz;
                float l = length(o.normal);
                if(l < 0.001) o.normal = float3(0,0,1);
                else o.normal /= l;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                UNITY_SETUP_INSTANCE_ID(i);

                float4 outColor = float4(_Color.rgb * ShadingByMatTex(i.normal, i.viewDir).rgb, _Color.a);
                // apply fog
                return outColor;
            }
            ENDCG
        }
    }
}
