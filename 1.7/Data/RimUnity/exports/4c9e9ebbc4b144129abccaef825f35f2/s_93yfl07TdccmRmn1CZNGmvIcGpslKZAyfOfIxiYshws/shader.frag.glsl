#version 450
layout(location = 14) flat in vec4 RU_FragmentObjectData3;
layout(location = 13) flat in vec4 RU_FragmentObjectData2;
layout(location = 12) flat in vec4 RU_FragmentObjectData1;
layout(location = 11) flat in vec4 RU_FragmentObjectData0;
layout(location = 10) flat in vec4 RU_FragmentCameraData3;
layout(location = 9) flat in vec4 RU_FragmentCameraData2;
layout(location = 8) flat in vec4 RU_FragmentCameraData1;
layout(location = 7) flat in vec4 RU_FragmentCameraData0;
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    vec4 _DepthTex_ST; // @default = vec4(0, 0, 1, 1)
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
}RU_Material_0;


#line 75 0
layout(binding = 3, set = 2)
uniform sampler2D _MainTex; // @default = black


#line 77



#line 64
layout(binding = 1, set = 2)
uniform sampler2D _DepthTex; // @default = gray


#line 66



#line 15
struct RU_CameraData_0
{
    mat4 ViewProj_0;
};


#line 16


#line 17
struct RU_ObjectData_0
{
    mat4 model_0;
};


#line 18


#line 79
vec4 RU_tex2D_MainTex_0(vec2 uv_0)
{

#line 79
    return (texture(_MainTex, (vec2(uv_0.x, 1.0 - uv_0.y))));
}


#line 68
vec4 RU_tex2D_DepthTex_0(vec2 uv_1)
{

#line 68
    return (texture(_DepthTex, (vec2(uv_1.x, 1.0 - uv_1.y))));
}


#line 23
vec4 UnityObjectToClipPos_0(vec4 p_0)
{

#line 23
    return ((((((p_0) * (transpose(mat4(RU_FragmentObjectData0,RU_FragmentObjectData1,RU_FragmentObjectData2,RU_FragmentObjectData3)))))) * (transpose(mat4(RU_FragmentCameraData0,RU_FragmentCameraData1,RU_FragmentCameraData2,RU_FragmentCameraData3)))));
}


#line 23
layout(location = 0)
out vec4 entryPointParam_frag_0;


#line 23
layout(location = 1) in vec2 i_uv_0; // @vertex TexCoord0 optional


#line 23
layout(location = 5) in vec2 i_uvDepth_0; // @vertex TexCoord1 optional


#line 23
layout(location = 6) in vec4 i_model_0; // @vertex TexCoord2 optional


#line 87
struct v2f_0
{
    vec2 uv_2;
    vec2 uvDepth_0;
    vec4 model_1;
    vec4 vertex_0;
};


#line 87
void main()
{

#line 87
    v2f_0 _S1;

#line 87
    _S1.uv_2 = i_uv_0;

#line 87
    _S1.uvDepth_0 = i_uvDepth_0;

#line 87
    _S1.model_1 = i_model_0;

#line 87
    _S1.vertex_0 = gl_FragCoord;

#line 87
    vec4 col_0 = RU_tex2D_MainTex_0(_S1.uv_2);

#line 87
    if((col_0.w) <= 0.0)
    {

#line 87
        discard;

#line 87
    }

#line 87
    _S1.model_1[1] = _S1.model_1[1] - (RU_tex2D_DepthTex_0(_S1.uvDepth_0).x - 0.5);

#line 87
    vec4 _S2 = UnityObjectToClipPos_0(_S1.model_1);

#line 87
    _S1.model_1 = _S2;

#line 87
    float _S3 = _S2.z / _S2.w;

#line 87
    entryPointParam_frag_0 = col_0;

#line 87
    gl_FragDepth = _S3;

#line 87
    return;
}


// @rimunity-host-matrices 1
