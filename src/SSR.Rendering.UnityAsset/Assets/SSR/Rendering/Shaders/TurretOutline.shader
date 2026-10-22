Shader "SSR/Rendering/Composite"
{
    Properties { _MainTex ("颜色纹理", 2D) = "black" {} }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        CGINCLUDE
        #include "UnityCG.cginc"
        #include "TurretGeometryPacking.cginc"
        sampler2D _MainTex;
        sampler2D _GeometryTex;
        float4 _MainTex_TexelSize;
        float4 _GeometryTex_TexelSize;
        float4 _OutlineColor;
        float _SilhouetteWidth, _StructureWidth, _NormalThreshold, _DepthThreshold, _Supersampling;
        float _OutputPremultiplied;
        float _ClipOutlineGround, _CaptureWorldHeight;
        float _GroundHeight;
        float _RotorLightingBlend;
        float3 _RotorAxisDirection;
        float4x4 _CaptureToWorld;

        //对齐点采样实际读取的像素中心，保持表面位置与编码法线来自同一像素。
        float2 GeometryPixelCenter(float2 uv)
        {
            return (floor(uv * _GeometryTex_TexelSize.zw) + 0.5) * abs(_GeometryTex_TexelSize.xy);
        }

        //保持两张手动采集纹理使用相同的坐标，超出画面的样本视为背景。
        float4 Geometry(float2 uv)
        {
            if (any(uv < 0) || any(uv > 1)) return 0;
            return tex2D(_GeometryTex, uv);
        }

        #include "TurretContactOcclusion.cginc"
        #include "TurretSurfaceLighting.cginc"

        //比较两个真实表面的切平面，保留遮挡断层及法线折角。
        float StructureAt(float2 neighborUV, float4 center, float3 centerNormal)
        {
            float4 neighbor = Geometry(neighborUV);
            if (center.a == 0 || neighbor.a == 0) return 0;
            float3 neighborNormal = UnpackTurretNormal(neighbor.a);
            float normalDelta = 1 - saturate(dot(centerNormal, neighborNormal));
            float3 delta = neighbor.xyz - center.xyz;
            float planeDistance = min(abs(dot(centerNormal, delta)), abs(dot(neighborNormal, delta)));
            float normalEdge = smoothstep(_NormalThreshold, _NormalThreshold * 1.2, normalDelta);
            float depthEdge = smoothstep(_DepthThreshold, _DepthThreshold * 1.5, planeDistance);
            return max(normalEdge, depthEdge);
        }

        //插值边缘强度而非几何属性，使小于一像素的线宽也能连续改变覆盖率。
        float Structure(float2 neighborUV, float4 center, float3 centerNormal)
        {
            float2 pixel = neighborUV * _GeometryTex_TexelSize.zw - 0.5;
            float2 fraction = frac(pixel);
            float2 texel = abs(_GeometryTex_TexelSize.xy);
            float2 first = (floor(pixel) + 0.5) * texel;
            float bottom = lerp(StructureAt(first, center, centerNormal),
                StructureAt(first + float2(texel.x, 0), center, centerNormal), fraction.x);
            float top = lerp(StructureAt(first + float2(0, texel.y), center, centerNormal),
                StructureAt(first + texel, center, centerNormal), fraction.x);
            return lerp(bottom, top, fraction.y);
        }

        //读取连续的颜色覆盖率，画面之外视为空白，避免硬阈值扩张外轮廓。
        float Coverage(float2 uv)
        {
            if (any(uv < 0) || any(uv > 1)) return 0;
            return tex2D(_MainTex, uv).a;
        }

        //采样八个方向，分别控制外轮廓和内部结构线的像素宽度。
        float4 Composite(v2f_img input) : SV_Target
        {
            float2 uv = input.uv;
            float4 source = tex2D(_MainTex, uv);
            float2 geometryUV = GeometryPixelCenter(uv);
            float4 center = Geometry(geometryUV);
            float occupied = step(0.000001, abs(center.a));
            float3 centerNormal = occupied > 0 ? UnpackTurretNormal(center.a) : float3(0, 0, 1);
            source.rgb = ShadeTurretSurface(source.rgb, geometryUV, center, centerNormal);
            float silhouette = 0, structure = 0;
            const float2 directions[8] = {
                float2(1,0), float2(-1,0), float2(0,1), float2(0,-1),
                float2(0.7071,0.7071), float2(-0.7071,0.7071),
                float2(0.7071,-0.7071), float2(-0.7071,-0.7071)
            };
            [unroll] for (int index = 0; index < 8; index++)
            {
                float2 offset = directions[index] * abs(_MainTex_TexelSize.xy);
                if (_SilhouetteWidth > 0)
                {
                    float neighbor = Coverage(uv + offset * _SilhouetteWidth);
                    if (_ClipOutlineGround > 0.5)
                    {
                        float4 surface = Geometry(uv + offset * _SilhouetteWidth);
                        float height = mul(_CaptureToWorld, float4(surface.xyz, 1)).y
                            - offset.y * _SilhouetteWidth * _CaptureWorldHeight;
                        neighbor *= step(0, height);
                    }
                    silhouette = max(silhouette, (1 - source.a) * neighbor);
                }
                if (_StructureWidth > 0 && occupied > 0)
                {
                    float2 neighborUV = geometryUV + offset * _StructureWidth * 0.5;
                    structure = max(structure, Structure(neighborUV, center, centerNormal));
                }
            }
            float edge = saturate(max(silhouette, structure)) * _OutlineColor.a;
            float alpha = source.a + edge * (1 - source.a);
            //使用预乘颜色合成，避免透明背景在缩小时产生黑边污染。
            float3 premultiplied = source.rgb * source.a * (1 - edge) + _OutlineColor.rgb * edge;
            return float4(premultiplied, alpha);
        }

        //平均高分辨率覆盖率；游戏保留预乘颜色，编辑器和 PNG 使用直通透明度。
        float4 Resolve(v2f_img input) : SV_Target
        {
            float4 value;
            if (_Supersampling > 1.5)
            {
                float2 offset = abs(_MainTex_TexelSize.xy) * 0.5;
                value = (tex2D(_MainTex, input.uv + offset) + tex2D(_MainTex, input.uv - offset)
                    + tex2D(_MainTex, input.uv + float2(offset.x, -offset.y))
                    + tex2D(_MainTex, input.uv + float2(-offset.x, offset.y))) * 0.25;
            }
            else value = tex2D(_MainTex, input.uv);
            if (_OutputPremultiplied < 0.5)
                value.rgb = value.a > 0.00001 ? value.rgb / value.a : 0;
            return value;
        }

        //轮廓沿用邻近实体的高度，空白背景保持零值。
        float SurfaceHeightAt(float2 uv)
        {
            float4 surface = Geometry(uv);
            if (surface.a != 0)
                return max(0, mul(_CaptureToWorld, float4(surface.xyz, 1)).y - _GroundHeight);
            float height = 0;
            const float2 directions[8] = {
                float2(1,0), float2(-1,0), float2(0,1), float2(0,-1),
                float2(0.7071,0.7071), float2(-0.7071,0.7071),
                float2(0.7071,-0.7071), float2(-0.7071,-0.7071)
            };
            [unroll] for (int index = 0; index < 8; index++)
            {
                float2 neighborUV = uv + directions[index] * abs(_GeometryTex_TexelSize.xy) * _SilhouetteWidth;
                float4 neighbor = Geometry(neighborUV);
                if (neighbor.a != 0)
                    height = max(height, mul(_CaptureToWorld, float4(neighbor.xyz, 1)).y - _GroundHeight);
            }
            return height;
        }

        //与颜色使用相同的超采样位置，边缘保留最近实体的高度。
        float ResolveSurfaceHeight(v2f_img input) : SV_Target
        {
            if (_Supersampling <= 1.5) return SurfaceHeightAt(input.uv);
            float2 offset = abs(_GeometryTex_TexelSize.xy) * 0.5;
            return max(max(SurfaceHeightAt(input.uv + offset), SurfaceHeightAt(input.uv - offset)),
                max(SurfaceHeightAt(input.uv + float2(offset.x, -offset.y)),
                    SurfaceHeightAt(input.uv + float2(-offset.x, offset.y))));
        }
        ENDCG
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment Composite
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment Resolve
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment CaptureTurretContact
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment FilterTurretContact
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment ResolveSurfaceHeight
            ENDCG
        }
    }
}
