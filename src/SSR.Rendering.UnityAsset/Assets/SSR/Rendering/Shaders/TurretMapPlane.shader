Shader "SSR/Rendering/MapPlane"
{
    Properties
    {
        _MainTex ("炮塔离屏纹理", 2D) = "black" {}
        _SurfaceHeightTex ("实体表面高度", 2D) = "black" {}
        _SurfaceDepthRange ("地图层内深度范围", Float) = 0
    }
    SubShader
    {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" }
        Cull Off ZWrite On ZTest LEqual
        Blend One OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex Vert
            #pragma fragment Fragment
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            sampler2D _SurfaceHeightTex;
            float _SurfaceDepthRange;

            //携带面片坐标，表面高度只影响深度，不改变屏幕投影。
            struct Varyings
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
            };

            //保持地图面片的原有位置和尺寸。
            Varyings Vert(appdata_img input)
            {
                Varyings output;
                output.position = UnityObjectToClipPos(input.vertex);
                output.uv = input.texcoord;
                output.worldPosition = mul(unity_ObjectToWorld, input.vertex).xyz;
                return output;
            }

            //按表面高度写入深度，单调压缩到原版层间，透明背景不遮挡其他物体。
            fixed4 Fragment(Varyings input, out float depth : SV_Depth) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, input.uv);
                clip(color.a - 0.001);
                float height = tex2D(_SurfaceHeightTex, input.uv).r;
                input.worldPosition.y += _SurfaceDepthRange * height / (1 + abs(height));
                float4 position = UnityWorldToClipPos(input.worldPosition);
                depth = position.z / position.w;
                #if !defined(UNITY_REVERSED_Z)
                    depth = (depth - UNITY_NEAR_CLIP_VALUE) / (1 - UNITY_NEAR_CLIP_VALUE);
                #endif
                return color;
            }
            ENDCG
        }
    }
}
