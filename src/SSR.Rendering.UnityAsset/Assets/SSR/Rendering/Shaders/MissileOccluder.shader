Shader "SSR/Missiles/Occluder"
{
    SubShader
    {
        Cull Off ZWrite On ZTest LEqual ColorMask 0
        Pass
        {
            CGPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #include "UnityCG.cginc"
            float _ClipGround;
            //携带逐像素地面裁切所需的真实高度。
            struct Varyings { float4 position : SV_POSITION; float height : TEXCOORD0; };
            //生成井体与井盖的透明通道遮挡深度。
            Varyings Vert(appdata_base input)
            {
                Varyings output;
                output.position = UnityObjectToClipPos(input.vertex);
                output.height = mul(unity_ObjectToWorld, input.vertex).y;
                return output;
            }
            //只保留地面以上的遮挡，颜色写入由通道状态关闭。
            fixed4 Frag(Varyings input) : SV_Target
            {
                if (_ClipGround > 0.5) clip(input.height);
                return 0;
            }
            ENDCG
        }
    }
}
