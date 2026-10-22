Shader "SSR/MechanicalArm/HeldThing"
{
    Properties
    {
        _MainTex ("物品贴图", 2D) = "white" {}
        _MaskTex ("染色遮罩", 2D) = "black" {}
        _Color ("颜色", Color) = (1,1,1,1)
        _ColorTwo ("第二颜色", Color) = (1,1,1,1)
        _UseMask ("使用染色遮罩", Float) = 0
    }
    SubShader
    {
        Tags { "Queue"="Overlay+1000" "RenderType"="Transparent" }
        Cull Off ZWrite Off ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha
        CGINCLUDE
        #include "UnityCG.cginc"
        sampler2D _MainTex, _MaskTex;
        fixed4 _Color, _ColorTwo;
        float _UseMask;
        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };
        //物品按地图坐标直接叠加，透明区域保留背景。
        v2f vert(appdata_base v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }
        fixed4 color(v2f i) : SV_Target
        {
            fixed4 tex = tex2D(_MainTex,i.uv);
            clip(tex.a * _Color.a - 0.01);
            fixed4 tint = _Color;
            if (_UseMask > .5)
            {
                fixed4 mask = tex2D(_MaskTex,i.uv);
                tint.rgb = lerp(1, _Color.rgb, mask.r);
                tint.rgb = lerp(tint.rgb, _ColorTwo.rgb, mask.g);
            }
            return fixed4(tex.rgb * tint.rgb, tex.a * _Color.a);
        }
        ENDCG
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment color
            ENDCG
        }
    }
}
