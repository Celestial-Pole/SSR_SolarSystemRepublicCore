Shader "Unlit/JetFlow"
{
    Properties
    {
        _DepthTex ("Depth Texture", 2D) = "gray" {}
        _Seed ("Seed", Int) = 64
        _DiskCount ("Disk Count", Int) = 4
        _ExpendCurve ("Expend Curve", Float) = 0.5
        _DiskStart ("Disk Start", Range(0,1)) = 0.2
        _DiskEnd ("Disk End", Range(0,0.5)) = 0.5
        _InColor ("In Color", Color) = (1,1,1,1)
        _OutColor ("Out Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent-100" }
        LOD 100
        Blend One One
        ZWrite Off
        Cull Off
        CGINCLUDE
        #include "UnityCG.cginc"

        int2 Vec2FromSeed(uint seed)
        {
            return int2(sqrt(seed), sqrt(seed << 1));
        }

        float Hash1In2D(int2 p, uint seed)
        {
            int2 vec = Vec2FromSeed(seed);
            int l = vec.x * vec.x + vec.y * vec.y;
            float2 n = l < 1 ? vec / l : vec;
            return 2 * frac(sin(dot(p, n)) * max(l, 1 / l)) - 1;
        }

        float2 Hash2In2D(int2 p, uint seed)
        {
            
            return float2(
                Hash1In2D(p, sqrt(seed)),
                Hash1In2D(p, sqrt(seed << 1))
            );
        }

        float PerlinNoise(float2 p, uint seed)
        {
            int2 i = floor(p);
            float2 f = frac(p);
            float2 w = f * f * f * (6 * f * f -15 * f + 10);
            // float2 w = f;
            float2 a = Hash2In2D(i + int2(0, 0), seed);
            float2 b = Hash2In2D(i + int2(1, 0), seed);
            float2 c = Hash2In2D(i + int2(0, 1), seed);
            float2 d = Hash2In2D(i + int2(1, 1), seed);
            return lerp(
                lerp(dot(a, f - float2(0, 0)), dot(b, f - float2(1, 0)), w.x),
                lerp(dot(c, f - float2(0, 1)), dot(d, f - float2(1, 1)), w.x),
            w.y);
        }

        // float LoopingPerlinNoise(uint2 size, float2 p, uint seed)
        // {
            
        //     float2 i = floor(p);
        //     float2 f = frac(p);
        //     float2 w = f * f * f * (6 * f * f -15 * f + 10);
        //     // float2 w = f;
        //     float2 a = Hash2In2D((i + int2(0, 0)) % size, seed);
        //     float2 b = Hash2In2D((i + int2(1, 0)) % size, seed);
        //     float2 c = Hash2In2D((i + int2(0, 1)) % size, seed);
        //     float2 d = Hash2In2D((i + int2(1, 1)) % size, seed);
        //     return lerp(
        //         lerp(dot(a, f - float2(0, 0)), dot(b, f - float2(1, 0)), w.x),
        //         lerp(dot(c, f - float2(0, 1)), dot(d, f - float2(1, 1)), w.x),
        //     w.y);
        // }

        // float ValueNoise(float2 p, uint seed)
        // {
        //     float2 i = floor(p);
        //     float2 f = frac(p);
        //     float a = Hash1In2D(i + float2(0, 0), seed);
        //     float b = Hash1In2D(i + float2(1, 0), seed);
        //     float c = Hash1In2D(i + float2(0, 1), seed);
        //     float d = Hash1In2D(i + float2(1, 1), seed);
        //     return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
        // }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uvDepth : TEXCOORD1;
                float4 model : TEXCOORD2;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _DepthTex;
            float4 _DepthTex_ST;
            uint _Seed;
            uint _DiskCount;
            float _ExpendCurve;
            float _DiskStart;
            float _DiskEnd;
            float4 _InColor;
            float4 _OutColor;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uvDepth = TRANSFORM_TEX(v.uv, _DepthTex);
                o.model = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                UNITY_SETUP_INSTANCE_ID(i);
                // float4 col = LoopingPerlinNoise(uint2(16,16), i.uv * 16, _Seed);
                // float4 col = ValueNoise(i.uv * 16, _Seed);
                _ExpendCurve = max(_ExpendCurve, 0);
                // float noise = 1;
                float noise = PerlinNoise(float2((i.uv.x - _Time.w) * 64, i.uv.y * 16), _Seed);
                noise = lerp(1 , noise / (1 - i.uv.x), i.uv.x);
                float scale = (1 - i.uv.x * i.uv.x) * max(noise, 0);
                float partX = frac(i.uv.x * _DiskCount);
                float bround = scale * (sin(partX * UNITY_PI) * _ExpendCurve + 1) / (_ExpendCurve + 1);
                // partX = 1 - partX;
                float diskEnd = scale * ((_DiskEnd + partX - 1) / _DiskEnd) / (_ExpendCurve + 1);
                float w = (_DiskStart * _DiskEnd - partX) / _DiskEnd;
                // float w = (1 - partX - _DiskStart) * 0.5;
                float diskStart = w > 0 ? scale * (1 - partX / _DiskEnd) / (_ExpendCurve + 1) : 0;
                float r = abs(i.uv.y - 0.5) * 2;
                float4 col = _InColor * max(max(2 * (diskStart - r), 0) / diskStart, 0) * clamp(w / _DiskStart, 0, 1);
                col += _InColor * max(max(2 * (diskEnd - r), 0) / diskEnd, 0);
                col += clamp(2 * (bround - r) * r / bround, 0, 1) * _OutColor;
                // col += (clamp(2 * (r / bround), 0, 1) - clamp(2 * r * r / bround, 0, 1)) * _OutColor;
                col *= sin(max(1 - i.uv.x, 0) * UNITY_HALF_PI);
                // col = max(w / _DiskStart, 0);

                // apply fog
                return col;
            }
            ENDCG
        }
    }
}
