#version 450
layout(binding = 5, set = 2)
uniform sampler2D _MatTex; // @default = white
layout(binding = 1, set = 2)
uniform sampler2D _DepthTex; // @default = gray
layout(binding = 3, set = 2)
uniform sampler2D _MainTex; // @default = white


#line 56 0
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

#line 108
vec3 UnityObjectToViewPos_0(vec3 p_0)
{

#line 108
    return ((((((vec4(p_0, 1.0)) * (transpose(RU_Object_0.model_0))))) * (transpose(RU_Material_0._RimUnity_View)))).xyz;
}


#line 108
vec3 UnityObjectToViewPos_1(vec4 p_1)
{

#line 108
    return UnityObjectToViewPos_0(p_1.xyz);
}


#line 108
vec4 UnityViewToClipPos_0(vec3 p_2)
{

#line 108
    return (((vec4(p_2, 1.0)) * (transpose(RU_Material_0._RimUnity_Projection))));
}


#line 108
vec3 GetViewDir_0(vec3 viewPos_0, out vec4 clipPos_0)
{

#line 108
    vec4 _S1 = UnityViewToClipPos_0(viewPos_0);

#line 108
    clipPos_0 = _S1;

#line 108
    vec3 near_0 = viewPos_0;

#line 108
    float _S2 = float((int(sign((viewPos_0.z)))));

#line 108
    near_0[2] = _S2 * RU_Material_0._ProjectionParams.y;

#line 108
    float _S3 = _S1.w;

#line 108
    near_0.xy = near_0.xy * (UnityViewToClipPos_0(vec3(0.0, 0.0, near_0.z)).w / _S3);

#line 108
    vec3 far_0 = viewPos_0;

#line 108
    far_0[2] = _S2 * RU_Material_0._ProjectionParams.z;

#line 108
    far_0.xy = far_0.xy * (UnityViewToClipPos_0(vec3(0.0, 0.0, far_0.z)).w / _S3);

#line 108
    return far_0 - near_0;
}


#line 28
vec3 UnityObjectToWorldNormal_0(vec3 normal_0)
{

#line 29
    mat3 _S4 = mat3(transpose(RU_Object_0.model_0)[0].xyz, transpose(RU_Object_0.model_0)[1].xyz, transpose(RU_Object_0.model_0)[2].xyz);
    mat3 cofactors_0 = mat3(cross(_S4[1], _S4[2]), cross(_S4[2], _S4[0]), cross(_S4[0], _S4[1]));
    return normalize((((normal_0) * (cofactors_0))) * float((int(sign((dot(_S4[0], cofactors_0[0])))))));
}


#line 31
layout(location = 1)
out vec2 entryPointParam_vert_uv_0;


#line 31
layout(location = 5)
out vec2 entryPointParam_vert_uvDepth_0;


#line 31
layout(location = 6)
out vec3 entryPointParam_vert_viewPos_0;


#line 31
layout(location = 7)
out vec3 entryPointParam_vert_viewDir_0;


#line 31
layout(location = 8)
out vec3 entryPointParam_vert_normal_0;


#line 31
layout(location = 0) in vec4 v_vertex_0; // @vertex Position required


#line 31
layout(location = 1) in vec2 v_uv_0; // @vertex TexCoord0 optional


#line 31
layout(location = 3) in vec3 v_normal_0; // @vertex Normal optional


#line 108
struct v2f_0
{
    vec2 uv_0;
    vec2 uvDepth_0;
    vec3 viewPos_1;
    vec3 viewDir_0;
    vec3 normal_1;
    vec4 vertex_0;
};


#line 108
void main()
{

#line 108
    v2f_0 o_0;

#line 108
    o_0.uv_0 = v_uv_0.xy * RU_Material_0._MainTex_ST.zwxy.xy + RU_Material_0._MainTex_ST.zwxy.zw;

#line 108
    o_0.uvDepth_0 = v_uv_0.xy * RU_Material_0._DepthTex_ST.zwxy.xy + RU_Material_0._DepthTex_ST.zwxy.zw;

#line 108
    vec3 _S5 = UnityObjectToViewPos_1(v_vertex_0);

#line 108
    o_0.viewPos_1 = _S5;

#line 108
    vec3 _S6 = GetViewDir_0(_S5, o_0.vertex_0);

#line 108
    o_0.viewDir_0 = _S6;

#line 108
    vec3 _S7 = (((vec4(UnityObjectToWorldNormal_0(v_normal_0), 0.0)) * (transpose(RU_Material_0._RimUnity_View)))).xyz;

#line 108
    o_0.normal_1 = _S7;

#line 108
    float l_0 = length(_S7);

#line 108
    if(l_0 < 0.00100000004749745)
    {

#line 108
        o_0.normal_1 = vec3(0.0, 0.0, 1.0);

#line 108
    }
    else
    {

#line 108
        o_0.normal_1 = o_0.normal_1 / l_0;

#line 108
    }

#line 108
    v2f_0 _S8 = o_0;

#line 108
    entryPointParam_vert_uv_0 = o_0.uv_0;

#line 108
    entryPointParam_vert_uvDepth_0 = _S8.uvDepth_0;

#line 108
    entryPointParam_vert_viewPos_0 = _S8.viewPos_1;

#line 108
    entryPointParam_vert_viewDir_0 = _S8.viewDir_0;

#line 108
    entryPointParam_vert_normal_0 = _S8.normal_1;

#line 108
    gl_Position = _S8.vertex_0;

#line 108
    return;
}


// @rimunity-host-matrices 1
