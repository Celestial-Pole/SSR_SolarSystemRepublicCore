#ifndef SSR_TURRET_GEOMETRY_PACKING
#define SSR_TURRET_GEOMETRY_PACKING

//把单位法线编码为两个十二位八面体坐标，零值专门表示空白背景。
float PackTurretNormal(float3 normal)
{
    normal /= abs(normal.x) + abs(normal.y) + abs(normal.z);
    float2 oct = normal.xy;
    if (normal.z < 0)
        oct = (1 - abs(oct.yx)) * float2(oct.x >= 0 ? 1 : -1, oct.y >= 0 ? 1 : -1);
    float2 packed = floor(saturate(oct * 0.5 + 0.5) * 4095 + 0.5);
    return packed.x + packed.y * 4096 + 1;
}

//从浮点通道中精确保存的二十四位整数还原观察空间单位法线。
float3 UnpackTurretNormal(float value)
{
    //符号用于区分转轮表面，绝对值仍保留完整的二十四位法线编码。
    float packed = abs(value) - 1;
    float high = floor(packed / 4096);
    float2 oct = float2(packed - high * 4096, high) / 4095 * 2 - 1;
    float3 normal = float3(oct, 1 - abs(oct.x) - abs(oct.y));
    float fold = saturate(-normal.z);
    normal.xy += float2(normal.x >= 0 ? -fold : fold, normal.y >= 0 ? -fold : fold);
    return normalize(normal);
}

#endif
