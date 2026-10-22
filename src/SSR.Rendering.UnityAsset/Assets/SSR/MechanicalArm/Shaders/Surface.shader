Shader "SSR/MechanicalArm/Surface"
{
    Properties { _MainTex ("贴图", 2D) = "white" {} _Color ("颜色", Color) = (1,1,1,1) }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off ZWrite On
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            fixed4 _Color;
            struct v2f { float4 pos : SV_POSITION; float2 uv : TEXCOORD0; };
            //纹理颜色交给核心后处理计算照明。
            v2f vert(appdata_base v) { v2f o; o.pos=UnityObjectToClipPos(v.vertex); o.uv=v.texcoord; return o; }
            fixed4 frag(v2f i) : SV_Target { return tex2D(_MainTex,i.uv)*_Color; }
            ENDCG
        }
    }
}
