#version 450


#line 64 0
layout(binding = 1, set = 2)
uniform sampler2D _MainTex; // @default = white


#line 66



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


vec4 RU_tex2D_MainTex_0(vec2 uv_0)
{

#line 68
    return (texture(_MainTex, (vec2(uv_0.x, 1.0 - uv_0.y))));
}


#line 68
layout(location = 0)
out vec4 entryPointParam_frag_0;


#line 68
layout(location = 1) in vec2 i_uv_0; // @vertex TexCoord0 optional


#line 76
void main()
{

#line 76
    entryPointParam_frag_0 = RU_tex2D_MainTex_0(i_uv_0) * RU_Material_0._Color;

#line 76
    return;
}


// @rimunity-host-matrices 1
