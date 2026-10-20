#version 450


#line 66 0
layout(binding = 1, set = 2)
uniform sampler2D _MainTex; // @default = gray


#line 68



#line 56
struct RU_MaterialData_0
{
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
};


#line 61
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
}RU_Material_0;


vec4 RU_tex2D_MainTex_0(vec2 uv_0)
{

#line 70
    return (texture(_MainTex, (vec2(uv_0.x, 1.0 - uv_0.y))));
}


#line 78
vec4 UnityViewToClipPos_0(vec3 p_0)
{

#line 78
    return (((vec4(p_0, 1.0)) * (transpose(RU_Material_0._RimUnity_Projection))));
}


#line 78
layout(location = 0)
out vec4 entryPointParam_frag_0;


#line 78
layout(location = 1) in vec2 i_uv_0; // @vertex TexCoord0 optional


#line 78
layout(location = 5) in vec3 i_view_0; // @vertex TexCoord1 optional


#line 78
struct v2f_0
{
    vec2 uv_1;
    vec3 view_0;
    vec4 vertex_0;
};


#line 78
void main()
{

#line 78
    v2f_0 _S1;

#line 78
    _S1.uv_1 = i_uv_0;

#line 78
    _S1.view_0 = i_view_0;

#line 78
    _S1.vertex_0 = gl_FragCoord;

#line 78
    vec4 col_0 = RU_tex2D_MainTex_0(_S1.uv_1);

#line 78
    float _S2 = col_0.w;

#line 78
    if(_S2 <= 0.0)
    {

#line 78
        discard;

#line 78
    }

#line 78
    _S1.view_0[2] = _S1.view_0[2] - (col_0.x - 0.5) * _S2;

#line 78
    vec4 _S3 = UnityViewToClipPos_0(_S1.view_0);

#line 78
    _S1.vertex_0 = _S3;

#line 78
    float _S4 = _S3.z / _S3.w;

#line 78
    entryPointParam_frag_0 = vec4(_S4);

#line 78
    gl_FragDepth = _S4;

#line 78
    return;
}


// @rimunity-host-matrices 1
