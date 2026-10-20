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
float _DepthFactor;
float4 _DepthTex_ST;
float4 _MainTex_ST;
float4 _MatTex_ST;
float4 _ProjectionParams;
float4x4 _RimUnity_Projection;
float4x4 _RimUnity_View;
};
[[vk::binding(0, 2)]] ConstantBuffer<RU_MaterialData> RU_Material;
// @rimunity-material _DepthFactor,_DepthTex_ST,_MainTex_ST,_MatTex_ST,_ProjectionParams,_RimUnity_Projection,_RimUnity_View
#define _DepthFactor (RU_Material._DepthFactor)
#define _MatTex_ST (RU_Material._MatTex_ST.zwxy)
#define _DepthTex_ST (RU_Material._DepthTex_ST.zwxy)
#define _MainTex_ST (RU_Material._MainTex_ST.zwxy)
#define _ProjectionParams (RU_Material._ProjectionParams)
#define _RimUnity_View (RU_Material._RimUnity_View)
#define _RimUnity_Projection (RU_Material._RimUnity_Projection)
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
[[vk::binding(3, 2)]] Texture2D _MainTex;
// @rimunity-texture 3 _MainTex
[[vk::binding(4, 2)]] SamplerState RU_Sampler_MainTex;
// @rimunity-combined 3 4
float4 RU_tex2D_MainTex(float2 uv) { return _MainTex.Sample(RU_Sampler_MainTex, float2(uv.x,1-uv.y)); }
float4 RU_tex2D_MainTex(float3 uv) { return RU_tex2D_MainTex(uv.xy); }
float4 RU_tex2D_MainTex(float4 uv) { return RU_tex2D_MainTex(uv.xy); }
float4 RU_tex2Dlod_MainTex(float4 uv) { return _MainTex.SampleLevel(RU_Sampler_MainTex, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dbias_MainTex(float4 uv) { return _MainTex.SampleBias(RU_Sampler_MainTex, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dproj_MainTex(float4 uv) { return _MainTex.Sample(RU_Sampler_MainTex, float2(uv.x/uv.w,1-uv.y/uv.w)); }
float4 RU_tex2Dgrad_MainTex(float2 uv,float2 dx,float2 dy) { return _MainTex.SampleGrad(RU_Sampler_MainTex,float2(uv.x,1-uv.y),float2(dx.x,-dx.y),float2(dy.x,-dy.y)); }
[[vk::binding(5, 2)]] Texture2D _MatTex;
// @rimunity-texture 5 _MatTex
[[vk::binding(6, 2)]] SamplerState RU_Sampler_MatTex;
// @rimunity-combined 5 6
float4 RU_tex2D_MatTex(float2 uv) { return _MatTex.Sample(RU_Sampler_MatTex, float2(uv.x,1-uv.y)); }
float4 RU_tex2D_MatTex(float3 uv) { return RU_tex2D_MatTex(uv.xy); }
float4 RU_tex2D_MatTex(float4 uv) { return RU_tex2D_MatTex(uv.xy); }
float4 RU_tex2Dlod_MatTex(float4 uv) { return _MatTex.SampleLevel(RU_Sampler_MatTex, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dbias_MatTex(float4 uv) { return _MatTex.SampleBias(RU_Sampler_MatTex, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dproj_MatTex(float4 uv) { return _MatTex.Sample(RU_Sampler_MatTex, float2(uv.x/uv.w,1-uv.y/uv.w)); }
float4 RU_tex2Dgrad_MatTex(float2 uv,float2 dx,float2 dy) { return _MatTex.SampleGrad(RU_Sampler_MatTex,float2(uv.x,1-uv.y),float2(dx.x,-dx.y),float2(dy.x,-dy.y)); }

float3 UnityObjectToViewPos ( float3 p ) { return mul ( _RimUnity_View , mul ( unity_ObjectToWorld , float4 ( p , 1 ) ) ) . xyz ; } float3 UnityObjectToViewPos ( float4 p ) { return UnityObjectToViewPos ( p . xyz ) ; } float4 UnityViewToClipPos ( float3 p ) { return mul ( _RimUnity_Projection , float4 ( p , 1 ) ) ; } float4 UnityViewToClipPos ( float4 p ) { return UnityViewToClipPos ( p . xyz ) ; } struct appdata { [[vk::location(0)]] float4 vertex : POSITION ; [[vk::location(1)]] float2 uv : TEXCOORD0 ; [[vk::location(3)]] float3 normal : NORMAL ; } ; struct v2f { [[vk::location(1)]] float2 uv : TEXCOORD0 ; [[vk::location(5)]] float2 uvDepth : TEXCOORD1 ; [[vk::location(6)]] float3 viewPos : TEXCOORD2 ; [[vk::location(7)]] float3 viewDir : TEXCOORD3 ; [[vk::location(8)]] float3 normal : TEXCOORD4 ; float4 vertex : SV_POSITION ; } ;        float3 GetViewDir ( float3 viewPos , out float4 clipPos ) { clipPos = UnityViewToClipPos ( viewPos ) ; float3 near = viewPos ; near . z = sign ( near . z ) * _ProjectionParams . y ; near . xy *= UnityViewToClipPos ( float3 ( 0 , 0 , near . z ) ) . w / clipPos . w ; float3 far = viewPos ; far . z = sign ( far . z ) * _ProjectionParams . z ; far . xy *= UnityViewToClipPos ( float3 ( 0 , 0 , far . z ) ) . w / clipPos . w ; return far - near ; } float4 ShadingByMatTex ( float3 normal , float3 viewDir ) { float3 reflectDir = normalize ( reflect ( viewDir , normal ) ) ; float d = length ( reflectDir . xy ) ; reflectDir . xy *= ( 1 + d - reflectDir . z ) / ( 2 * d * sqrt ( 1 + d ) ) ; return RU_tex2D_MatTex( TRANSFORM_TEX ( ( reflectDir . xy * 0.5 + 0.5 ) , _MatTex ) ) ; } v2f vert ( appdata v ) { v2f o ; ; ; o . uv = TRANSFORM_TEX ( v . uv , _MainTex ) ; o . uvDepth = TRANSFORM_TEX ( v . uv , _DepthTex ) ; o . viewPos = UnityObjectToViewPos ( v . vertex ) ; o . viewDir = GetViewDir ( o . viewPos , o . vertex ) ; o . normal = UnityObjectToWorldNormal ( v . normal ) ; o . normal = mul ( _RimUnity_View , float4 ( o . normal , 0.0 ) ) . xyz ; float l = length ( o . normal ) ; if ( l < 0.001 ) o . normal = float3 ( 0 , 0 , 1 ) ; else o . normal /= l ; return o ; } float4 frag ( v2f i , out float depth : SV_DEPTH ) : SV_Target { ; float4 col = RU_tex2D_MainTex( i . uv ) ; if ( col . a < 0.5 ) discard ; i . viewPos . z -= ( RU_tex2D_DepthTex( i . uvDepth ) . x - 0.5 ) * _DepthFactor ; i . vertex = UnityViewToClipPos ( i . viewPos ) ; depth = i . vertex . z / i . vertex . w ; float4 outColor = float4 ( col . rgb * ShadingByMatTex ( i . normal , i . viewDir ) . rgb , col . a ) ; return outColor ; } 
