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
float _OutlineWidth;
float4 _ProjectionParams;
float4x4 _RimUnity_InvProjection;
float4x4 _RimUnity_Projection;
float4x4 _RimUnity_View;
};
[[vk::binding(0, 2)]] ConstantBuffer<RU_MaterialData> RU_Material;
// @rimunity-material _DepthTex_ST,_OutlineWidth,_ProjectionParams,_RimUnity_InvProjection,_RimUnity_Projection,_RimUnity_View
#define _DepthTex_ST (RU_Material._DepthTex_ST)
#define _OutlineWidth (RU_Material._OutlineWidth)
#define _ProjectionParams (RU_Material._ProjectionParams)
#define _RimUnity_View (RU_Material._RimUnity_View)
#define _RimUnity_Projection (RU_Material._RimUnity_Projection)
#define _RimUnity_InvProjection (RU_Material._RimUnity_InvProjection)

float3 UnityObjectToViewPos ( float3 p ) { return mul ( _RimUnity_View , mul ( unity_ObjectToWorld , float4 ( p , 1 ) ) ) . xyz ; } float3 UnityObjectToViewPos ( float4 p ) { return UnityObjectToViewPos ( p . xyz ) ; } float4 UnityViewToClipPos ( float3 p ) { return mul ( _RimUnity_Projection , float4 ( p , 1 ) ) ; } float4 UnityViewToClipPos ( float4 p ) { return UnityViewToClipPos ( p . xyz ) ; } struct appdata { [[vk::location(0)]] float4 vertex : POSITION ; [[vk::location(1)]] float2 uv : TEXCOORD0 ; } ; struct v2f { float4 vertex : SV_POSITION ; [[vk::location(1)]] float3 orginalVert : TEXCOORD0 ; [[vk::location(5)]] float3 transposVert : TEXCOORD1 ; } ;    v2f vert ( appdata v ) { v2f o ; ; ; o . vertex = float4 ( UnityObjectToViewPos ( v . vertex ) , 1 ) ; o . orginalVert = o . vertex . xyz ; o . transposVert = o . vertex . xyz ; o . vertex = UnityViewToClipPos ( o . vertex . xyz ) ; return o ; } v2f RU_Line ( v2f from , v2f to , bool drawSpot , uint slot ) { float2 dirL = cross ( from . vertex . xyw , to . vertex . xyw ) . xy ; dirL = mul ( _RimUnity_InvProjection , float4 ( dirL , 0 , 0 ) ) . xy ; dirL = normalize ( dirL ) * _OutlineWidth ; dirL . y *= _ProjectionParams . x ; float2 dirT = float2 ( - dirL . y , dirL . x ) ; v2f toSpotT = to ; v2f toSpotL = to ; v2f lineTL = to ; v2f lineBL = from ; v2f fromSpotB = from ; v2f fromSpotL = from ; toSpotT . transposVert . xy += dirT * 1.5 ; toSpotL . transposVert . xy += dirL * 1.5 ; lineTL . transposVert . xy += dirL ; lineBL . transposVert . xy += dirL ; fromSpotB . transposVert . xy -= dirT * 1.5 ; fromSpotL . transposVert . xy += dirL * 1.5 ; toSpotT . vertex = UnityViewToClipPos ( toSpotT . transposVert ) ; toSpotL . vertex = UnityViewToClipPos ( toSpotL . transposVert ) ; lineTL . vertex = UnityViewToClipPos ( lineTL . transposVert ) ; lineBL . vertex = UnityViewToClipPos ( lineBL . transposVert ) ; fromSpotB . vertex = UnityViewToClipPos ( fromSpotB . transposVert ) ; fromSpotL . vertex = UnityViewToClipPos ( fromSpotL . transposVert ) ; v2f result = from ; if ( slot == 0 ) result = toSpotT ; else if ( slot == 1 ) result = toSpotL ; else if ( slot == 2 || slot == 6 || slot == 11 ) result = to ; else if ( slot == 3 ) result = fromSpotB ; else if ( slot == 4 ) result = fromSpotL ; else if ( slot == 8 || slot == 9 ) result = lineBL ; else if ( slot == 10 ) result = lineTL ; if ( slot < 6 && ! drawSpot ) result . vertex = from . vertex ; return result ; } struct RU_EdgeInput { [[vk::location(0)]] float4 vertex : POSITION ; [[vk::location(5)]] float4 to : TEXCOORD1 ; [[vk::location(6)]] float4 third : TEXCOORD2 ; } ; v2f RU_EdgeVertex ( RU_EdgeInput input ) { appdata a = ( appdata ) 0 ; a . vertex = input . vertex ; appdata b = ( appdata ) 0 ; b . vertex = float4 ( input . to . xyz , 1 ) ; appdata c = ( appdata ) 0 ; c . vertex = float4 ( input . third . xyz , 1 ) ; v2f from = vert ( a ) , to = vert ( b ) , third = vert ( c ) ; bool drawSpot = dot ( from . vertex . xyw , cross ( to . vertex . xyw , third . vertex . xyw ) ) < 0 ; return RU_Line ( from , to , drawSpot , ( uint ) input . to . w ) ; } float4 frag ( v2f i , out float depth : SV_DEPTH ) : SV_Target { ; if ( _OutlineWidth <= 0 ) discard ; float3 dir = i . transposVert . xyz - i . orginalVert . xyz ; float disSq = dot ( dir , dir ) ; float outlineWidthSq = _OutlineWidth * _OutlineWidth ; if ( outlineWidthSq <= disSq ) discard ; float2 deeperVert = UnityViewToClipPos ( float3 ( 0 , 0 , i . transposVert . z + 10 * sqrt ( disSq ) * sign ( i . transposVert . z ) ) ) . zw ; depth = deeperVert . x / deeperVert . y ; return float4 ( 0 , 0 , 0 , 1 ) ; } 
