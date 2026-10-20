#version 450


#line 56 0
struct RU_MaterialData_0
{
    vec4 _DepthTex_ST; // @default = vec4(0, 0, 1, 1)
    float _OutlineWidth; // @default = 0.015625
    vec4 _ProjectionParams;
    mat4 _RimUnity_InvProjection;
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
};


#line 64
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{    float _OutlineWidth; // @default = 0.015625
    vec4 _ProjectionParams;
    mat4 _RimUnity_InvProjection;
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
}RU_Material_0;

#line 73
vec4 UnityViewToClipPos_0(vec3 p_0)
{

#line 73
    return (((vec4(p_0, 1.0)) * (transpose(RU_Material_0._RimUnity_Projection))));
}


#line 73
layout(location = 0)
out vec4 entryPointParam_frag_0;


#line 73
layout(location = 1) in vec3 i_orginalVert_0; // @vertex TexCoord0 optional


#line 73
layout(location = 5) in vec3 i_transposVert_0; // @vertex TexCoord1 optional


#line 73
void main()
{

#line 73
    if((RU_Material_0._OutlineWidth) <= 0.0)
    {

#line 73
        discard;

#line 73
    }

#line 73
    vec3 dir_0 = i_transposVert_0.xyz - i_orginalVert_0.xyz;

#line 73
    float disSq_0 = dot(dir_0, dir_0);

#line 73
    if((RU_Material_0._OutlineWidth * RU_Material_0._OutlineWidth) <= disSq_0)
    {

#line 73
        discard;

#line 73
    }

#line 73
    vec2 deeperVert_0 = UnityViewToClipPos_0(vec3(0.0, 0.0, i_transposVert_0.z + 10.0 * sqrt(disSq_0) * float((int(sign((i_transposVert_0.z))))))).zw;

#line 73
    float _S1 = deeperVert_0.x / deeperVert_0.y;

#line 73
    entryPointParam_frag_0 = vec4(0.0, 0.0, 0.0, 1.0);

#line 73
    gl_FragDepth = _S1;

#line 73
    return;
}


// @rimunity-host-matrices 1
