Shader "Unlit/Wireframe"
{
    Properties
    {
        [Toggle(ENABLE_EWS)] _EqualWidthStroke ("Equal width stroke", Float) = 0
        _OutlineWidth ("Outline Width", Float) = 0.015625
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent-100"}
        LOD 100
        Cull Off
        ZWrite Off
        // ZTest Less
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma shader_feature ENABLE_EWS
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 orginalVert : TEXCOORD0;
                float3 transposVert : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            float _OutlineWidth;
            sampler2D _DepthTex;
            float4 _DepthTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = float4(UnityObjectToViewPos(v.vertex),1);
                // float w = UnityViewToClipPos(o.vertex).w;
                // o.vertex.z += _OutlineWidth * sign(o.vertex.z);
                o.orginalVert = o.vertex.xyz;
                o.transposVert = o.vertex.xyz;
                o.vertex = UnityViewToClipPos(o.vertex.xyz);
                // w = o.vertex.w / w;
                // o.vertex.xy *= w;
                // o.orginalVert.xy *= w;
                // o.transposVert.xy *= w;
                // o.orginalViewDir = normalize(getViewDir(o.vertex));
                // o.transposViewDir = o.orginalViewDir;
                return o;
            }

            
            void convetLine(v2f from, v2f to, bool drawSpot, inout TriangleStream<v2f> outStream)
            // void convetLine(v2f from, v2f to, bool left, inout TriangleStream<v2f> outStream)
            {
                // float2 dirT = to.vertex.xy / to.vertex.w - from.vertex.xy / from.vertex.w;
                // dirT = (to.vertex.w <= 0 || from.vertex.w <= 0) ? -dirT : dirT;
                // dirT = mul(unity_CameraInvProjection, float4(dirT, 0, 0)).xy;
                // dirT = normalize(dirT) * _OutlineWidth;
                // dirT.y *= _ProjectionParams.x;
                // float2 dirL = left ? float2(dirT.y,-dirT.x) : float2(-dirT.y, dirT.x);
                // float2 dirL = float2(dirT.y,-dirT.x);
                float2 dirL = cross(from.vertex.xyw, to.vertex.xyw).xy;
                dirL = mul(unity_CameraInvProjection, float4(dirL, 0, 0)).xy;
                dirL = normalize(dirL) * _OutlineWidth;
                dirL.y *= _ProjectionParams.x;
                float2 dirT = float2(-dirL.y, dirL.x);



                v2f toSpotT = to;
                v2f toSpotL = to;

                v2f lineTL = to;
                v2f lineBL = from;
                
                v2f fromSpotB = from;
                v2f fromSpotL = from;

                #ifdef ENABLE_EWS
                float wFrom = abs(from.vertex.w);
                float wTo = abs(to.vertex.w);

                toSpotT.vertex = UnityViewToClipPos(toSpotT.transposVert + float3(dirT * 1.5 * wTo, 0));
                toSpotL.vertex = UnityViewToClipPos(toSpotL.transposVert + float3(dirL * 1.5 * wTo, 0));

                lineTL.vertex = UnityViewToClipPos(lineTL.transposVert + float3(dirL * wTo, 0));
                lineBL.vertex = UnityViewToClipPos(lineBL.transposVert + float3(dirL * wFrom, 0));

                fromSpotB.vertex = UnityViewToClipPos(fromSpotB.transposVert - float3(dirT * 1.5 * wFrom, 0));
                fromSpotL.vertex = UnityViewToClipPos(fromSpotL.transposVert + float3(dirL * 1.5 * wFrom, 0));
                #endif

                toSpotT.transposVert.xy += dirT * 1.5;
                toSpotL.transposVert.xy += dirL * 1.5;

                lineTL.transposVert.xy += dirL;
                lineBL.transposVert.xy += dirL;

                fromSpotB.transposVert.xy -= dirT * 1.5;
                fromSpotL.transposVert.xy += dirL * 1.5;
                
                #ifndef ENABLE_EWS
                toSpotT.vertex = UnityViewToClipPos(toSpotT.transposVert);
                toSpotL.vertex = UnityViewToClipPos(toSpotL.transposVert);

                lineTL.vertex = UnityViewToClipPos(lineTL.transposVert);
                lineBL.vertex = UnityViewToClipPos(lineBL.transposVert);

                fromSpotB.vertex = UnityViewToClipPos(fromSpotB.transposVert);
                fromSpotL.vertex = UnityViewToClipPos(fromSpotL.transposVert);
                #endif


                // _ZBufferParams
                
                if (drawSpot)
                {
                    //toSpot
                    outStream.Append(toSpotT);
                    outStream.Append(toSpotL);
                    outStream.Append(to);
                    outStream.RestartStrip();
                    
                    //fromSpot
                    outStream.Append(fromSpotB);
                    outStream.Append(fromSpotL);
                    outStream.Append(from);
                    outStream.RestartStrip();
                }

                //line
                outStream.Append(to);
                outStream.Append(from);
                outStream.Append(lineBL);
                outStream.RestartStrip();
                outStream.Append(lineBL);
                outStream.Append(lineTL);
                outStream.Append(to);
                outStream.RestartStrip();
            } 

            [maxvertexcount(36)] 
            void geom(triangle v2f input[3],inout TriangleStream<v2f> outStream)
            {
                float4 v0 = input[0].vertex;
                float4 v1 = input[1].vertex;
                float4 v2 = input[2].vertex;
                
                bool drawSpot = dot(v0.xyw, cross(v1.xyw, v2.xyw)) < 0;
                // if (!drawSpot)
                // {
                    convetLine(input[0],input[1],drawSpot,outStream);
                    convetLine(input[1],input[2],drawSpot,outStream);
                    convetLine(input[2],input[0],drawSpot,outStream);
                // }
            } 

            // fixed4 frag(v2f i) : SV_Target
            fixed4 frag(v2f i, out float depth : SV_DEPTH) : SV_Target
            {
                // sample the texture
                UNITY_SETUP_INSTANCE_ID(i);
                if(_OutlineWidth <= 0) discard;
                // i.transposViewDir = normalize(i.transposViewDir);
                float3 dir = i.transposVert.xyz-i.orginalVert.xyz;
                float disSq = dot(dir,dir);
                float outlineWidthSq = _OutlineWidth * _OutlineWidth;
                if(outlineWidthSq <= disSq) discard;

                float2 deeperVert = UnityViewToClipPos(float3(0,0,i.transposVert.z + 10 * sqrt(disSq) * sign(i.transposVert.z))).zw;
                // float2 deeperVert = UnityViewToClipPos(float3(0,0,i.transposVert.z + (10 * sqrt(disSq) + _OutlineWidth) * sign(i.transposVert.z))).zw;
                // float2 deeperVert = UnityViewToClipPos(i.transposVert + float3(0,0,10 * (_OutlineWidth - sqrt(outlineWidthSq - disSq)) * sign(i.transposVert.z))).zw;
                depth = deeperVert.x / deeperVert.y;

                // return i.color;
                return float4(0,0,0,1);
                // return float4(disSq.xxx,1);
                // i.transposVert.z = abs(i.transposVert.z);
                // return float4((i.transposVert + 1) * .5,1);
            }
            ENDCG
        }

    }
}