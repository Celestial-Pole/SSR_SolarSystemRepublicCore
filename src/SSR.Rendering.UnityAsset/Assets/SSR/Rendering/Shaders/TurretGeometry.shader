Shader "SSR/Rendering/Geometry"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off ZWrite On ZTest LEqual
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex Vert
            #pragma fragment Frag
            #include "UnityCG.cginc"
            #include "TurretGeometryPacking.cginc"
            float _ClipGround;
            float _RotatingSurface;

            //携带观察空间法线和真实表面位置。
            struct Varyings
            {
                float4 position : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 viewPosition : TEXCOORD1;
                float worldHeight : TEXCOORD2;
            };

            //将网格顶点和法线变换到采集相机空间。
            Varyings Vert(appdata_base input)
            {
                Varyings output;
                output.position = UnityObjectToClipPos(input.vertex);
                output.viewPosition = UnityObjectToViewPos(input.vertex);
                output.normal = mul((float3x3)UNITY_MATRIX_V, UnityObjectToWorldNormal(input.normal));
                output.worldHeight = mul(unity_ObjectToWorld, input.vertex).y;
                return output;
            }

            //保存表面位置和法线，以符号标记转轮而不损失法线编码精度。
            float4 Frag(Varyings input, fixed facing : VFACE) : SV_Target
            {
                if (_ClipGround > 0.5) clip(input.worldHeight);
                float3 normal = normalize(input.normal) * (facing >= 0 ? 1 : -1);
                float packed = PackTurretNormal(normal);
                return float4(input.viewPosition, _RotatingSurface > 0.5 ? -packed : packed);
            }
            ENDCG
        }
    }
}
