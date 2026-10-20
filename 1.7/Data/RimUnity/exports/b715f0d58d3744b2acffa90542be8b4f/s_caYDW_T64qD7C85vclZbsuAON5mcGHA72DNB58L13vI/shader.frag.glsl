#version 450


#line 56 0
struct RU_MaterialData_0
{
    vec4 _Color; // @default = vec4(1, 1, 1, 1) @color
    vec4 _MatTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _ProjectionParams;
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
};


#line 63
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    vec4 _Color; // @default = vec4(1, 1, 1, 1) @color
    vec4 _MatTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _ProjectionParams;
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
}RU_Material_0;

#line 70
layout(binding = 1, set = 2)
uniform sampler2D _MatTex; // @default = white


#line 72



#line 74
vec4 RU_tex2D_MatTex_0(vec2 uv_0)
{

#line 74
    return (texture(_MatTex, (vec2(uv_0.x, 1.0 - uv_0.y))));
}


#line 82
vec4 ShadingByMatTex_0(vec3 normal_0, vec3 viewDir_0)
{

#line 82
    vec3 _S1 = normalize(reflect(viewDir_0, normal_0));

#line 82
    vec3 reflectDir_0 = _S1;

#line 82
    vec2 _S2 = _S1.xy;

#line 82
    float d_0 = length(_S2);

#line 82
    float _S3 = 1.0 + d_0;

#line 82
    reflectDir_0.xy = _S2 * ((_S3 - _S1.z) / (2.0 * d_0 * sqrt(_S3)));

#line 82
    return RU_tex2D_MatTex_0((reflectDir_0.xy * 0.5 + 0.5).xy * RU_Material_0._MatTex_ST.zwxy.xy + RU_Material_0._MatTex_ST.zwxy.zw);
}


#line 82
layout(location = 0)
out vec4 entryPointParam_frag_0;


#line 82
layout(location = 1) in vec3 i_normal_0; // @vertex TexCoord0 optional


#line 82
layout(location = 5) in vec3 i_viewDir_0; // @vertex TexCoord1 optional


#line 82
void main()
{

#line 82
    entryPointParam_frag_0 = vec4(RU_Material_0._Color.xyz * ShadingByMatTex_0(i_normal_0, i_viewDir_0).xyz, RU_Material_0._Color.w);

#line 82
    return;
}


// @rimunity-host-matrices 1
