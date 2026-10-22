#ifndef SSR_TURRET_SURFACE_LIGHTING
#define SSR_TURRET_SURFACE_LIGHTING

float _SurfaceLighting;
float3 _SurfaceKeyDirection, _SurfaceFillDirection, _SurfaceUpDirection;

//解析计算法线绕转轮轴旋转一周的漫反射均值，保持轴向端面和炮塔俯仰的体积照明。
float AverageRotorLambert(float axialNormal, float axialLight)
{
    float axial = axialNormal * axialLight;
    float radial = sqrt(max(0, (1 - axialNormal * axialNormal) * (1 - axialLight * axialLight)));
    if (radial < 0.00001 || axial >= radial) return max(0, axial);
    if (axial <= -radial) return 0;
    //只积分朝向光源的圆周区间，避免离散角度采样本身产生周期明暗。
    float litAngle = acos(clamp(-axial / radial, -1, 1));
    return (axial * litAngle + radial * sin(litAngle)) / UNITY_PI;
}

//结合半球环境光、柔和主辅光和宽高光，以独立平滑后的遮蔽纹理塑造凹槽层次。
float3 ShadeTurretSurface(float3 color, float2 uv, float4 geometry, float3 normal)
{
    if (_SurfaceLighting < 0.5 || geometry.a == 0) return color;
    float up = saturate(dot(normal, _SurfaceUpDirection) * 0.5 + 0.5);
    float key = saturate(dot(normal, _SurfaceKeyDirection));
    float fill = saturate(dot(normal, _SurfaceFillDirection));
    float diffuse = lerp(0.34, 0.60, up) + key * 0.42 + fill * 0.12;
    float rotorBlend = geometry.a < 0 ? _RotorLightingBlend : 0;
    if (rotorBlend > 0)
    {
        float axialNormal = clamp(dot(normal, _RotorAxisDirection), -1, 1);
        float averageUp = dot(_SurfaceUpDirection, _RotorAxisDirection) * axialNormal * 0.5 + 0.5;
        float averageKey = AverageRotorLambert(axialNormal, dot(_SurfaceKeyDirection, _RotorAxisDirection));
        float averageFill = AverageRotorLambert(axialNormal, dot(_SurfaceFillDirection, _RotorAxisDirection));
        float averageDiffuse = lerp(0.34, 0.60, averageUp) + averageKey * 0.42 + averageFill * 0.12;
        diffuse = lerp(diffuse, averageDiffuse, rotorBlend);
    }
    float3 viewDirection = _SurfaceProjection.z > 0.5 ? float3(0, 0, 1) : normalize(-geometry.xyz);
    float3 halfDirection = normalize(_SurfaceKeyDirection + viewDirection);
    float highlight = pow(saturate(dot(normal, halfDirection)), 24) * key * 0.028 * (1 - rotorBlend);
    float visibility = tex2D(_ContactVisibilityTex, uv).r;
    return (color * diffuse + highlight) * visibility;
}

#endif
