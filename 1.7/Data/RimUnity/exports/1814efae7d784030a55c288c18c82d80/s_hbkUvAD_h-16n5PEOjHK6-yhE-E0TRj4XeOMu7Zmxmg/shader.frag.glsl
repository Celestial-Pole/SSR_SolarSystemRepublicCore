#version 450
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    vec4 _Color; // @default = vec4(1, 1, 1, 1) @color
}RU_Material_0;


#line 62 0
layout(binding = 1, set = 2)
uniform sampler2D _MainTex; // @default = black


#line 64



#line 66
vec4 RU_tex2D_MainTex_0(vec2 uv_0)
{

#line 66
    return (texture(_MainTex, (vec2(uv_0.x, 1.0 - uv_0.y))));
}


#line 1098 1
layout(location = 0)
out vec4 entryPointParam_frag_0;


#line 1098
layout(location = 1) in vec2 i_uv_0; // @vertex TexCoord0 optional


#line 1098
layout(location = 2) in vec4 i_color_0; // @vertex Color optional


#line 74 0
void main()
{

#line 74
    vec4 _S1 = RU_tex2D_MainTex_0(i_uv_0);

#line 74
    vec4 c_0 = _S1;

#line 74
    c_0.xyz = _S1.xyz * (i_color_0.xyz * i_color_0.w);

#line 74
    c_0[3] = c_0[3] * i_color_0.w;

#line 74
    entryPointParam_frag_0 = c_0;

#line 74
    return;
}


// @rimunity-host-matrices 1
