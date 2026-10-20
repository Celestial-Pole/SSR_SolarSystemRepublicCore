#version 450
layout(binding = 1, set = 2)
uniform sampler2D _MainTex; // @default = gray


#line 56 0
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

#line 17
struct RU_ObjectData_0
{
    mat4 model_0;
};


#line 18
layout(push_constant, std430) uniform block_RU_ObjectData_0
{
    mat4 model_0;
}RU_Object_0;

#line 78
vec3 UnityObjectToViewPos_0(vec3 p_0)
{

#line 78
    return ((((((vec4(p_0, 1.0)) * (transpose(RU_Object_0.model_0))))) * (transpose(RU_Material_0._RimUnity_View)))).xyz;
}


#line 78
vec3 UnityObjectToViewPos_1(vec4 p_1)
{

#line 78
    return UnityObjectToViewPos_0(p_1.xyz);
}


#line 78
vec4 UnityViewToClipPos_0(vec3 p_2)
{

#line 78
    return (((vec4(p_2, 1.0)) * (transpose(RU_Material_0._RimUnity_Projection))));
}


#line 78
layout(location = 1)
out vec2 entryPointParam_vert_uv_0;


#line 78
layout(location = 5)
out vec3 entryPointParam_vert_view_0;


#line 78
layout(location = 0) in vec4 v_vertex_0; // @vertex Position required


#line 78
layout(location = 1) in vec2 v_uv_0; // @vertex TexCoord0 optional


#line 78
struct v2f_0
{
    vec2 uv_0;
    vec3 view_0;
    vec4 vertex_0;
};


#line 78
void main()
{

#line 78
    v2f_0 o_0;

#line 78
    vec3 _S1 = UnityObjectToViewPos_1(v_vertex_0);

#line 78
    o_0.view_0 = _S1;

#line 78
    o_0.vertex_0 = UnityViewToClipPos_0(_S1);

#line 78
    o_0.uv_0 = v_uv_0.xy * RU_Material_0._MainTex_ST.zwxy.xy + RU_Material_0._MainTex_ST.zwxy.zw;

#line 78
    v2f_0 _S2 = o_0;

#line 78
    entryPointParam_vert_uv_0 = o_0.uv_0;

#line 78
    entryPointParam_vert_view_0 = _S2.view_0;

#line 78
    gl_Position = _S2.vertex_0;

#line 78
    return;
}


// @rimunity-host-matrices 1
