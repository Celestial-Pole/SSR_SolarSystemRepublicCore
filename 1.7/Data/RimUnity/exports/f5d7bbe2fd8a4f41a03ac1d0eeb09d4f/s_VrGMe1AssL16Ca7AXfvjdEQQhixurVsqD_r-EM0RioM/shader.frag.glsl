#version 450


#line 85 0
layout(binding = 3, set = 2)
uniform sampler2D _MainTex; // @default = white


#line 87



#line 74
layout(binding = 1, set = 2)
uniform sampler2D _DepthTex; // @default = gray


#line 76



#line 56
struct RU_MaterialData_0
{
    float _DepthFactor; // @default = 1
    vec4 _DepthTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _MatTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _ProjectionParams;
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
};


#line 65
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    float _DepthFactor; // @default = 1
    vec4 _DepthTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _MatTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _ProjectionParams;
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
}RU_Material_0;

#line 96
layout(binding = 5, set = 2)
uniform sampler2D _MatTex; // @default = white


#line 98



#line 89
vec4 RU_tex2D_MainTex_0(vec2 uv_0)
{

#line 89
    return (texture(_MainTex, (vec2(uv_0.x, 1.0 - uv_0.y))));
}


#line 78
vec4 RU_tex2D_DepthTex_0(vec2 uv_1)
{

#line 78
    return (texture(_DepthTex, (vec2(uv_1.x, 1.0 - uv_1.y))));
}


#line 108
vec4 UnityViewToClipPos_0(vec3 p_0)
{

#line 108
    return (((vec4(p_0, 1.0)) * (transpose(RU_Material_0._RimUnity_Projection))));
}


#line 100
vec4 RU_tex2D_MatTex_0(vec2 uv_2)
{

#line 100
    return (texture(_MatTex, (vec2(uv_2.x, 1.0 - uv_2.y))));
}


#line 108
vec4 ShadingByMatTex_0(vec3 normal_0, vec3 viewDir_0)
{

#line 108
    vec3 _S1 = normalize(reflect(viewDir_0, normal_0));

#line 108
    vec3 reflectDir_0 = _S1;

#line 108
    vec2 _S2 = _S1.xy;

#line 108
    float d_0 = length(_S2);

#line 108
    float _S3 = 1.0 + d_0;

#line 108
    reflectDir_0.xy = _S2 * ((_S3 - _S1.z) / (2.0 * d_0 * sqrt(_S3)));

#line 108
    return RU_tex2D_MatTex_0((reflectDir_0.xy * 0.5 + 0.5).xy * RU_Material_0._MatTex_ST.zwxy.xy + RU_Material_0._MatTex_ST.zwxy.zw);
}


#line 108
layout(location = 0)
out vec4 entryPointParam_frag_0;


#line 108
layout(location = 1) in vec2 i_uv_0; // @vertex TexCoord0 optional


#line 108
layout(location = 5) in vec2 i_uvDepth_0; // @vertex TexCoord1 optional


#line 108
layout(location = 6) in vec3 i_viewPos_0; // @vertex TexCoord2 optional


#line 108
layout(location = 7) in vec3 i_viewDir_0; // @vertex TexCoord3 optional


#line 108
layout(location = 8) in vec3 i_normal_0; // @vertex TexCoord4 optional


#line 108
struct v2f_0
{
    vec2 uv_3;
    vec2 uvDepth_0;
    vec3 viewPos_0;
    vec3 viewDir_1;
    vec3 normal_1;
    vec4 vertex_0;
};


#line 108
void main()
{

#line 108
    v2f_0 _S4;

#line 108
    _S4.uv_3 = i_uv_0;

#line 108
    _S4.uvDepth_0 = i_uvDepth_0;

#line 108
    _S4.viewPos_0 = i_viewPos_0;

#line 108
    _S4.viewDir_1 = i_viewDir_0;

#line 108
    _S4.normal_1 = i_normal_0;

#line 108
    _S4.vertex_0 = gl_FragCoord;

#line 108
    vec4 col_0 = RU_tex2D_MainTex_0(_S4.uv_3);

#line 108
    float _S5 = col_0.w;

#line 108
    if(_S5 < 0.5)
    {

#line 108
        discard;

#line 108
    }

#line 108
    _S4.viewPos_0[2] = _S4.viewPos_0[2] - (RU_tex2D_DepthTex_0(_S4.uvDepth_0).x - 0.5) * RU_Material_0._DepthFactor;

#line 108
    vec4 _S6 = UnityViewToClipPos_0(_S4.viewPos_0);

#line 108
    _S4.vertex_0 = _S6;

#line 108
    float _S7 = _S6.z / _S6.w;

#line 108
    entryPointParam_frag_0 = vec4(col_0.xyz * ShadingByMatTex_0(_S4.normal_1, _S4.viewDir_1).xyz, _S5);

#line 108
    gl_FragDepth = _S7;

#line 108
    return;
}


// @rimunity-host-matrices 1
