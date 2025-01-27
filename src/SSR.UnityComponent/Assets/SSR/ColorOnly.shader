Shader "Unlit/ColorOnly"
{
    Properties
    {
        _OutlineWidth ("Outline Width", Float) = 0.015625
        _Color ("Color", Color) = (1,1,1,1) 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderType"="2900"}
        LOD 100
        Pass
        {
            ZWrite Off
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 orginalVert : TEXCOORD0;
                float4 transposVert : TEXCOORD1;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            float _OutlineWidth;
            sampler2D _DepthTex;
            float4 _DepthTex_ST;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = mul(unity_ObjectToWorld, v.vertex);
                o.orginalVert = o.vertex;
                o.transposVert = o.vertex;
                return o;
            }

            
            void convetLine(v2f v1, v2f v2, inout TriangleStream<v2f> outStream)
            {
                float3 dirA = normalize(v1.vertex.xyz - _WorldSpaceCameraPos.xyz);
                float3 dirB = normalize(v1.vertex.xyz - v2.vertex.xyz);
                float3 dirC = normalize(cross(dirA,dirB));
                dirB = normalize(cross(dirC,dirA));
                v2f lt1 = v1;
                v2f rt1 = v1;
                v2f lt2 = v1;
                v2f rt2 = v1;
                // v2f lb1 = v2;
                // v2f rb1 = v2;
                v2f lb2 = v2;
                v2f rb2 = v2;
                lt1.vertex.xyz += dirB * _OutlineWidth;
                rt1.vertex.xyz += dirB * _OutlineWidth;
                // lb1.vertex.xyz -= dirB * _OutlineWidth;
                // rb1.vertex.xyz -= dirB * _OutlineWidth;
                
                lt1.vertex.xyz -= dirC * _OutlineWidth;
                rt1.vertex.xyz += dirC * _OutlineWidth;
                // lb1.vertex.xyz -= dirC * _OutlineWidth;
                // rb1.vertex.xyz += dirC * _OutlineWidth;
                lt2.vertex.xyz -= dirC * _OutlineWidth;
                rt2.vertex.xyz += dirC * _OutlineWidth;
                lb2.vertex.xyz -= dirC * _OutlineWidth;
                rb2.vertex.xyz += dirC * _OutlineWidth;
                lt1.transposVert = lt1.vertex;
                rt1.transposVert = rt1.vertex;
                // lb1.transposVert = lb1.vertex;
                // rb1.transposVert = rb1.vertex;
                lt2.transposVert = lt2.vertex;
                rt2.transposVert = rt2.vertex;
                lb2.transposVert = lb2.vertex;
                rb2.transposVert = rb2.vertex;
                lt1.vertex = UnityWorldToClipPos(lt1.vertex);
                rt1.vertex = UnityWorldToClipPos(rt1.vertex);
                // lb1.vertex = UnityWorldToClipPos(lb1.vertex);
                // rb1.vertex = UnityWorldToClipPos(rb1.vertex);
                lt2.vertex = UnityWorldToClipPos(lt2.vertex);
                rt2.vertex = UnityWorldToClipPos(rt2.vertex);
                lb2.vertex = UnityWorldToClipPos(lb2.vertex);
                rb2.vertex = UnityWorldToClipPos(rb2.vertex);
                outStream.Append(lt2);
                outStream.Append(rt2);
                outStream.Append(lb2);
                outStream.RestartStrip();
                outStream.Append(rt2);
                outStream.Append(lb2);
                outStream.Append(rb2);
                outStream.RestartStrip();
                outStream.Append(lt1);
                outStream.Append(rt1);
                outStream.Append(lt2);
                outStream.RestartStrip();
                outStream.Append(rt1);
                outStream.Append(lt2);
                outStream.Append(rt2);
                outStream.RestartStrip();
                // outStream.Append(lb1);
                // outStream.Append(rb1);
                // outStream.Append(lb2);
                // outStream.RestartStrip();
                // outStream.Append(rb1);
                // outStream.Append(lb2);
                // outStream.Append(rb2);
                // outStream.RestartStrip();
            } 

            [maxvertexcount(36)] 
            void geom(triangle v2f input[3],inout TriangleStream<v2f> outStream)
            {
                // float3 dirA = normalize(input[0].vertex.xyz - input[1].vertex.xyz);
                // float3 dirB = normalize(input[1].vertex.xyz - input[2].vertex.xyz);
                // float3 dirC = normalize(input[2].vertex.xyz - input[0].vertex.xyz);
                // float3 s = float3(
                //     abs(dot(dirA,dirB)) + abs(dot(dirA,dirC)),
                //     abs(dot(dirA,dirB)) + abs(dot(dirB,dirC)),
                //     abs(dot(dirA,dirC)) + abs(dot(dirB,dirC))
                //     );
                // float m = max(s.x,max(s.y,s.z));
                // if(m != s.x) convetLine(input[0],input[1],outStream);
                // if(m != s.y) convetLine(input[1],input[2],outStream);
                // if(m != s.z) convetLine(input[2],input[0],outStream);
                convetLine(input[0],input[1],outStream);
                convetLine(input[1],input[2],outStream);
                convetLine(input[2],input[0],outStream);
            } 

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                UNITY_SETUP_INSTANCE_ID(i);
                if(_OutlineWidth <= 0) discard;
                if(_OutlineWidth <= distance(i.transposVert.xyz,i.orginalVert.xyz)) discard;

                // apply fog
                return fixed4(0,0,0,1);
            }
            ENDCG
        }

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
                float4 model : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            float4 _Color;
            sampler2D _DepthTex;
            float4 _DepthTex_ST;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _DepthTex);
                o.model = v.vertex;
                o.normal = UnityObjectToWorldNormal(v.normal);
                float l = length(o.normal);
                if(l < 0.001) o.normal = float3(0,1,0);
                else o.normal /= l;
                return o;
            }

            fixed4 frag (v2f i, out float depth : SV_DEPTH) : SV_Target
            {
                // sample the texture
                UNITY_SETUP_INSTANCE_ID(i);
                i.model.y -= tex2D(_DepthTex, i.uv).x - 0.5;
                i.model = UnityObjectToClipPos(i.model);
                depth = i.model.z / i.model.w;

                // apply fog
                return _Color * dot(i.normal, float3(0,1,0));
            }
            ENDCG
        }
    }
}
