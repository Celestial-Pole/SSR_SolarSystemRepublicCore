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

#line 15
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

#line 89
float RU_Mutable_ExpendCurve_0;


#line 23
vec4 UnityObjectToClipPos_0(vec4 p_0)
{

#line 23
    return ((((((p_0) * (transpose(RU_Object_0.model_0))))) * (transpose(RU_Camera_0.ViewProj_0))));
}


#line 91
layout(location = 1)
out vec2 entryPointParam_vert_uv_0;


#line 91
layout(location = 5)
out vec2 entryPointParam_vert_uvDepth_0;


#line 91
layout(location = 6)
out vec4 entryPointParam_vert_model_0;


#line 91
layout(location = 0) in vec4 v_vertex_0; // @vertex Position required


#line 91
layout(location = 1) in vec2 v_uv_0; // @vertex TexCoord0 optional


#line 91
struct v2f_0
{
    vec2 uv_0;
    vec2 uvDepth_0;
    vec4 model_1;
    vec4 vertex_0;
};


#line 91
void main()
{

#line 92
    RU_Mutable_ExpendCurve_0 = RU_Material_0._ExpendCurve;
    v2f_0 o_0;

#line 93
    o_0.vertex_0 = UnityObjectToClipPos_0(v_vertex_0);

#line 93
    o_0.uv_0 = v_uv_0;

#line 93
    o_0.uvDepth_0 = v_uv_0.xy * RU_Material_0._DepthTex_ST.zwxy.xy + RU_Material_0._DepthTex_ST.zwxy.zw;

#line 93
    o_0.model_1 = v_vertex_0;

#line 93
    v2f_0 _S1 = o_0;

#line 93
    entryPointParam_vert_uv_0 = o_0.uv_0;

#line 93
    entryPointParam_vert_uvDepth_0 = _S1.uvDepth_0;

#line 93
    entryPointParam_vert_model_0 = _S1.model_1;

#line 93
    gl_Position = _S1.vertex_0;

#line 93
    return;
}


// @rimunity-host-matrices 1
