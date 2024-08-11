// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "224/CelShader_2.0"
{
	Properties
	{
		_OutLineColor("OutLineColor", Color) = (0,0,0,0)
		_OutLineWidth("OutLineWidth", Range( 0 , 0.02)) = 0
		_Maintex("Maintex", 2D) = "white" {}
		[HDR]_MainTexColor("MainTexColor", Color) = (1,1,1,0)
		_SSSTex("SSSTex", 2D) = "white" {}
		_LimTex("LimTex", 2D) = "white" {}
		[HDR]_FirstShadowColor("FirstShadowColor", Color) = (0.1698113,0.1698113,0.1698113,0)
		_FirstShadowWidth("FirstShadowWidth", Range( 0 , 1)) = 0.7
		[HDR]_SecondShadowColor("SecondShadowColor", Color) = (0.2924528,0.2924528,0.2924528,0)
		_SecondShadowWidth("SecondShadowWidth", Range( 0 , 1)) = 0.55
		[HDR]_Speccolor("Speccolor", Color) = (1,1,1,0)
		_SpecIntensity("SpecIntensity", Range( 0 , 20)) = 0
		_SpecGloss("SpecGloss", Range( 1 , 30)) = 1
		[Toggle]_Rim_On("Rim_On", Float) = 0
		[HDR]_RimColor("RimColor", Color) = (1,1,1,0)
		_RimWidth("RimWidth", Range( 0.01 , 10)) = 0.1
		_Rimoffest("Rimoffest", Range( 0.01 , 1)) = 0.2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _OutLineWidth;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _OutLineColor.rgb;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
			float4 vertexColor : COLOR;
			float3 viewDir;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _Rim_On;
		uniform sampler2D _SSSTex;
		uniform float4 _SSSTex_ST;
		uniform sampler2D _Maintex;
		uniform float4 _Maintex_ST;
		uniform float4 _SecondShadowColor;
		uniform float4 _FirstShadowColor;
		uniform float _SecondShadowWidth;
		uniform sampler2D _LimTex;
		uniform float4 _LimTex_ST;
		uniform float4 _MainTexColor;
		uniform float _FirstShadowWidth;
		uniform float _SpecGloss;
		uniform float4 _Speccolor;
		uniform float _SpecIntensity;
		uniform float _Rimoffest;
		uniform float _RimWidth;
		uniform float4 _RimColor;
		uniform float4 _OutLineColor;
		uniform float _OutLineWidth;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_SSSTex = i.uv_texcoord * _SSSTex_ST.xy + _SSSTex_ST.zw;
			float2 uv_Maintex = i.uv_texcoord * _Maintex_ST.xy + _Maintex_ST.zw;
			float4 temp_cast_0 = (_SecondShadowWidth).xxxx;
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult4 = dot( ase_worldNormal , ase_worldlightDir );
			float HalfLambert24 = ( ( ( dotResult4 * 0.5 ) + 0.5 ) * ase_lightAtten );
			float2 uv_LimTex = i.uv_texcoord * _LimTex_ST.xy + _LimTex_ST.zw;
			float4 tex2DNode42 = tex2D( _LimTex, uv_LimTex );
			float4 ShadowMask45 = ( tex2DNode42.g * i.vertexColor );
			float4 lerpResult12 = lerp( ( tex2D( _SSSTex, uv_SSSTex ) * tex2D( _Maintex, uv_Maintex ) * _SecondShadowColor ) , ( tex2D( _Maintex, uv_Maintex ) * _FirstShadowColor ) , step( temp_cast_0 , ( ( HalfLambert24 + ShadowMask45 ) * 0.5 ) ));
			float4 temp_cast_1 = (_FirstShadowWidth).xxxx;
			float4 temp_cast_2 = (0.2).xxxx;
			float4 temp_cast_3 = (0.1).xxxx;
			float4 temp_cast_4 = (0.125).xxxx;
			float4 RemapMask73 = ( ShadowMask45 == temp_cast_2 ? ( ( ShadowMask45 * 1.2 ) - temp_cast_3 ) : ( ( ShadowMask45 * 1.25 ) - temp_cast_4 ) );
			float4 lerpResult39 = lerp( lerpResult12 , ( tex2D( _Maintex, uv_Maintex ) * _MainTexColor ) , step( temp_cast_1 , ( ( HalfLambert24 + RemapMask73 ) * 0.5 ) ));
			float3 normalizeResult78 = normalize( ( i.viewDir + ase_worldlightDir ) );
			float dotResult80 = dot( normalizeResult78 , ase_worldNormal );
			float4 temp_output_83_0 = ( lerpResult39 + ( step( ( 1.0 - tex2DNode42.b ) , pow( dotResult80 , _SpecGloss ) ) * _Speccolor * tex2DNode42.r * _SpecIntensity ) );
			float dotResult97 = dot( i.viewDir , ase_worldNormal );
			c.rgb = (( _Rim_On )?( ( temp_output_83_0 + ( pow( ( 1.0 - saturate( ( dotResult97 + _Rimoffest ) ) ) , _RimWidth ) * _RimColor ) ) ):( temp_output_83_0 )).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
542;202;1920;1019;2699.893;791.2921;2.792688;True;False
Node;AmplifyShaderEditor.CommentaryNode;46;-1498.456,137.242;Inherit;False;744.0012;450.1509;ShadowMask;4;42;43;44;45;ShadowMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;42;-1448.456,187.242;Inherit;True;Property;_LimTex;LimTex;5;0;Create;True;0;0;0;False;0;False;-1;None;73b400db15c01f548845286ded24da66;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;43;-1315.826,380.3932;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;23;-1487.839,-1742.437;Inherit;False;1175.459;403.9201;HalfLambert;10;5;4;2;1;8;22;21;7;6;24;HalfLambert;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1117.524,325.0237;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-1437.839,-1547.318;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-978.4539,331.4615;Inherit;False;ShadowMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;74;-2900.031,-298.4171;Inherit;False;1258.162;733.8021;RemapMask;16;58;60;59;61;63;65;62;64;71;72;66;67;68;69;70;73;RemapMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-1413.839,-1691.318;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;67;-2419.73,222.385;Inherit;False;Constant;_Float7;Float 7;8;0;Create;True;0;0;0;False;0;False;1.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-2438.73,110.385;Inherit;False;45;ShadowMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1149.839,-1510.318;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2831.031,-2.914924;Inherit;False;Constant;_Float5;Float 5;8;0;Create;True;0;0;0;False;0;False;1.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;4;-1137.839,-1616.318;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-2850.031,-114.9149;Inherit;False;45;ShadowMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-966.0762,-1692.437;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-2672.031,94.08511;Inherit;False;Constant;_Float6;Float 6;8;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-2260.73,319.385;Inherit;False;Constant;_Float8;Float 8;8;0;Create;True;0;0;0;False;0;False;0.125;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-2647.031,-151.9149;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-978.0762,-1578.438;Inherit;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-2217.73,80.38499;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-801.8075,-1643.525;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;-1924.73,151.3851;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;21;-858.1191,-1453.211;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;64;-2434.031,-96.91492;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;71;-2376.031,-76.9149;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;94;-1503.625,638.5804;Inherit;False;1361.425;554.9655;Spec高光;13;75;77;76;79;78;82;80;92;81;87;91;93;88;Spec高光;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2489.252,-248.417;Inherit;False;45;ShadowMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;72;-2161.031,-83.91489;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-2446.031,-173.915;Inherit;False;Constant;_Float4;Float 4;8;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-670.1495,-1572.474;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;56;-542.8334,-353.5571;Inherit;False;651.7984;470.7416;第二层阴影;8;25;52;53;54;11;55;10;12;第二层阴影;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-539.9078,-1571.946;Inherit;False;HalfLambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;75;-1405.437,713.7476;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;77;-1453.625,863.6846;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Compare;59;-2086.031,-203.915;Inherit;False;0;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;113;-1487.649,1226.713;Inherit;False;1334.824;556.735;Rim;11;96;95;97;106;107;98;102;103;105;101;104;Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-400.5995,-98.81566;Inherit;True;45;ShadowMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-397.6418,-182.1544;Inherit;False;24;HalfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-1204.151,757.3286;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-1865.869,-197.9962;Inherit;False;RemapMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;57;-525.728,168.4266;Inherit;False;633.4645;423.6699;第一层阴影;7;36;47;48;50;49;37;38;第一层阴影;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;95;-1437.649,1276.713;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;96;-1437.649,1438.058;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;47;-388.9418,413.018;Inherit;False;73;RemapMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-204.5986,1.184453;Inherit;False;Constant;_Float3;Float 3;8;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;79;-1110.953,877.2131;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;29;-1788.557,-1001.728;Inherit;True;Property;_Maintex;Maintex;2;0;Create;True;0;0;0;False;0;False;None;73b400db15c01f548845286ded24da66;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;27;-1496.771,-827.1496;Inherit;False;839.6409;461.1183;暗部;4;33;20;19;18;暗部;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-198.5987,-118.8157;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-382.9359,292.9673;Inherit;False;24;HalfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-1229.177,1460.362;Inherit;False;Property;_Rimoffest;Rimoffest;16;0;Create;True;0;0;0;False;0;False;0.2;0.55;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;26;-1494.893,-344.4012;Inherit;False;547.9998;449.999;第二层阴影;3;15;13;16;第二层阴影;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;78;-1084.663,762.5806;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;97;-1226.234,1283.403;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-492.8334,-263.595;Inherit;False;Property;_SecondShadowWidth;SecondShadowWidth;9;0;Create;True;0;0;0;False;0;False;0.55;0.31;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;80;-904.0448,777.5758;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;41;-1499.153,-1328.017;Inherit;False;583.4363;476.7094;亮部;3;35;40;34;亮部;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-67.59882,-69.81558;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-191.2634,476.0961;Inherit;False;Constant;_Float2;Float 2;8;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-185.2634,356.0965;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;33;-1467.622,-643.1082;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;13;-1444.894,-294.4009;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-1176.634,-778.5492;Inherit;True;Property;_SSSTex;SSSTex;4;0;Create;True;0;0;0;False;0;False;-1;None;73b400db15c01f548845286ded24da66;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-905.0448,894.5758;Inherit;False;Property;_SpecGloss;SpecGloss;12;0;Create;True;0;0;0;False;0;False;1;1;1;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;15;-1355.893,-106.4027;Inherit;False;Property;_FirstShadowColor;FirstShadowColor;6;1;[HDR];Create;True;0;0;0;False;0;False;0.1698113,0.1698113,0.1698113,0;0.754717,0.754717,0.754717,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;18;-1093.996,-578.6864;Inherit;False;Property;_SecondShadowColor;SecondShadowColor;8;1;[HDR];Create;True;0;0;0;False;0;False;0.2924528,0.2924528,0.2924528,0;1.164525,0.7415606,0.7415606,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-1071.176,1348.362;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1108.896,-172.4006;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-475.728,218.4266;Inherit;False;Property;_FirstShadowWidth;FirstShadowWidth;7;0;Create;True;0;0;0;False;0;False;0.7;0.44;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-849.9579,-694.2874;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;40;-1449.153,-1278.017;Inherit;True;Property;_TextureSample1;Texture Sample 1;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;10;-195.8215,-254.1727;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;81;-602.0449,791.5758;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-1372.123,-1063.308;Inherit;False;Property;_MainTexColor;MainTexColor;3;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1.331051,1.062786,1.03596,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-54.26332,405.0964;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;92;-684.071,688.5804;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;98;-979.1093,1283.448;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-442.1979,970.6108;Inherit;False;Property;_SpecIntensity;SpecIntensity;11;0;Create;True;0;0;0;False;0;False;0;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;91;-434.071,724.5804;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1077.717,-1172.214;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;12;-73.03499,-303.5571;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;38;-47.35599,239.9082;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-1027.573,1584.871;Inherit;False;Property;_RimWidth;RimWidth;15;0;Create;True;0;0;0;False;0;False;0.1;0.01;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;87;-820.761,981.5458;Inherit;False;Property;_Speccolor;Speccolor;10;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.5743492,0.5743492,0.5743492,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;103;-839.1093,1356.448;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;101;-691.1094,1351.448;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;105;-657.1093,1571.448;Inherit;False;Property;_RimColor;RimColor;14;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.4150943,0.1036584,0.08419366,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-319.4617,817.946;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;39;173.5035,-67.51936;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-387.824,1386.912;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;380.0605,231.8896;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;112;586.4238,691.8209;Inherit;False;Property;_OutLineWidth;OutLineWidth;1;0;Create;True;0;0;0;False;0;False;0;1.5E-05;0;0.02;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;389.1159,366.0869;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;111;548.4238,516.8209;Inherit;False;Property;_OutLineColor;OutLineColor;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4811321,0.1283019,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;109;611.9702,266.2235;Inherit;True;Property;_Rim_On;Rim_On;13;0;Create;True;0;0;0;False;0;False;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;110;884.8034,479.3578;Inherit;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1125.892,-114.7127;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;224/CelShader_2.0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;44;0;42;2
WireConnection;44;1;43;0
WireConnection;45;0;44;0
WireConnection;4;0;1;0
WireConnection;4;1;2;0
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;62;0;61;0
WireConnection;62;1;63;0
WireConnection;69;0;66;0
WireConnection;69;1;67;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;70;0;69;0
WireConnection;70;1;68;0
WireConnection;64;0;62;0
WireConnection;64;1;65;0
WireConnection;71;0;64;0
WireConnection;72;0;70;0
WireConnection;22;0;8;0
WireConnection;22;1;21;0
WireConnection;24;0;22;0
WireConnection;59;0;58;0
WireConnection;59;1;60;0
WireConnection;59;2;71;0
WireConnection;59;3;72;0
WireConnection;76;0;75;0
WireConnection;76;1;77;0
WireConnection;73;0;59;0
WireConnection;54;0;25;0
WireConnection;54;1;52;0
WireConnection;78;0;76;0
WireConnection;97;0;95;0
WireConnection;97;1;96;0
WireConnection;80;0;78;0
WireConnection;80;1;79;0
WireConnection;55;0;54;0
WireConnection;55;1;53;0
WireConnection;48;0;36;0
WireConnection;48;1;47;0
WireConnection;33;0;29;0
WireConnection;13;0;29;0
WireConnection;107;0;97;0
WireConnection;107;1;106;0
WireConnection;16;0;13;0
WireConnection;16;1;15;0
WireConnection;20;0;19;0
WireConnection;20;1;33;0
WireConnection;20;2;18;0
WireConnection;40;0;29;0
WireConnection;10;0;11;0
WireConnection;10;1;55;0
WireConnection;81;0;80;0
WireConnection;81;1;82;0
WireConnection;49;0;48;0
WireConnection;49;1;50;0
WireConnection;92;0;42;3
WireConnection;98;0;107;0
WireConnection;91;0;92;0
WireConnection;91;1;81;0
WireConnection;35;0;40;0
WireConnection;35;1;34;0
WireConnection;12;0;20;0
WireConnection;12;1;16;0
WireConnection;12;2;10;0
WireConnection;38;0;37;0
WireConnection;38;1;49;0
WireConnection;103;0;98;0
WireConnection;101;0;103;0
WireConnection;101;1;102;0
WireConnection;88;0;91;0
WireConnection;88;1;87;0
WireConnection;88;2;42;1
WireConnection;88;3;93;0
WireConnection;39;0;12;0
WireConnection;39;1;35;0
WireConnection;39;2;38;0
WireConnection;104;0;101;0
WireConnection;104;1;105;0
WireConnection;83;0;39;0
WireConnection;83;1;88;0
WireConnection;108;0;83;0
WireConnection;108;1;104;0
WireConnection;109;0;83;0
WireConnection;109;1;108;0
WireConnection;110;0;111;0
WireConnection;110;1;112;0
WireConnection;0;13;109;0
WireConnection;0;11;110;0
ASEEND*/
//CHKSM=435C3AA819D579BDD69F2068AB65058EAABAFD3E