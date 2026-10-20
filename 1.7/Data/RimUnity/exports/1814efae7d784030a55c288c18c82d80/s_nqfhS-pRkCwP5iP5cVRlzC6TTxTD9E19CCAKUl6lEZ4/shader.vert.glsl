#version 450
layout(set = 2, binding = 5) uniform sampler2D _UiMaskAtlas;
layout(binding = 1, set = 2)
uniform sampler2D _MainTex; // @default = white
layout(binding = 3, set = 2)
uniform sampler2D _SSR_ScreenTexture;
layout(std430, set = 2, binding = 7) readonly buffer _UiRectMasks { vec4 rows[]; } rectangles;
layout(std430, set = 2, binding = 6) readonly buffer _UiMaskRegions { vec4 rows[]; } regions;
layout(std430, set = 2, binding = 4) readonly buffer _UiMasks { vec4 rows[]; } masks;


#line 15 0
struct RU_FrameData_0
{
    vec4 sunDirection_0;
    mat4 worldToCamera_0;
    mat4 viewProj_0;
};


#line 16
layout(binding = 1, std140) uniform block_RU_FrameData_0
{
    vec4 sunDirection_0;
    mat4 worldToCamera_0;
    mat4 viewProj_0;
}RU_Frame_0;

#line 43
struct RU_MaterialData_0
{
    float _BlurPercent; // @default = 50
    vec4 _ClipRect;
    vec4 _Color; // @default = vec4(1, 1, 1, 1) @color
    vec4 _ScreenParams;
};


#line 49
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    float _BlurPercent; // @default = 50
    vec4 _Color; // @default = vec4(1, 1, 1, 1) @color
    vec4 _ScreenParams;

float _UiMaskCount; // @default = 0.0
float _UiRectMaskCount; // @default = 0.0
}RU_Material_0;

#line 19
vec4 UnityObjectToClipPos_0(vec4 p_0)
{

#line 19
    return (((p_0) * (transpose(RU_Frame_0.viewProj_0))));
}

vec4 ComputeScreenPos_0(vec4 p_1)
{

#line 22
    return vec4(p_1.xy * 0.5 + p_1.w * 0.5, p_1.zw);
}


#line 22
layout(location = 1)
out vec2 entryPointParam_vert_uv_0;


#line 22
layout(location = 2)
out vec4 entryPointParam_vert_color_0;


#line 22
layout(location = 5)
out vec4 entryPointParam_vert_screen_0;


#line 22
layout(location = 0) in vec4 v_vertex_0; // @vertex Position required


#line 22
layout(location = 1) in vec2 v_uv_0; // @vertex TexCoord0 optional


#line 22
layout(location = 2) in vec4 v_color_0; // @vertex Color optional


#line 78
struct F_0
{
    vec4 pos_0;
    vec2 uv_0;
    vec4 color_0;
    vec4 screen_0;
};


#line 78
void main()
{

#line 78
    F_0 o_0;

#line 78
    vec4 _S1 = UnityObjectToClipPos_0(v_vertex_0);

#line 78
    o_0.pos_0 = _S1;

#line 78
    o_0.uv_0 = v_uv_0;

#line 78
    o_0.color_0 = v_color_0 * RU_Material_0._Color;

#line 78
    o_0.screen_0 = ComputeScreenPos_0(_S1);

#line 78
    F_0 _S2 = o_0;

#line 78
    gl_Position = o_0.pos_0;

#line 78
    entryPointParam_vert_uv_0 = _S2.uv_0;

#line 78
    entryPointParam_vert_color_0 = _S2.color_0;

#line 78
    entryPointParam_vert_screen_0 = _S2.screen_0;

#line 78
    return;
}


// @rimunity-host-matrices 1
