#version 450


#line 56 0
struct RU_MaterialData_0
{
    vec4 _DepthTex_ST; // @default = vec4(0, 0, 1, 1)
    uint _DiskCount; // @default = 4
    float _DiskEnd; // @default = 0.5
    float _DiskStart; // @default = 0.2
    float _ExpendCurve; // @default = 0.5
    vec4 _InColor; // @default = vec4(1, 1, 1, 1) @color
    vec4 _OutColor; // @default = vec4(1, 1, 1, 1) @color
    uint _Seed; // @default = 64
    vec4 _Time;
};


#line 67
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    vec4 _DepthTex_ST; // @default = vec4(0, 0, 1, 1)
    uint _DiskCount; // @default = 4
    float _DiskEnd; // @default = 0.5
    float _DiskStart; // @default = 0.2
    float _ExpendCurve; // @default = 0.5
    vec4 _InColor; // @default = vec4(1, 1, 1, 1) @color
    vec4 _OutColor; // @default = vec4(1, 1, 1, 1) @color
    uint _Seed; // @default = 64
    vec4 _Time;
}RU_Material_0;

#line 89
float RU_Mutable_ExpendCurve_0;

ivec2 Vec2FromSeed_0(uint seed_0)
{

#line 91
    return ivec2(int(sqrt(float(seed_0))), int(sqrt(float(seed_0 << 1))));
}


#line 91
float Hash1In2D_0(ivec2 p_0, uint seed_1)
{

#line 91
    ivec2 vec_0 = Vec2FromSeed_0(seed_1);

#line 91
    int _S1 = vec_0.x;

#line 91
    int _S2 = vec_0.y;

#line 91
    int l_0 = _S1 * _S1 + _S2 * _S2;

#line 91
    ivec2 _S3;

#line 91
    if(l_0 < 1)
    {

#line 91
        ivec2 _S4 = vec_0 / l_0;

#line 91
        _S3 = _S4;

#line 91
    }
    else
    {

#line 91
        _S3 = vec_0;

#line 91
    }

#line 91
    float _S5 = sin(dot(vec2(p_0), vec2(_S3)));

#line 91
    int _S6 = 1 / l_0;

#line 91
    return 2.0 * fract(_S5 * float(max(l_0, _S6))) - 1.0;
}


#line 91
vec2 Hash2In2D_0(ivec2 p_1, uint seed_2)
{

#line 91
    float _S7 = Hash1In2D_0(p_1, uint(sqrt(float(seed_2))));

#line 91
    float _S8 = Hash1In2D_0(p_1, uint(sqrt(float(seed_2 << 1))));

#line 91
    return vec2(_S7, _S8);
}


#line 91
float PerlinNoise_0(vec2 p_2, uint seed_3)
{

#line 91
    ivec2 _S9 = ivec2(floor(p_2));

#line 91
    vec2 f_0 = fract(p_2);

#line 91
    vec2 w_0 = f_0 * f_0 * f_0 * (6.0 * f_0 * f_0 - 15.0 * f_0 + 10.0);

#line 91
    vec2 a_0 = Hash2In2D_0(_S9, seed_3);

#line 91
    vec2 b_0 = Hash2In2D_0(_S9 + ivec2(1, 0), seed_3);

#line 91
    vec2 c_0 = Hash2In2D_0(_S9 + ivec2(0, 1), seed_3);

#line 91
    vec2 d_0 = Hash2In2D_0(_S9 + ivec2(1, 1), seed_3);

#line 91
    float _S10 = w_0.x;

#line 91
    return mix(mix(dot(a_0, f_0), dot(b_0, f_0 - vec2(1.0, 0.0)), _S10), mix(dot(c_0, f_0 - vec2(0.0, 1.0)), dot(d_0, f_0 - vec2(1.0, 1.0)), _S10), w_0.y);
}


#line 91
layout(location = 0)
out vec4 entryPointParam_frag_0;


#line 91
layout(location = 1) in vec2 i_uv_0; // @vertex TexCoord0 optional


#line 93
void main()
{

#line 94
    RU_Mutable_ExpendCurve_0 = RU_Material_0._ExpendCurve;
    RU_Mutable_ExpendCurve_0 = max(RU_Material_0._ExpendCurve, 0.0);

#line 95
    float noise_0 = PerlinNoise_0(vec2((i_uv_0.x - RU_Material_0._Time.w) * 64.0, i_uv_0.y * 16.0), RU_Material_0._Seed);

#line 95
    float scale_0 = (1.0 - i_uv_0.x * i_uv_0.x) * max(mix(1.0, noise_0 / (1.0 - i_uv_0.x), i_uv_0.x), 0.0);

#line 95
    float partX_0 = fract(i_uv_0.x * float(RU_Material_0._DiskCount));

#line 95
    float bround_0 = scale_0 * (sin(partX_0 * 3.14159274101257324) * RU_Mutable_ExpendCurve_0 + 1.0) / (RU_Mutable_ExpendCurve_0 + 1.0);

#line 95
    float diskEnd_0 = scale_0 * ((RU_Material_0._DiskEnd + partX_0 - 1.0) / RU_Material_0._DiskEnd) / (RU_Mutable_ExpendCurve_0 + 1.0);

#line 95
    float w_1 = (RU_Material_0._DiskStart * RU_Material_0._DiskEnd - partX_0) / RU_Material_0._DiskEnd;

#line 95
    float diskStart_0;

#line 95
    if(w_1 > 0.0)
    {

#line 95
        diskStart_0 = scale_0 * (1.0 - partX_0 / RU_Material_0._DiskEnd) / (RU_Mutable_ExpendCurve_0 + 1.0);

#line 95
    }
    else
    {

#line 95
        diskStart_0 = 0.0;

#line 95
    }

#line 95
    float r_0 = abs(i_uv_0.y - 0.5) * 2.0;

#line 95
    entryPointParam_frag_0 = (RU_Material_0._InColor * max(max(2.0 * (diskStart_0 - r_0), 0.0) / diskStart_0, 0.0) * clamp(w_1 / RU_Material_0._DiskStart, 0.0, 1.0) + RU_Material_0._InColor * max(max(2.0 * (diskEnd_0 - r_0), 0.0) / diskEnd_0, 0.0) + clamp(2.0 * (bround_0 - r_0) * r_0 / bround_0, 0.0, 1.0) * RU_Material_0._OutColor) * sin(max(1.0 - i_uv_0.x, 0.0) * 1.57079637050628662);

#line 95
    return;
}


// @rimunity-host-matrices 1
