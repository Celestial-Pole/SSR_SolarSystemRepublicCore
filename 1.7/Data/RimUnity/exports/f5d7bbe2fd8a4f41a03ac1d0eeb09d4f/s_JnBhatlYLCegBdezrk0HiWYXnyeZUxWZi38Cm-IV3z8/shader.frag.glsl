#version 450


#line 56 0
struct RU_MaterialData_0
{
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _ProjectionParams;
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
    float sizeIn; // @default = 0.5
    float sizeOut; // @default = 1
    vec4 warpMap_TexelSize;
};


#line 65
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{    vec4 _ProjectionParams;
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
    float sizeIn; // @default = 0.5
    float sizeOut; // @default = 1
    vec4 warpMap_TexelSize;
}RU_Material_0;

#line 96
layout(binding = 5, set = 2)
uniform sampler2D warpMap; // @default = white


#line 98



#line 74
layout(binding = 1, set = 2)
uniform sampler2D _MainTex; // @default = black


#line 76



#line 85
layout(binding = 3, set = 2)
uniform sampler2D background;


#line 87



#line 14946 1
float saturate_0(float x_0)
{

#line 14954
    return clamp(x_0, 0.0, 1.0);
}


#line 103 0
vec4 RU_tex2DlodwarpMap_0(vec4 uv_0)
{

#line 103
    return (textureLod(warpMap, (vec2(uv_0.x, 1.0 - uv_0.y)), (uv_0.w)));
}


#line 81
vec4 RU_tex2Dlod_MainTex_0(vec4 uv_1)
{

#line 81
    return (textureLod(_MainTex, (vec2(uv_1.x, 1.0 - uv_1.y)), (uv_1.w)));
}


#line 92
vec4 RU_tex2Dlodbackground_0(vec4 uv_2)
{

#line 92
    return (textureLod(background, (vec2(uv_2.x, 1.0 - uv_2.y)), (uv_2.w)));
}


#line 92
layout(location = 0)
out vec4 entryPointParam_frag_0;


#line 2600 2
layout(location = 1) in vec3 i_viewSpacePos_0; // @vertex TexCoord0 optional


#line 2600
layout(location = 5) in vec3 i_viewSpaceZeroPoint_0; // @vertex TexCoord1 optional


#line 2600
layout(location = 6) in vec4 i_uvBackground_0; // @vertex TexCoord2 optional


#line 108 0
void main()
{

#line 108
    float warpMaper_0 = length(i_viewSpacePos_0.xy - i_viewSpaceZeroPoint_0.xy) - RU_Material_0.sizeIn;

#line 108
    vec4 dir_0 = (((vec4(normalize(i_viewSpacePos_0.xy - i_viewSpaceZeroPoint_0.xy), i_viewSpacePos_0.z, 1.0)) * (transpose(RU_Material_0._RimUnity_Projection))));

#line 108
    vec2 screenUV_0 = 0.5 * (i_uvBackground_0.xy / i_uvBackground_0.w) + 0.5;

#line 108
    float mapFactor_0 = (RU_Material_0.warpMap_TexelSize.z - 1.0) * RU_Material_0.warpMap_TexelSize.x;

#line 108
    float mapOffseter_0 = 0.5 * RU_Material_0.warpMap_TexelSize.x;

#line 108
    vec2 _S1 = dir_0.xy;

#line 108
    float _S2 = dir_0.w;

#line 108
    entryPointParam_frag_0 = mix(RU_tex2Dlod_MainTex_0(vec4(screenUV_0 + (1.0 / RU_tex2DlodwarpMap_0(vec4(saturate_0(- warpMaper_0 / RU_Material_0.sizeIn) * mapFactor_0 + mapOffseter_0, 0.25, 0.0, 0.0)).x - 1.0) * _S1 / _S2, 0.0, 0.0)), RU_tex2Dlodbackground_0(vec4(screenUV_0 - (1.0 / RU_tex2DlodwarpMap_0(vec4(saturate_0(warpMaper_0 / (RU_Material_0.sizeOut - RU_Material_0.sizeIn)) * mapFactor_0 + mapOffseter_0, 0.75, 0.0, 0.0)).x - 1.0) * _S1 / _S2, 0.0, 0.0)), vec4(step(0.0, warpMaper_0)));

#line 108
    return;
}


// @rimunity-host-matrices 1
