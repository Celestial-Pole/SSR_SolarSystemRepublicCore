#version 450
layout(binding = 3, set = 2)
uniform sampler2D background;
layout(binding = 1, set = 2)
uniform sampler2D _MainTex; // @default = black
layout(binding = 5, set = 2)
uniform sampler2D warpMap; // @default = white


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

#line 23
vec4 UnityObjectToClipPos_0(vec4 p_0)
{

#line 23
    return ((((((p_0) * (transpose(RU_Object_0.model_0))))) * (transpose(RU_Camera_0.ViewProj_0))));
}


#line 108
vec3 UnityObjectToViewPos_0(vec3 p_1)
{

#line 108
    return ((((((vec4(p_1, 1.0)) * (transpose(RU_Object_0.model_0))))) * (transpose(RU_Material_0._RimUnity_View)))).xyz;
}


#line 108
vec3 UnityObjectToViewPos_1(vec4 p_2)
{

#line 108
    return UnityObjectToViewPos_0(p_2.xyz);
}


#line 108
layout(location = 1)
out vec3 entryPointParam_vert_viewSpacePos_0;


#line 108
layout(location = 5)
out vec3 entryPointParam_vert_viewSpaceZeroPoint_0;


#line 108
layout(location = 6)
out vec4 entryPointParam_vert_uvBackground_0;


#line 108
layout(location = 0) in vec4 v_vertex_0; // @vertex Position required


#line 108
struct v2f_0
{
    vec3 viewSpacePos_0;
    vec3 viewSpaceZeroPoint_0;
    vec4 uvBackground_0;
    vec4 vertex_0;
};


#line 108
void main()
{

#line 108
    v2f_0 o_0;

#line 108
    vec4 _S1 = UnityObjectToClipPos_0(v_vertex_0);

#line 108
    o_0.vertex_0 = _S1;

#line 108
    o_0.uvBackground_0 = _S1;

#line 108
    o_0.uvBackground_0[1] = o_0.uvBackground_0[1] * RU_Material_0._ProjectionParams.x;

#line 108
    o_0.viewSpacePos_0 = UnityObjectToViewPos_1(v_vertex_0);

#line 108
    o_0.viewSpacePos_0[1] = o_0.viewSpacePos_0[1] * RU_Material_0._ProjectionParams.x;

#line 108
    o_0.viewSpaceZeroPoint_0 = UnityObjectToViewPos_0(vec3(0.0, 0.0, 0.0));

#line 108
    o_0.viewSpaceZeroPoint_0[1] = o_0.viewSpaceZeroPoint_0[1] * RU_Material_0._ProjectionParams.x;

#line 108
    v2f_0 _S2 = o_0;

#line 108
    entryPointParam_vert_viewSpacePos_0 = o_0.viewSpacePos_0;

#line 108
    entryPointParam_vert_viewSpaceZeroPoint_0 = _S2.viewSpaceZeroPoint_0;

#line 108
    entryPointParam_vert_uvBackground_0 = _S2.uvBackground_0;

#line 108
    gl_Position = _S2.vertex_0;

#line 108
    return;
}


// @rimunity-host-matrices 1
