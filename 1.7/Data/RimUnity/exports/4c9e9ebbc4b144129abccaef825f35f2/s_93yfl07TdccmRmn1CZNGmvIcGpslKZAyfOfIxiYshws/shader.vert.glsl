#version 450
layout(binding = 1, set = 2)
uniform sampler2D _DepthTex; // @default = gray
layout(binding = 3, set = 2)
uniform sampler2D _MainTex; // @default = black
layout(location = 14) flat out vec4 RU_FragmentObjectData3;
layout(location = 13) flat out vec4 RU_FragmentObjectData2;
layout(location = 12) flat out vec4 RU_FragmentObjectData1;
layout(location = 11) flat out vec4 RU_FragmentObjectData0;
layout(location = 10) flat out vec4 RU_FragmentCameraData3;
layout(location = 9) flat out vec4 RU_FragmentCameraData2;
layout(location = 8) flat out vec4 RU_FragmentCameraData1;
layout(location = 7) flat out vec4 RU_FragmentCameraData0;


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
    vec4 _DepthTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
};


#line 60
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    vec4 _DepthTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
}RU_Material_0;

#line 23
vec4 UnityObjectToClipPos_0(vec4 p_0)
{

#line 23
    return ((((((p_0) * (transpose(RU_Object_0.model_0))))) * (transpose(RU_Camera_0.ViewProj_0))));
}


#line 87
layout(location = 1)
out vec2 entryPointParam_vert_uv_0;


#line 87
layout(location = 5)
out vec2 entryPointParam_vert_uvDepth_0;


#line 87
layout(location = 6)
out vec4 entryPointParam_vert_model_0;


#line 87
layout(location = 0) in vec4 v_vertex_0; // @vertex Position required


#line 87
layout(location = 1) in vec2 v_uv_0; // @vertex TexCoord0 optional


#line 87
struct v2f_0
{
    vec2 uv_0;
    vec2 uvDepth_0;
    vec4 model_1;
    vec4 vertex_0;
};


#line 87
void main()
{
RU_FragmentCameraData0 = RU_Camera_0.ViewProj_0[0];
RU_FragmentCameraData1 = RU_Camera_0.ViewProj_0[1];
RU_FragmentCameraData2 = RU_Camera_0.ViewProj_0[2];
RU_FragmentCameraData3 = RU_Camera_0.ViewProj_0[3];
RU_FragmentObjectData0 = RU_Object_0.model_0[0];
RU_FragmentObjectData1 = RU_Object_0.model_0[1];
RU_FragmentObjectData2 = RU_Object_0.model_0[2];
RU_FragmentObjectData3 = RU_Object_0.model_0[3];


#line 87
    v2f_0 o_0;

#line 87
    o_0.vertex_0 = UnityObjectToClipPos_0(v_vertex_0);

#line 87
    o_0.uv_0 = v_uv_0.xy * RU_Material_0._MainTex_ST.zwxy.xy + RU_Material_0._MainTex_ST.zwxy.zw;

#line 87
    o_0.uvDepth_0 = v_uv_0.xy * RU_Material_0._DepthTex_ST.zwxy.xy + RU_Material_0._DepthTex_ST.zwxy.zw;

#line 87
    o_0.model_1 = v_vertex_0;

#line 87
    v2f_0 _S1 = o_0;

#line 87
    entryPointParam_vert_uv_0 = o_0.uv_0;

#line 87
    entryPointParam_vert_uvDepth_0 = _S1.uvDepth_0;

#line 87
    entryPointParam_vert_model_0 = _S1.model_1;

#line 87
    gl_Position = _S1.vertex_0;

#line 87
    return;
}


// @rimunity-host-matrices 1
