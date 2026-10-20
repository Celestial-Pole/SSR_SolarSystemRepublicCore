#version 450
layout(binding = 1, set = 2)
uniform sampler2D _MainTex; // @default = black


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
};


#line 59
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    vec4 _Color; // @default = vec4(1, 1, 1, 1) @color
}RU_Material_0;

#line 23
vec4 UnityObjectToClipPos_0(vec4 p_0)
{

#line 23
    return ((((((p_0) * (transpose(RU_Object_0.model_0))))) * (transpose(RU_Camera_0.ViewProj_0))));
}


#line 74
layout(location = 1)
out vec2 entryPointParam_vert_uv_0;


#line 74
layout(location = 2)
out vec4 entryPointParam_vert_color_0;


#line 74
layout(location = 0) in vec4 v_vertex_0; // @vertex Position required


#line 74
layout(location = 1) in vec2 v_uv_0; // @vertex TexCoord0 optional


#line 74
layout(location = 2) in vec4 v_color_0; // @vertex Color optional


#line 74
struct F_0
{
    vec4 pos_0;
    vec2 uv_0;
    vec4 color_0;
};


#line 74
void main()
{

#line 74
    F_0 o_0;

#line 74
    o_0.pos_0 = UnityObjectToClipPos_0(v_vertex_0);

#line 74
    o_0.uv_0 = v_uv_0;

#line 74
    o_0.color_0 = v_color_0 * RU_Material_0._Color;

#line 74
    F_0 _S1 = o_0;

#line 74
    gl_Position = o_0.pos_0;

#line 74
    entryPointParam_vert_uv_0 = _S1.uv_0;

#line 74
    entryPointParam_vert_color_0 = _S1.color_0;

#line 74
    return;
}


// @rimunity-host-matrices 1
