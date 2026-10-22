#ifndef SSR_TURRET_CONTACT_OCCLUSION
#define SSR_TURRET_CONTACT_OCCLUSION

float _SurfaceContactRadius, _SurfaceContactStrength;
float4 _SurfaceProjection;
float2 _ContactBlurDirection;
sampler2D _ContactVisibilityTex;

//将模型空间阴影半径投影到纹理坐标，透视与正交采集共用同一遮蔽尺度。
float2 TurretContactRadiusUV(float3 position)
{
    float distance = _SurfaceProjection.z > 0.5 ? 1 : max(0.0001, -position.z);
    return _SurfaceContactRadius * _SurfaceProjection.xy / distance;
}

//判断邻近表面对当前切平面的遮蔽，排除背景、共面误差及半径以外的几何。
float TurretContactSample(float2 uv, float3 position, float3 normal)
{
    float4 neighbor = Geometry(uv);
    if (neighbor.a == 0) return 0;
    float3 delta = neighbor.xyz - position;
    float distanceSquared = dot(delta, delta);
    float radius = _SurfaceContactRadius;
    if (distanceSquared <= radius * radius * 0.0001) return 0;
    float distance = sqrt(distanceSquared);
    float horizon = (dot(normal, delta) - radius * 0.015) / distance;
    float facing = smoothstep(0.06, 0.5, horizon);
    float attenuation = 1 - smoothstep(radius * 0.2, radius, distance);
    //高速转轮不作为逐帧变化的遮蔽物，避免它使邻近固定炮身也产生阴影闪动。
    float rotorVisibility = neighbor.a < 0 ? 1 - _RotorLightingBlend : 1;
    return facing * attenuation * rotorVisibility;
}

//在固定模型尺度的空间格点上改变采样方向，打散重复零件投影，采样格不随帧或分辨率变化。
float2 TurretContactRotation(float3 position)
{
    float2 cell = floor(position.xy / max(_SurfaceContactRadius * 0.04, 0.00001));
    float phase = frac(52.9829189 * frac(dot(cell, float2(0.06711056, 0.00583715)))) * 6.2831853;
    return float2(cos(phase), sin(phase));
}

//生成全分辨率的独立遮蔽纹理，以空间分散的采样方向避免固定核复制矩形零件的形状。
float4 CaptureTurretContact(v2f_img input) : SV_Target
{
    float2 uv = GeometryPixelCenter(input.uv);
    float4 center = Geometry(uv);
    float strength = _SurfaceContactStrength * (center.a < 0 ? 1 - _RotorLightingBlend : 1);
    if (center.a == 0 || _SurfaceContactRadius <= 0 || strength <= 0) return 1;
    float3 normal = UnpackTurretNormal(center.a);
    float2 radiusUV = TurretContactRadiusUV(center.xyz);
    float2 rotation = TurretContactRotation(center.xyz);
    const float2 samples[32] = {
        float2(0.125000, 0.000000), float2(-0.159645, 0.146248),
        float2(0.024436, -0.278438), float2(0.201222, 0.262459),
        float2(-0.369268, -0.065318), float2(0.349802, -0.222516),
        float2(-0.117002, 0.435242), float2(-0.223136, -0.429634),
        float2(0.484115, 0.176798), float2(-0.503641, 0.207896),
        float2(0.242788, -0.518824), float2(0.179414, 0.572001),
        float2(-0.540757, -0.313380), float2(0.634370, -0.139464),
        float2(-0.387146, 0.550675), float2(-0.089440, -0.690200),
        float2(0.549072, 0.462758), float2(-0.738878, 0.030555),
        float2(0.538955, -0.536332), float2(-0.036058, 0.779792),
        float2(-0.512818, -0.614527), float2(0.812360, 0.109302),
        float2(-0.688311, 0.478909), float2(0.188086, -0.836061),
        float2(0.435033, 0.759191), float2(-0.850448, -0.271316),
        float2(0.826102, -0.381680), float2(-0.357888, 0.855156),
        float2(-0.319407, -0.888034), float2(0.849909, 0.446688),
        float2(-0.944035, 0.248845), float2(0.536596, -0.834530)
    };
    float occlusion = 0;
    [unroll] for (int index = 0; index < 32; index++)
    {
        float2 sampleOffset = samples[index];
        float2 offset = float2(sampleOffset.x * rotation.x - sampleOffset.y * rotation.y,
            sampleOffset.x * rotation.y + sampleOffset.y * rotation.x);
        occlusion += TurretContactSample(uv + offset * radiusUV, center.xyz, normal);
    }
    float visibility = 1 - saturate(occlusion * (2.6 / 32)) * strength;
    return float4(visibility, 0, 0, 1);
}

//结合双方切平面距离和法线判断是否属于连续表面，阻止阴影滤波穿过部件边界。
float TurretContactSurfaceWeight(float4 center, float3 normal, float4 neighbor)
{
    if (neighbor.a == 0) return 0;
    //独立过滤固定表面和转轮，旋转切面不改变炮身滤波权重。
    if ((center.a < 0) != (neighbor.a < 0)) return 0;
    float3 neighborNormal = UnpackTurretNormal(neighbor.a);
    float3 delta = neighbor.xyz - center.xyz;
    float planeDistance = max(abs(dot(normal, delta)), abs(dot(neighborNormal, delta)));
    float distanceRatio = planeDistance / max(_SurfaceContactRadius * 0.12, 0.00001);
    return exp2(-distanceRatio * distanceRatio) * pow(saturate(dot(normal, neighborNormal)), 16);
}

//只对遮蔽强度做横向或纵向双边滤波，保持模型颜色、细节和外轮廓未经模糊。
float4 FilterTurretContact(v2f_img input) : SV_Target
{
    float2 uv = GeometryPixelCenter(input.uv);
    float4 center = Geometry(uv);
    if (center.a == 0 || (center.a < 0 && _RotorLightingBlend >= 1)) return 1;
    float3 normal = UnpackTurretNormal(center.a);
    float2 texel = abs(_GeometryTex_TexelSize.xy);
    float2 span = max(TurretContactRadiusUV(center.xyz) * 0.22, texel * 2);
    float2 stride = span * _ContactBlurDirection / 4;
    float weighted = tex2D(_MainTex, uv).r;
    float totalWeight = 1;
    [unroll] for (int index = -4; index <= 4; index++)
    {
        if (index == 0) continue;
        float2 neighborUV = uv + stride * index;
        float4 neighbor = Geometry(neighborUV);
        float weight = exp2(-0.18 * index * index) * TurretContactSurfaceWeight(center, normal, neighbor);
        weighted += tex2D(_MainTex, neighborUV).r * weight;
        totalWeight += weight;
    }
    return float4(weighted / totalWeight, 0, 0, 1);
}

#endif
