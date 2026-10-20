#version 450
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{
    vec4 _Color; // @default = vec4(1, 1, 1, 1) @color
    vec4 _MainTex_ST; // @default = vec4(0, 0, 1, 1)
}RU_Material_0;


#line 64 0
layout(binding = 1, set = 2)
uniform sampler2D _MainTex; // @default = white


#line 66



#line 68
vec4 RU_tex2D_MainTex_0(vec2 uv_0)
{

#line 68
    return (texture(_MainTex, (vec2(uv_0.x, 1.0 - uv_0.y))));
}


#line 1098 1
layout(location = 0)
out vec4 entryPointParam_frag_0;


#line 1098
layout(location = 1) in vec2 i_uv_0; // @vertex TexCoord0 optional


#line 1098
layout(location = 6) in vec4 i_color_0; // @vertex TexCoord2 optional


#line 76 0
void main()
{

#line 76
    vec4 col_0 = RU_tex2D_MainTex_0(i_uv_0) * i_color_0;

#line 76
    if((col_0.w) <= 0.0)
    {

#line 76
        discard;

#line 76
    }

#line 76
    entryPointParam_frag_0 = col_0;

#line 76
    return;
}


// @rimunity-host-matrices 1
