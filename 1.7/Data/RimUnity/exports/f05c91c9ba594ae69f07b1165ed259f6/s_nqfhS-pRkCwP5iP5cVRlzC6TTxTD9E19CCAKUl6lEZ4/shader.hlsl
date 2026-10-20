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
struct RU_FrameData { float4 sunDirection; float4x4 worldToCamera; float4x4 viewProj; };
[[vk::binding(1, 0)]] ConstantBuffer<RU_FrameData> RU_Frame;
#define UNITY_MATRIX_VP RU_Frame.viewProj
#define UNITY_MATRIX_MVP RU_Frame.viewProj
float4 UnityObjectToClipPos(float4 p) { return mul(RU_Frame.viewProj, p); }
float4 UnityObjectToClipPos(float3 p) { return UnityObjectToClipPos(float4(p, 1)); }
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
float _BlurPercent;
float4 _ClipRect;
float4 _Color;
float4 _ScreenParams;
};
[[vk::binding(0, 2)]] ConstantBuffer<RU_MaterialData> RU_Material;
// @rimunity-material _BlurPercent,_ClipRect,_Color,_ScreenParams
#define _ClipRect (RU_Material._ClipRect)
#define _BlurPercent (RU_Material._BlurPercent)
#define _Color (RU_Material._Color)
#define _ScreenParams (RU_Material._ScreenParams)
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
[[vk::binding(3, 2)]] Texture2D _SSR_ScreenTexture;
// @rimunity-texture 3 _SSR_ScreenTexture
[[vk::binding(4, 2)]] SamplerState RU_Sampler_SSR_ScreenTexture;
// @rimunity-combined 3 4
float4 RU_tex2D_SSR_ScreenTexture(float2 uv) { return _SSR_ScreenTexture.Sample(RU_Sampler_SSR_ScreenTexture, float2(uv.x,1-uv.y)); }
float4 RU_tex2D_SSR_ScreenTexture(float3 uv) { return RU_tex2D_SSR_ScreenTexture(uv.xy); }
float4 RU_tex2D_SSR_ScreenTexture(float4 uv) { return RU_tex2D_SSR_ScreenTexture(uv.xy); }
float4 RU_tex2Dlod_SSR_ScreenTexture(float4 uv) { return _SSR_ScreenTexture.SampleLevel(RU_Sampler_SSR_ScreenTexture, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dbias_SSR_ScreenTexture(float4 uv) { return _SSR_ScreenTexture.SampleBias(RU_Sampler_SSR_ScreenTexture, float2(uv.x,1-uv.y),uv.w); }
float4 RU_tex2Dproj_SSR_ScreenTexture(float4 uv) { return _SSR_ScreenTexture.Sample(RU_Sampler_SSR_ScreenTexture, float2(uv.x/uv.w,1-uv.y/uv.w)); }
float4 RU_tex2Dgrad_SSR_ScreenTexture(float2 uv,float2 dx,float2 dy) { return _SSR_ScreenTexture.SampleGrad(RU_Sampler_SSR_ScreenTexture,float2(uv.x,1-uv.y),float2(dx.x,-dx.y),float2(dy.x,-dy.y)); }

     struct V { [[vk::location(0)]] float4 vertex : POSITION ; [[vk::location(1)]] float2 uv : TEXCOORD0 ; [[vk::location(2)]] float4 color : COLOR ; } ; struct F { float4 pos : SV_POSITION ; [[vk::location(1)]] float2 uv : TEXCOORD0 ; [[vk::location(2)]] float4 color : COLOR ; [[vk::location(5)]] float4 screen : TEXCOORD1 ; } ; F vert ( V v ) { F o ; o . pos = UnityObjectToClipPos ( v . vertex ) ; o . uv = v . uv ; o . color = v . color * _Color ; o . screen = ComputeScreenPos ( o . pos ) ; return o ; } float4 frag ( F i ) : SV_Target { float2 uv = i . screen . xy / i . screen . w ; float2 radius = ( _BlurPercent * .08 ) / _ScreenParams . xy ; float3 c = RU_tex2D_SSR_ScreenTexture( uv ) . rgb * 4 ; c += RU_tex2D_SSR_ScreenTexture( uv + float2 ( radius . x , 0 ) ) . rgb * 2 ; c += RU_tex2D_SSR_ScreenTexture( uv - float2 ( radius . x , 0 ) ) . rgb * 2 ; c += RU_tex2D_SSR_ScreenTexture( uv + float2 ( 0 , radius . y ) ) . rgb * 2 ; c += RU_tex2D_SSR_ScreenTexture( uv - float2 ( 0 , radius . y ) ) . rgb * 2 ; c += RU_tex2D_SSR_ScreenTexture( uv + radius ) . rgb ; c += RU_tex2D_SSR_ScreenTexture( uv - radius ) . rgb ; c += RU_tex2D_SSR_ScreenTexture( uv + float2 ( radius . x , - radius . y ) ) . rgb ; c += RU_tex2D_SSR_ScreenTexture( uv + float2 ( - radius . x , radius . y ) ) . rgb ; float4 mask = RU_tex2D_MainTex( i . uv ) * i . color ; return float4 ( c * ( 1.0 / 16.0 ) * mask . rgb , mask . a ) ; } 
