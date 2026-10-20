// @rimunity-vertex 0 Position required
// @rimunity-vertex 1 TexCoord0 optional
// @rimunity-vertex 2 Color optional
// @rimunity-vertex 3 Normal optional
// @rimunity-vertex 4 Tangent optional
// @rimunity-vertex 5 TexCoord1 optional
// @rimunity-vertex 6 TexCoord2 optional
// @rimunity-vertex 7 TexCoord3 optional
// @rimunity-vertex 8 TexCoord4 optional
// @rimunity-vertex 9 TexCoord5 optional
// @rimunity-vertex 10 TexCoord6 optional
// @rimunity-vertex 11 TexCoord7 optional
// @rimunity-vertex 12 BlendWeight optional
// @rimunity-vertex 13 BlendIndices optional
struct RU_CameraData { float4x4 ViewProj; };
[[vk::binding(0, 0)]] ConstantBuffer<RU_CameraData> RU_Camera;
struct RU_ObjectData { float4x4 model; };
[[vk::push_constant]] ConstantBuffer<RU_ObjectData> RU_Object;
#define unity_ObjectToWorld RU_Object.model
#define UNITY_MATRIX_M RU_Object.model
#define UNITY_MATRIX_VP RU_Camera.ViewProj
#define UNITY_MATRIX_MVP mul(RU_Camera.ViewProj, RU_Object.model)
float4 UnityObjectToClipPos(float4 p) { return mul(RU_Camera.ViewProj, mul(RU_Object.model, p)); }
float4 UnityObjectToClipPos(float3 p) { return UnityObjectToClipPos(float4(p, 1)); }
float3 TransformObjectToWorld(float3 p) { return mul(RU_Object.model, float4(p, 1)).xyz; }
float4 TransformWorldToHClip(float3 p) { return mul(RU_Camera.ViewProj, float4(p, 1)); }
float4 UnityWorldToClipPos(float3 p) { return TransformWorldToHClip(p); }
float3 UnityObjectToWorldNormal(float3 normal) {
    float3x3 m = (float3x3)RU_Object.model;
    float3x3 cofactors = float3x3(cross(m[1],m[2]), cross(m[2],m[0]), cross(m[0],m[1]));
    return normalize(mul(cofactors, normal) * sign(dot(m[0],cofactors[0])));
}
float3 UnityObjectToWorldDir(float3 direction) { return normalize(mul((float3x3)RU_Object.model, direction)); }
float4 TransformObjectToHClip(float3 p) { return UnityObjectToClipPos(p); }
float4 ComputeScreenPos(float4 p) { return float4(p.xy * 0.5 + p.w * 0.5, p.zw); }
#define TRANSFORM_TEX(uv,name) ((uv).xy * name##_ST.xy + name##_ST.zw)
#define UNITY_INITIALIZE_OUTPUT(type,name) name = (type)0
//非雾、非实例化、单眼变体在 Unity 中也不产生这些字段和调用。
#define UNITY_FOG_COORDS(index)
#define UNITY_TRANSFER_FOG(output,position)
#define UNITY_APPLY_FOG(coord,color)
#define UNITY_VERTEX_INPUT_INSTANCE_ID
#define UNITY_SETUP_INSTANCE_ID(input)
#define UNITY_TRANSFER_INSTANCE_ID(input,output)
#define UNITY_VERTEX_OUTPUT_STEREO
#define UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output)
#define SAMPLE_TEXTURE2D(tex,samp,uv) tex.Sample(samp,float2((uv).x,1-(uv).y))
#define SAMPLE_TEXTURE2D_LOD(tex,samp,uv,lod) tex.SampleLevel(samp,float2((uv).x,1-(uv).y),lod)
#define SAMPLE_TEXTURE2D_BIAS(tex,samp,uv,bias) tex.SampleBias(samp,float2((uv).x,1-(uv).y),bias)
float4 ComputeGrabScreenPos(float4 p) { float4 r = p * 0.5; r.xy = float2(r.x, -r.y) + r.w; r.zw = p.zw; return r; }
float3 UnpackNormal(float4 n) { n.x *= n.w; float2 xy = n.xy * 2 - 1; return float3(xy, sqrt(1 - saturate(dot(xy, xy)))); }
float UnityGet2DClipping(float2 p, float4 r) { float2 v = step(r.xy,p)*step(p,r.zw); return v.x*v.y; }
struct appdata_base { [[vk::location(0)]] float4 vertex : POSITION; [[vk::location(3)]] float3 normal : NORMAL; [[vk::location(1)]] float4 texcoord : TEXCOORD0; };
struct appdata_tan { [[vk::location(0)]] float4 vertex : POSITION; [[vk::location(4)]] float4 tangent : TANGENT; [[vk::location(3)]] float3 normal : NORMAL; [[vk::location(1)]] float4 texcoord : TEXCOORD0; };
struct appdata_full { [[vk::location(0)]] float4 vertex : POSITION; [[vk::location(4)]] float4 tangent : TANGENT; [[vk::location(3)]] float3 normal : NORMAL; [[vk::location(1)]] float4 texcoord : TEXCOORD0; [[vk::location(5)]] float4 texcoord1 : TEXCOORD1; [[vk::location(6)]] float4 texcoord2 : TEXCOORD2; [[vk::location(7)]] float4 texcoord3 : TEXCOORD3; [[vk::location(2)]] float4 color : COLOR; };
struct RU_MaterialData {
float4 _MainTex_ST;
float4 _ProjectionParams;
float4x4 _RimUnity_Projection;
float4x4 _RimUnity_View;
float sizeIn;
float sizeOut;
float4 warpMap_TexelSize;
};
[[vk::binding(0, 2)]] ConstantBuffer<RU_MaterialData> RU_Material;
// @rimunity-material _MainTex_ST,_ProjectionParams,_RimUnity_Projection,_RimUnity_View,sizeIn,sizeOut,warpMap_TexelSize
#define sizeOut (RU_Material.sizeOut)
#define sizeIn (RU_Material.sizeIn)
#define warpMap_TexelSize (RU_Material.warpMap_TexelSize)
#define _MainTex_ST (RU_Material._MainTex_ST.zwxy)
#define _ProjectionParams (RU_Material._ProjectionParams)
#define _RimUnity_View (RU_Material._RimUnity_View)
#define _RimUnity_Projection (RU_Material._RimUnity_Projection)
[[vk::binding(1, 2)]] Texture2D _MainTex;
// @rimunity-texture 1 _MainTex
[[vk::binding(2, 2)]] SamplerState RU_Sampler_MainTex;
// @rimunity-combined 1 2
float4 RU_tex2D_MainTex(float2 uv) { return _MainTex.Sample(RU_Sampler_MainTex, float2(uv.x,1-uv.y)); }
float4 RU_tex2D_MainTex(float3 uv) { return RU_tex2D_MainTex(uv.xy); }
float4 RU_tex2D_MainTex(float4 uv) { return RU_tex2D_MainTex(uv.xy); }
float4 RU_tex2Dlod_MainTex(float4 uv) { return _MainTex.SampleLevel(RU_Sampler_MainTex, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dbias_MainTex(float4 uv) { return _MainTex.SampleBias(RU_Sampler_MainTex, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dproj_MainTex(float4 uv) { return _MainTex.Sample(RU_Sampler_MainTex, float2(uv.x/uv.w,1-uv.y/uv.w)); }
float4 RU_tex2Dgrad_MainTex(float2 uv,float2 dx,float2 dy) { return _MainTex.SampleGrad(RU_Sampler_MainTex,float2(uv.x,1-uv.y),float2(dx.x,-dx.y),float2(dy.x,-dy.y)); }
[[vk::binding(3, 2)]] Texture2D background;
// @rimunity-texture 3 background
[[vk::binding(4, 2)]] SamplerState RU_Samplerbackground;
// @rimunity-combined 3 4
float4 RU_tex2Dbackground(float2 uv) { return background.Sample(RU_Samplerbackground, float2(uv.x,1-uv.y)); }
float4 RU_tex2Dbackground(float3 uv) { return RU_tex2Dbackground(uv.xy); }
float4 RU_tex2Dbackground(float4 uv) { return RU_tex2Dbackground(uv.xy); }
float4 RU_tex2Dlodbackground(float4 uv) { return background.SampleLevel(RU_Samplerbackground, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dbiasbackground(float4 uv) { return background.SampleBias(RU_Samplerbackground, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dprojbackground(float4 uv) { return background.Sample(RU_Samplerbackground, float2(uv.x/uv.w,1-uv.y/uv.w)); }
float4 RU_tex2Dgradbackground(float2 uv,float2 dx,float2 dy) { return background.SampleGrad(RU_Samplerbackground,float2(uv.x,1-uv.y),float2(dx.x,-dx.y),float2(dy.x,-dy.y)); }
[[vk::binding(5, 2)]] Texture2D warpMap;
// @rimunity-texture 5 warpMap
[[vk::binding(6, 2)]] SamplerState RU_SamplerwarpMap;
// @rimunity-combined 5 6
float4 RU_tex2DwarpMap(float2 uv) { return warpMap.Sample(RU_SamplerwarpMap, float2(uv.x,1-uv.y)); }
float4 RU_tex2DwarpMap(float3 uv) { return RU_tex2DwarpMap(uv.xy); }
float4 RU_tex2DwarpMap(float4 uv) { return RU_tex2DwarpMap(uv.xy); }
float4 RU_tex2DlodwarpMap(float4 uv) { return warpMap.SampleLevel(RU_SamplerwarpMap, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2DbiaswarpMap(float4 uv) { return warpMap.SampleBias(RU_SamplerwarpMap, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2DprojwarpMap(float4 uv) { return warpMap.Sample(RU_SamplerwarpMap, float2(uv.x/uv.w,1-uv.y/uv.w)); }
float4 RU_tex2DgradwarpMap(float2 uv,float2 dx,float2 dy) { return warpMap.SampleGrad(RU_SamplerwarpMap,float2(uv.x,1-uv.y),float2(dx.x,-dx.y),float2(dy.x,-dy.y)); }

float3 UnityObjectToViewPos ( float3 p ) { return mul ( _RimUnity_View , mul ( unity_ObjectToWorld , float4 ( p , 1 ) ) ) . xyz ; } float3 UnityObjectToViewPos ( float4 p ) { return UnityObjectToViewPos ( p . xyz ) ; } struct appdata { [[vk::location(0)]] float4 vertex : POSITION ; } ; struct v2f { [[vk::location(1)]] float3 viewSpacePos : TEXCOORD0 ; [[vk::location(5)]] float3 viewSpaceZeroPoint : TEXCOORD1 ; [[vk::location(6)]] float4 uvBackground : TEXCOORD2 ; float4 vertex : SV_POSITION ; } ;        v2f vert ( appdata v ) { v2f o ; o . vertex = UnityObjectToClipPos ( v . vertex ) ; o . uvBackground = o . vertex ; o . uvBackground . y *= _ProjectionParams . x ; o . viewSpacePos = UnityObjectToViewPos ( v . vertex ) ; o . viewSpacePos . y *= _ProjectionParams . x ; o . viewSpaceZeroPoint = UnityObjectToViewPos ( float3 ( 0 , 0 , 0 ) ) ; o . viewSpaceZeroPoint . y *= _ProjectionParams . x ; return o ; } float4 frag ( v2f i ) : SV_Target { float warpMaper = length ( i . viewSpacePos . xy - i . viewSpaceZeroPoint . xy ) - sizeIn ; float4 dir = mul ( _RimUnity_Projection , float4 ( normalize ( i . viewSpacePos . xy - i . viewSpaceZeroPoint . xy ) , i . viewSpacePos . z , 1 ) ) ; float2 screenUV = i . uvBackground . xy / i . uvBackground . w ; screenUV = 0.5 * screenUV + 0.5 ; float mapFactor = ( warpMap_TexelSize . z - 1.0 ) * warpMap_TexelSize . x ; float mapOffseter = 0.5 * warpMap_TexelSize . x ; float2 inUV = screenUV + ( 1.0 / RU_tex2DlodwarpMap( float4 ( saturate ( - warpMaper / sizeIn ) * mapFactor + mapOffseter , 0.25 , 0 , 0 ) ) . x - 1.0 ) * dir . xy / dir . w ; float2 outUV = screenUV - ( 1.0 / RU_tex2DlodwarpMap( float4 ( saturate ( warpMaper / ( sizeOut - sizeIn ) ) * mapFactor + mapOffseter , 0.75 , 0 , 0 ) ) . x - 1.0 ) * dir . xy / dir . w ; return lerp ( RU_tex2Dlod_MainTex( float4 ( inUV , 0 , 0 ) ) , RU_tex2Dlodbackground( float4 ( outUV , 0 , 0 ) ) , step ( 0 , warpMaper ) ) ; } 
