#version 450


#line 56 0
struct RU_MaterialData_0
{
    vec4 _DepthTex_ST; // @default = vec4(0, 0, 1, 1)
    float _OutlineWidth; // @default = 0.015625
    vec4 _ProjectionParams;
    mat4 _RimUnity_InvProjection;
    mat4 _RimUnity_Projection;
    mat4 _RimUnity_View;
};


#line 64
layout(binding = 0, set = 2, std140) uniform block_RU_MaterialData_0
{    float _OutlineWidth; // @default = 0.015625
    vec4 _ProjectionParams;
    mat4 _RimUnity_InvProjection;
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

#line 73
vec3 UnityObjectToViewPos_0(vec3 p_0)
{

#line 73
    return ((((((vec4(p_0, 1.0)) * (transpose(RU_Object_0.model_0))))) * (transpose(RU_Material_0._RimUnity_View)))).xyz;
}


#line 73
vec3 UnityObjectToViewPos_1(vec4 p_1)
{

#line 73
    return UnityObjectToViewPos_0(p_1.xyz);
}


#line 73
vec4 UnityViewToClipPos_0(vec3 p_2)
{

#line 73
    return (((vec4(p_2, 1.0)) * (transpose(RU_Material_0._RimUnity_Projection))));
}


#line 73
struct v2f_0
{
    vec4 vertex_0;
    vec3 orginalVert_0;
    vec3 transposVert_0;
};


#line 73
struct appdata_0
{
    vec4 vertex_1;
    vec2 uv_0;
};


#line 73
v2f_0 vert_0(appdata_0 v_0)
{

#line 73
    v2f_0 o_0;

#line 73
    vec3 _S1 = vec4(UnityObjectToViewPos_1(v_0.vertex_1), 1.0).xyz;

#line 73
    o_0.orginalVert_0 = _S1;

#line 73
    o_0.transposVert_0 = _S1;

#line 73
    o_0.vertex_0 = UnityViewToClipPos_0(_S1);

#line 73
    return o_0;
}


#line 73
v2f_0 RU_Line_0(v2f_0 from_0, v2f_0 to_0, bool drawSpot_0, uint slot_0)
{

#line 73
    vec2 dirL_0 = normalize((((vec4(cross(from_0.vertex_0.xyw, to_0.vertex_0.xyw).xy, 0.0, 0.0)) * (transpose(RU_Material_0._RimUnity_InvProjection)))).xy) * RU_Material_0._OutlineWidth;

#line 73
    dirL_0[1] = dirL_0[1] * RU_Material_0._ProjectionParams.x;

#line 73
    vec2 dirT_0 = vec2(- dirL_0.y, dirL_0.x);

#line 73
    v2f_0 toSpotT_0 = to_0;

#line 73
    v2f_0 toSpotL_0 = to_0;

#line 73
    v2f_0 lineTL_0 = to_0;

#line 73
    v2f_0 lineBL_0 = from_0;

#line 73
    v2f_0 fromSpotB_0 = from_0;

#line 73
    v2f_0 fromSpotL_0 = from_0;

#line 73
    vec2 _S2 = dirT_0 * 1.5;

#line 73
    toSpotT_0.transposVert_0.xy = toSpotT_0.transposVert_0.xy + _S2;

#line 73
    toSpotL_0.transposVert_0.xy = toSpotL_0.transposVert_0.xy + dirL_0 * 1.5;

#line 73
    lineTL_0.transposVert_0.xy = lineTL_0.transposVert_0.xy + dirL_0;

#line 73
    lineBL_0.transposVert_0.xy = lineBL_0.transposVert_0.xy + dirL_0;

#line 73
    fromSpotB_0.transposVert_0.xy = fromSpotB_0.transposVert_0.xy - _S2;

#line 73
    fromSpotL_0.transposVert_0.xy = fromSpotL_0.transposVert_0.xy + dirL_0 * 1.5;

#line 73
    toSpotT_0.vertex_0 = UnityViewToClipPos_0(toSpotT_0.transposVert_0);

#line 73
    toSpotL_0.vertex_0 = UnityViewToClipPos_0(toSpotL_0.transposVert_0);

#line 73
    lineTL_0.vertex_0 = UnityViewToClipPos_0(lineTL_0.transposVert_0);

#line 73
    lineBL_0.vertex_0 = UnityViewToClipPos_0(lineBL_0.transposVert_0);

#line 73
    fromSpotB_0.vertex_0 = UnityViewToClipPos_0(fromSpotB_0.transposVert_0);

#line 73
    fromSpotL_0.vertex_0 = UnityViewToClipPos_0(fromSpotL_0.transposVert_0);

#line 73
    v2f_0 result_0 = from_0;

#line 73
    bool _S3;

#line 73
    if(slot_0 == 0U)
    {

#line 73
        result_0 = toSpotT_0;

#line 73
    }
    else
    {

#line 73
        if(slot_0 == 1U)
        {

#line 73
            result_0 = toSpotL_0;

#line 73
        }
        else
        {

#line 73
            if(slot_0 == 2U)
            {

#line 73
                _S3 = true;

#line 73
            }
            else
            {

#line 73
                _S3 = slot_0 == 6U;

#line 73
            }

#line 73
            if(_S3)
            {

#line 73
                _S3 = true;

#line 73
            }
            else
            {

#line 73
                _S3 = slot_0 == 11U;

#line 73
            }

#line 73
            if(_S3)
            {

#line 73
                result_0 = to_0;

#line 73
            }
            else
            {

#line 73
                if(slot_0 == 3U)
                {

#line 73
                    result_0 = fromSpotB_0;

#line 73
                }
                else
                {

#line 73
                    if(slot_0 == 4U)
                    {

#line 73
                        result_0 = fromSpotL_0;

#line 73
                    }
                    else
                    {

#line 73
                        if(slot_0 == 8U)
                        {

#line 73
                            _S3 = true;

#line 73
                        }
                        else
                        {

#line 73
                            _S3 = slot_0 == 9U;

#line 73
                        }

#line 73
                        if(_S3)
                        {

#line 73
                            result_0 = lineBL_0;

#line 73
                        }
                        else
                        {

#line 73
                            if(slot_0 == 10U)
                            {

#line 73
                                result_0 = lineTL_0;

#line 73
                            }

#line 73
                        }

#line 73
                    }

#line 73
                }

#line 73
            }

#line 73
        }

#line 73
    }

#line 73
    if(slot_0 < 6U)
    {

#line 73
        _S3 = !drawSpot_0;

#line 73
    }
    else
    {

#line 73
        _S3 = false;

#line 73
    }

#line 73
    if(_S3)
    {

#line 73
        result_0.vertex_0 = from_0.vertex_0;

#line 73
    }

#line 73
    return result_0;
}


#line 73
layout(location = 1)
out vec3 entryPointParam_RU_EdgeVertex_orginalVert_0;


#line 73
layout(location = 5)
out vec3 entryPointParam_RU_EdgeVertex_transposVert_0;


#line 73
layout(location = 0) in vec4 input_vertex_0; // @vertex Position required


#line 73
layout(location = 5) in vec4 input_to_0; // @vertex TexCoord1 optional


#line 73
layout(location = 6) in vec4 input_third_0; // @vertex TexCoord2 optional


#line 73
void main()
{

#line 73
    const vec4 _S4 = vec4(0.0);

#line 73
    const vec2 _S5 = vec2(0.0);

#line 73
    appdata_0 a_0;

#line 73
    a_0.vertex_1 = _S4;

#line 73
    a_0.uv_0 = _S5;

#line 73
    a_0.vertex_1 = input_vertex_0;

#line 73
    appdata_0 b_0;

#line 73
    b_0.vertex_1 = _S4;

#line 73
    b_0.uv_0 = _S5;

#line 73
    b_0.vertex_1 = vec4(input_to_0.xyz, 1.0);

#line 73
    appdata_0 c_0;

#line 73
    c_0.vertex_1 = _S4;

#line 73
    c_0.uv_0 = _S5;

#line 73
    c_0.vertex_1 = vec4(input_third_0.xyz, 1.0);

#line 73
    v2f_0 from_1 = vert_0(a_0);

#line 73
    v2f_0 to_1 = vert_0(b_0);

#line 73
    v2f_0 _S6 = RU_Line_0(from_1, to_1, (dot(from_1.vertex_0.xyw, cross(to_1.vertex_0.xyw, vert_0(c_0).vertex_0.xyw))) < 0.0, uint(input_to_0.w));

#line 73
    gl_Position = _S6.vertex_0;

#line 73
    entryPointParam_RU_EdgeVertex_orginalVert_0 = _S6.orginalVert_0;

#line 73
    entryPointParam_RU_EdgeVertex_transposVert_0 = _S6.transposVert_0;

#line 73
    return;
}


// @rimunity-host-matrices 1
