Shader "Unlit/WormHole"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
        // background ("background", 2D) = "black" {}
        warpMap ("warpMap", 2D) = "white" {}
        sizeIn ("size in", Float) = 0.5
        sizeOut ("size out", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent-98" }
        LOD 100
        GrabPass
        {
            "background"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float3 viewSpacePos : TEXCOORD0;
                float3 viewSpaceZeroPoint : TEXCOORD1;
                float4 uvBackground : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D background;
            sampler2D warpMap;
            float4 _MainTex_ST;
            float4 warpMap_TexelSize;
            float sizeIn;
            float sizeOut;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvBackground = o.vertex;
                o.uvBackground.y *= _ProjectionParams.x;
                o.viewSpacePos = UnityObjectToViewPos(v.vertex);
                o.viewSpacePos.y *= _ProjectionParams.x;
                o.viewSpaceZeroPoint = UnityObjectToViewPos(float3(0,0,0));
                o.viewSpaceZeroPoint.y *= _ProjectionParams.x;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float warpMaper = length(i.viewSpacePos.xy - i.viewSpaceZeroPoint.xy) - sizeIn;
                float4 dir = mul(UNITY_MATRIX_P,float4(normalize(i.viewSpacePos.xy - i.viewSpaceZeroPoint.xy),i.viewSpacePos.z,1));
                float2 screenUV = i.uvBackground.xy/i.uvBackground.w;
                screenUV = 0.5 * screenUV + 0.5;
                // float2 screenUV = i.uv;
                float mapFactor = (warpMap_TexelSize.z - 1.0) * warpMap_TexelSize.x;
                float mapOffseter = 0.5 * warpMap_TexelSize.x;
                float2 inUV = screenUV + (1.0 / tex2Dlod(warpMap,float4(saturate(-warpMaper/sizeIn) * mapFactor + mapOffseter,0.25,0,0)).x - 1.0) * dir.xy/dir.w;
                float2 outUV = screenUV - (1.0 / tex2Dlod(warpMap,float4(saturate(warpMaper/(sizeOut-sizeIn)) * mapFactor + mapOffseter,0.75,0,0)).x - 1.0) * dir.xy/dir.w;
                return lerp(tex2Dlod(_MainTex,float4(inUV,0,0)),tex2Dlod(background,float4(outUV,0,0)),step(0,warpMaper));
            }
            ENDCG
        }
    }
}
