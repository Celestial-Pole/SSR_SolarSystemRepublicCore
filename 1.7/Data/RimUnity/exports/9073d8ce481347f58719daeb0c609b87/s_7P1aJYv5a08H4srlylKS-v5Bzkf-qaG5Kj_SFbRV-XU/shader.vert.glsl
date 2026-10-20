#version 450
layout(binding = 1, set = 2)
uniform sampler2D _MainTex; // @default = white


#line 15 0
struct RU_CameraData_0
{
    mat4 ViewProj_0;
};


#line 16
layout(binding = 0, std140) uniform block_RU_CameraData_0
{
    mat4 ViewProj_0;
}RU_Camera_0;

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

#line 56
struct RU_MaterialData_0
{
    vec4 _Color; // @default = vec4(1, 1, 1, 1) @color
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
};


#line 60
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    vec4 _Color; // @default = vec4(1, 1, 1, 1) @color
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
}RU_Material_0;

#line 23
vec4 UnityObjectToClipPos_0(vec4 p_0)
{

#line 23
    return ((((((p_0) * (transpose(RU_Object_0.model_0))))) * (transpose(RU_Camera_0.ViewProj_0))));
}


#line 76
layout(location = 1)
out vec2 entryPointParam_vert_uv_0;


#line 76
layout(location = 0) in vec4 v_vertex_0; // @vertex Position required


#line 76
layout(location = 1) in vec2 v_uv_0; // @vertex TexCoord0 optional


#line 76
struct F_0
{
    vec4 pos_0;
    vec2 uv_0;
};


#line 76
void main()
{

#line 76
    F_0 o_0;

#line 76
    o_0.pos_0 = UnityObjectToClipPos_0(v_vertex_0);

#line 76
    o_0.uv_0 = v_uv_0.xy * RU_Material_0._MainTex_ST.zwxy.xy + RU_Material_0._MainTex_ST.zwxy.zw;

#line 76
    F_0 _S1 = o_0;

#line 76
    gl_Position = o_0.pos_0;

#line 76
    entryPointParam_vert_uv_0 = _S1.uv_0;

#line 76
    return;
}


// @rimunity-host-matrices 1
