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
float4 _DepthTex_ST;
uint _DiskCount;
float _DiskEnd;
float _DiskStart;
float _ExpendCurve;
float4 _InColor;
float4 _OutColor;
uint _Seed;
float4 _Time;
};
[[vk::binding(0, 2)]] ConstantBuffer<RU_MaterialData> RU_Material;
// @rimunity-material _DepthTex_ST,_DiskCount,_DiskEnd,_DiskStart,_ExpendCurve,_InColor,_OutColor,_Seed,_Time
#define _OutColor (RU_Material._OutColor)
#define _InColor (RU_Material._InColor)
#define _DiskEnd (RU_Material._DiskEnd)
#define _DiskStart (RU_Material._DiskStart)
#define _ExpendCurve (RU_Material._ExpendCurve)
#define _DiskCount (RU_Material._DiskCount)
#define _Seed (RU_Material._Seed)
#define _DepthTex_ST (RU_Material._DepthTex_ST.zwxy)
#define _Time (RU_Material._Time)
[[vk::binding(1, 2)]] Texture2D _DepthTex;
// @rimunity-texture 1 _DepthTex
[[vk::binding(2, 2)]] SamplerState RU_Sampler_DepthTex;
// @rimunity-combined 1 2
float4 RU_tex2D_DepthTex(float2 uv) { return _DepthTex.Sample(RU_Sampler_DepthTex, float2(uv.x,1-uv.y)); }
float4 RU_tex2D_DepthTex(float3 uv) { return RU_tex2D_DepthTex(uv.xy); }
float4 RU_tex2D_DepthTex(float4 uv) { return RU_tex2D_DepthTex(uv.xy); }
float4 RU_tex2Dlod_DepthTex(float4 uv) { return _DepthTex.SampleLevel(RU_Sampler_DepthTex, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dbias_DepthTex(float4 uv) { return _DepthTex.SampleBias(RU_Sampler_DepthTex, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dproj_DepthTex(float4 uv) { return _DepthTex.Sample(RU_Sampler_DepthTex, float2(uv.x/uv.w,1-uv.y/uv.w)); }
float4 RU_tex2Dgrad_DepthTex(float2 uv,float2 dx,float2 dy) { return _DepthTex.SampleGrad(RU_Sampler_DepthTex,float2(uv.x,1-uv.y),float2(dx.x,-dx.y),float2(dy.x,-dy.y)); }
static float RU_Mutable_ExpendCurve;

int2 Vec2FromSeed ( uint seed ) { return int2 ( sqrt ( seed ) , sqrt ( seed << 1 ) ) ; } float Hash1In2D ( int2 p , uint seed ) { int2 vec = Vec2FromSeed ( seed ) ; int l = vec . x * vec . x + vec . y * vec . y ; float2 n = l < 1 ? vec / l : vec ; return 2 * frac ( sin ( dot ( p , n ) ) * max ( l , 1 / l ) ) - 1 ; } float2 Hash2In2D ( int2 p , uint seed ) { return float2 ( Hash1In2D ( p , sqrt ( seed ) ) , Hash1In2D ( p , sqrt ( seed << 1 ) ) ) ; } float PerlinNoise ( float2 p , uint seed ) { int2 i = floor ( p ) ; float2 f = frac ( p ) ; float2 w = f * f * f * ( 6 * f * f - 15 * f + 10 ) ; float2 a = Hash2In2D ( i + int2 ( 0 , 0 ) , seed ) ; float2 b = Hash2In2D ( i + int2 ( 1 , 0 ) , seed ) ; float2 c = Hash2In2D ( i + int2 ( 0 , 1 ) , seed ) ; float2 d = Hash2In2D ( i + int2 ( 1 , 1 ) , seed ) ; return lerp ( lerp ( dot ( a , f - float2 ( 0 , 0 ) ) , dot ( b , f - float2 ( 1 , 0 ) ) , w . x ) , lerp ( dot ( c , f - float2 ( 0 , 1 ) ) , dot ( d , f - float2 ( 1 , 1 ) ) , w . x ) , w . y ) ; } struct appdata { [[vk::location(0)]] float4 vertex : POSITION ; [[vk::location(1)]] float2 uv : TEXCOORD0 ; } ; struct v2f { [[vk::location(1)]] float2 uv : TEXCOORD0 ; [[vk::location(5)]] float2 uvDepth : TEXCOORD1 ; [[vk::location(6)]] float4 model : TEXCOORD2 ; float4 vertex : SV_POSITION ; } ;          v2f vert ( appdata v ) {
RU_Mutable_ExpendCurve = _ExpendCurve;
 v2f o ; ; ; o . vertex = UnityObjectToClipPos ( v . vertex ) ; o . uv = v . uv ; o . uvDepth = TRANSFORM_TEX ( v . uv , _DepthTex ) ; o . model = v . vertex ; return o ; } float4 frag ( v2f i ) : SV_Target {
RU_Mutable_ExpendCurve = _ExpendCurve;
 ; RU_Mutable_ExpendCurve = max ( RU_Mutable_ExpendCurve , 0 ) ; float noise = PerlinNoise ( float2 ( ( i . uv . x - _Time . w ) * 64 , i . uv . y * 16 ) , _Seed ) ; noise = lerp ( 1 , noise / ( 1 - i . uv . x ) , i . uv . x ) ; float scale = ( 1 - i . uv . x * i . uv . x ) * max ( noise , 0 ) ; float partX = frac ( i . uv . x * _DiskCount ) ; float bround = scale * ( sin ( partX * 3.14159265359 ) * RU_Mutable_ExpendCurve + 1 ) / ( RU_Mutable_ExpendCurve + 1 ) ; float diskEnd = scale * ( ( _DiskEnd + partX - 1 ) / _DiskEnd ) / ( RU_Mutable_ExpendCurve + 1 ) ; float w = ( _DiskStart * _DiskEnd - partX ) / _DiskEnd ; float diskStart = w > 0 ? scale * ( 1 - partX / _DiskEnd ) / ( RU_Mutable_ExpendCurve + 1 ) : 0 ; float r = abs ( i . uv . y - 0.5 ) * 2 ; float4 col = _InColor * max ( max ( 2 * ( diskStart - r ) , 0 ) / diskStart , 0 ) * clamp ( w / _DiskStart , 0 , 1 ) ; col += _InColor * max ( max ( 2 * ( diskEnd - r ) , 0 ) / diskEnd , 0 ) ; col += clamp ( 2 * ( bround - r ) * r / bround , 0 , 1 ) * _OutColor ; col *= sin ( max ( 1 - i . uv . x , 0 ) * 1.570796326795 ) ; return col ; } 
