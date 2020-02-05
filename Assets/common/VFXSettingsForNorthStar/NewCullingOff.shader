Shader "Custom/NewCullingOff"
{
	Properties
	{
		[NoScaleOffset] Texture2D_E4969401("MainTex", 2D) = "white" {}
[NoScaleOffset] Texture2D_2C8B3EAF("BumpMap", 2D) = "bump" {}

	}
		SubShader
	{
		Tags
		{
			"RenderPipeline" = "HDRenderPipeline"
			"RenderType" = "HDLitShader"
			"Queue" = "Transparent"
		}

		Pass
		{
		// based on HDPBRPass.template
		Name "META"
		Tags { "LightMode" = "META" }

		//-------------------------------------------------------------------------------------
		// Render Modes (Blend, Cull, ZTest, Stencil, etc)
		//-------------------------------------------------------------------------------------

		Cull Off






		//-------------------------------------------------------------------------------------
		// End Render Modes
		//-------------------------------------------------------------------------------------

		HLSLPROGRAM

		#pragma target 4.5
		#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
		//#pragma enable_d3d11_debug_symbols

		#pragma multi_compile_instancing
		#pragma instancing_options renderinglayer
		#pragma multi_compile _ LOD_FADE_CROSSFADE

		//-------------------------------------------------------------------------------------
		// Variant Definitions (active field translations to HDRP defines)
		//-------------------------------------------------------------------------------------
		#define _MATERIAL_FEATURE_SPECULAR_COLOR 1
		#define _SURFACE_TYPE_TRANSPARENT 1
		#define _BLENDMODE_ALPHA 1
		// #define _BLENDMODE_ADD 1
		// #define _BLENDMODE_PRE_MULTIPLY 1
		#define _DOUBLESIDED_ON 1

		//-------------------------------------------------------------------------------------
		// End Variant Definitions
		//-------------------------------------------------------------------------------------

		#pragma vertex Vert
		#pragma fragment Frag

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"

		// define FragInputs structure
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"

		//-------------------------------------------------------------------------------------
		// Defines
		//-------------------------------------------------------------------------------------
				#define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
			// ACTIVE FIELDS:
			//   DoubleSided
			//   DoubleSided.Mirror
			//   FragInputs.isFrontFace
			//   Material.SpecularColor
			//   SurfaceType.Transparent
			//   BlendMode.Alpha
			//   AlphaFog
			//   SurfaceDescriptionInputs.uv0
			//   SurfaceDescription.Albedo
			//   SurfaceDescription.Normal
			//   SurfaceDescription.Specular
			//   SurfaceDescription.Emission
			//   SurfaceDescription.Smoothness
			//   SurfaceDescription.Occlusion
			//   SurfaceDescription.Alpha
			//   SurfaceDescription.AlphaClipThreshold
			//   AttributesMesh.normalOS
			//   AttributesMesh.tangentOS
			//   AttributesMesh.uv0
			//   AttributesMesh.uv1
			//   AttributesMesh.color
			//   AttributesMesh.uv2
			//   VaryingsMeshToPS.cullFace
			//   FragInputs.texCoord0
			//   VaryingsMeshToPS.texCoord0

		// this translates the new dependency tracker into the old preprocessor definitions for the existing HDRP shader code
		#define ATTRIBUTES_NEED_NORMAL
		#define ATTRIBUTES_NEED_TANGENT
		#define ATTRIBUTES_NEED_TEXCOORD0
		#define ATTRIBUTES_NEED_TEXCOORD1
		#define ATTRIBUTES_NEED_TEXCOORD2
		// #define ATTRIBUTES_NEED_TEXCOORD3
		#define ATTRIBUTES_NEED_COLOR
		// #define VARYINGS_NEED_POSITION_WS
		// #define VARYINGS_NEED_TANGENT_TO_WORLD
		#define VARYINGS_NEED_TEXCOORD0
		// #define VARYINGS_NEED_TEXCOORD1
		// #define VARYINGS_NEED_TEXCOORD2
		// #define VARYINGS_NEED_TEXCOORD3
		// #define VARYINGS_NEED_COLOR
		#define VARYINGS_NEED_CULLFACE
		// #define HAVE_MESH_MODIFICATION

		//-------------------------------------------------------------------------------------
		// End Defines
		//-------------------------------------------------------------------------------------

		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
		#ifdef DEBUG_DISPLAY
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
		#endif

		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"

	#if (SHADERPASS == SHADERPASS_FORWARD)
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"

		#define HAS_LIGHTLOOP

		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
	#else
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	#endif

		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

		//Used by SceneSelectionPass
		int _ObjectId;
		int _PassValue;

		//-------------------------------------------------------------------------------------
		// Interpolator Packing And Struct Declarations
		//-------------------------------------------------------------------------------------
	// Generated Type: AttributesMesh
	struct AttributesMesh {
		float3 positionOS : POSITION;
		float3 normalOS : NORMAL; // optional
		float4 tangentOS : TANGENT; // optional
		float4 uv0 : TEXCOORD0; // optional
		float4 uv1 : TEXCOORD1; // optional
		float4 uv2 : TEXCOORD2; // optional
		float4 color : COLOR; // optional
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : INSTANCEID_SEMANTIC;
		#endif // UNITY_ANY_INSTANCING_ENABLED
	};

	// Generated Type: VaryingsMeshToPS
	struct VaryingsMeshToPS {
		float4 positionCS : SV_Position;
		float4 texCoord0; // optional
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif // UNITY_ANY_INSTANCING_ENABLED
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
		#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
	};
	struct PackedVaryingsMeshToPS {
		float4 interp00 : TEXCOORD0; // auto-packed
		float4 positionCS : SV_Position; // unpacked
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID; // unpacked
		#endif // UNITY_ANY_INSTANCING_ENABLED
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // unpacked
		#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
	};
	PackedVaryingsMeshToPS PackVaryingsMeshToPS(VaryingsMeshToPS input)
	{
		PackedVaryingsMeshToPS output;
		output.positionCS = input.positionCS;
		output.interp00.xyzw = input.texCoord0;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif // UNITY_ANY_INSTANCING_ENABLED
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		return output;
	}
	VaryingsMeshToPS UnpackVaryingsMeshToPS(PackedVaryingsMeshToPS input)
	{
		VaryingsMeshToPS output;
		output.positionCS = input.positionCS;
		output.texCoord0 = input.interp00.xyzw;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif // UNITY_ANY_INSTANCING_ENABLED
		#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		output.cullFace = input.cullFace;
		#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
		return output;
	}

	// Generated Type: VaryingsMeshToDS
	struct VaryingsMeshToDS {
		float3 positionRWS;
		float3 normalWS;
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID;
		#endif // UNITY_ANY_INSTANCING_ENABLED
	};
	struct PackedVaryingsMeshToDS {
		float3 interp00 : TEXCOORD0; // auto-packed
		float3 interp01 : TEXCOORD1; // auto-packed
		#if UNITY_ANY_INSTANCING_ENABLED
		uint instanceID : CUSTOM_INSTANCE_ID; // unpacked
		#endif // UNITY_ANY_INSTANCING_ENABLED
	};
	PackedVaryingsMeshToDS PackVaryingsMeshToDS(VaryingsMeshToDS input)
	{
		PackedVaryingsMeshToDS output;
		output.interp00.xyz = input.positionRWS;
		output.interp01.xyz = input.normalWS;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif // UNITY_ANY_INSTANCING_ENABLED
		return output;
	}
	VaryingsMeshToDS UnpackVaryingsMeshToDS(PackedVaryingsMeshToDS input)
	{
		VaryingsMeshToDS output;
		output.positionRWS = input.interp00.xyz;
		output.normalWS = input.interp01.xyz;
		#if UNITY_ANY_INSTANCING_ENABLED
		output.instanceID = input.instanceID;
		#endif // UNITY_ANY_INSTANCING_ENABLED
		return output;
	}

	//-------------------------------------------------------------------------------------
	// End Interpolator Packing And Struct Declarations
	//-------------------------------------------------------------------------------------

	//-------------------------------------------------------------------------------------
	// Graph generated code
	//-------------------------------------------------------------------------------------
			// Shared Graph Properties (uniform inputs)
			CBUFFER_START(UnityPerMaterial)
			CBUFFER_END

			TEXTURE2D(Texture2D_E4969401); SAMPLER(samplerTexture2D_E4969401); float4 Texture2D_E4969401_TexelSize;
			TEXTURE2D(Texture2D_2C8B3EAF); SAMPLER(samplerTexture2D_2C8B3EAF); float4 Texture2D_2C8B3EAF_TexelSize;
			SAMPLER(_NormalFromTexture_46C3DE9D_Sampler_2_Linear_Repeat);
			SAMPLER(_SampleTexture2D_DCD952C4_Sampler_3_Linear_Repeat);

			// Pixel Graph Inputs
				struct SurfaceDescriptionInputs {
					float4 uv0; // optional
				};
				// Pixel Graph Outputs
					struct SurfaceDescription
					{
						float3 Albedo;
						float3 Normal;
						float3 Specular;
						float3 Emission;
						float Smoothness;
						float Occlusion;
						float Alpha;
						float AlphaClipThreshold;
					};

					// Shared Graph Node Functions

						void Unity_NormalFromTexture_float(Texture2D Texture, SamplerState Sampler, float2 UV, float Offset, float Strength, out float3 Out)
						{
							Offset = pow(Offset, 3) * 0.1;
							float2 offsetU = float2(UV.x + Offset, UV.y);
							float2 offsetV = float2(UV.x, UV.y + Offset);
							float normalSample = Texture.Sample(Sampler, UV);
							float uSample = Texture.Sample(Sampler, offsetU);
							float vSample = Texture.Sample(Sampler, offsetV);
							float3 va = float3(1, 0, (uSample - normalSample) * Strength);
							float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
							Out = normalize(cross(va, vb));
						}

						// Pixel Graph Evaluation
							SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
							{
								SurfaceDescription surface = (SurfaceDescription)0;
								float3 _NormalFromTexture_46C3DE9D_Out_5;
								Unity_NormalFromTexture_float(Texture2D_2C8B3EAF, samplerTexture2D_2C8B3EAF, IN.uv0.xy, 0.5, 8, _NormalFromTexture_46C3DE9D_Out_5);
								float4 _SampleTexture2D_DCD952C4_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_E4969401, samplerTexture2D_E4969401, IN.uv0.xy);
								float _SampleTexture2D_DCD952C4_R_4 = _SampleTexture2D_DCD952C4_RGBA_0.r;
								float _SampleTexture2D_DCD952C4_G_5 = _SampleTexture2D_DCD952C4_RGBA_0.g;
								float _SampleTexture2D_DCD952C4_B_6 = _SampleTexture2D_DCD952C4_RGBA_0.b;
								float _SampleTexture2D_DCD952C4_A_7 = _SampleTexture2D_DCD952C4_RGBA_0.a;
								surface.Albedo = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
								surface.Normal = _NormalFromTexture_46C3DE9D_Out_5;
								surface.Specular = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
								surface.Emission = (_SampleTexture2D_DCD952C4_RGBA_0.xyz);
								surface.Smoothness = 0;
								surface.Occlusion = 1;
								surface.Alpha = 1;
								surface.AlphaClipThreshold = 0;
								return surface;
							}

							//-------------------------------------------------------------------------------------
							// End graph generated code
							//-------------------------------------------------------------------------------------

						// $include("VertexAnimation.template.hlsl")


						//-------------------------------------------------------------------------------------
						// TEMPLATE INCLUDE : SharedCode.template.hlsl
						//-------------------------------------------------------------------------------------
							FragInputs BuildFragInputs(VaryingsMeshToPS input)
							{
								FragInputs output;
								ZERO_INITIALIZE(FragInputs, output);

								// Init to some default value to make the computer quiet (else it output 'divide by zero' warning even if value is not used).
								// TODO: this is a really poor workaround, but the variable is used in a bunch of places
								// to compute normals which are then passed on elsewhere to compute other values...
								output.tangentToWorld = k_identity3x3;
								output.positionSS = input.positionCS;       // input.positionCS is SV_Position

								// output.positionRWS = input.positionRWS;
								// output.tangentToWorld = BuildTangentToWorld(input.tangentWS, input.normalWS);
								output.texCoord0 = input.texCoord0;
								// output.texCoord1 = input.texCoord1;
								// output.texCoord2 = input.texCoord2;
								// output.texCoord3 = input.texCoord3;
								// output.color = input.color;
								#if _DOUBLESIDED_ON && SHADER_STAGE_FRAGMENT
								output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);
								#elif SHADER_STAGE_FRAGMENT
								output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);
								#endif // SHADER_STAGE_FRAGMENT

								return output;
							}

							SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
							{
								SurfaceDescriptionInputs output;
								ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

								// output.WorldSpaceNormal =            normalize(input.tangentToWorld[2].xyz);
								// output.ObjectSpaceNormal =           mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M);           // transposed multiplication by inverse matrix to handle normal scale
								// output.ViewSpaceNormal =             mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_I_V);         // transposed multiplication by inverse matrix to handle normal scale
								// output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
								// output.WorldSpaceTangent =           input.tangentToWorld[0].xyz;
								// output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
								// output.ViewSpaceTangent =            TransformWorldToViewDir(output.WorldSpaceTangent);
								// output.TangentSpaceTangent =         float3(1.0f, 0.0f, 0.0f);
								// output.WorldSpaceBiTangent =         input.tangentToWorld[1].xyz;
								// output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
								// output.ViewSpaceBiTangent =          TransformWorldToViewDir(output.WorldSpaceBiTangent);
								// output.TangentSpaceBiTangent =       float3(0.0f, 1.0f, 0.0f);
								// output.WorldSpaceViewDirection =     normalize(viewWS);
								// output.ObjectSpaceViewDirection =    TransformWorldToObjectDir(output.WorldSpaceViewDirection);
								// output.ViewSpaceViewDirection =      TransformWorldToViewDir(output.WorldSpaceViewDirection);
								// float3x3 tangentSpaceTransform =     float3x3(output.WorldSpaceTangent,output.WorldSpaceBiTangent,output.WorldSpaceNormal);
								// output.TangentSpaceViewDirection =   mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
								// output.WorldSpacePosition =          GetAbsolutePositionWS(input.positionRWS);
								// output.ObjectSpacePosition =         TransformWorldToObject(input.positionRWS);
								// output.ViewSpacePosition =           TransformWorldToView(input.positionRWS);
								// output.TangentSpacePosition =        float3(0.0f, 0.0f, 0.0f);
								// output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionRWS), _ProjectionParams.x);
								output.uv0 = input.texCoord0;
								// output.uv1 =                         input.texCoord1;
								// output.uv2 =                         input.texCoord2;
								// output.uv3 =                         input.texCoord3;
								// output.VertexColor =                 input.color;
								// output.FaceSign =                    input.isFrontFace;
								// output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value

								return output;
							}

							// existing HDRP code uses the combined function to go directly from packed to frag inputs
							FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
							{
								UNITY_SETUP_INSTANCE_ID(input);
								VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
								return BuildFragInputs(unpacked);
							}

							//-------------------------------------------------------------------------------------
							// END TEMPLATE INCLUDE : SharedCode.template.hlsl
							//-------------------------------------------------------------------------------------



								void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
								{
									// setup defaults -- these are used if the graph doesn't output a value
									ZERO_INITIALIZE(SurfaceData, surfaceData);
									surfaceData.ambientOcclusion = 1.0f;

									// copy across graph values, if defined
									surfaceData.baseColor = surfaceDescription.Albedo;
									surfaceData.perceptualSmoothness = surfaceDescription.Smoothness;
									surfaceData.ambientOcclusion = surfaceDescription.Occlusion;
									// surfaceData.metallic =              surfaceDescription.Metallic;
									surfaceData.specularColor = surfaceDescription.Specular;

									// These static material feature allow compile time optimization
									surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
							#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
									surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
							#endif

									float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
									// doubleSidedConstants = float3(-1.0, -1.0, -1.0);
									doubleSidedConstants = float3(1.0,  1.0, -1.0);

									// tangent-space normal
									float3 normalTS = float3(0.0f, 0.0f, 1.0f);
									normalTS = surfaceDescription.Normal;

									// compute world space normal
									GetNormalWS(fragInputs, normalTS, surfaceData.normalWS, doubleSidedConstants);

									surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];

									surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);    // The tangent is not normalize in tangentToWorld for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
									surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);

									// By default we use the ambient occlusion with Tri-ace trick (apply outside) for specular occlusion.
									// If user provide bent normal then we process a better term
									surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));

							#if HAVE_DECALS
									if (_EnableDecals)
									{
										DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, surfaceDescription.Alpha);
										ApplyDecalToSurfaceData(decalSurfaceData, surfaceData);
									}
							#endif

							#ifdef DEBUG_DISPLAY
									if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
									{
										// TODO: need to update mip info
										surfaceData.metallic = 0;
									}

									// We need to call ApplyDebugToSurfaceData after filling the surfarcedata and before filling builtinData
									// as it can modify attribute use for static lighting
									ApplyDebugToSurfaceData(fragInputs.tangentToWorld, surfaceData);
							#endif
								}

								void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
								{
							#ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
									uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx)); // Quantize V to _ScreenSize values
									LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
							#endif

									float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
									// doubleSidedConstants = float3(-1.0, -1.0, -1.0);
									doubleSidedConstants = float3(1.0,  1.0, -1.0);

									ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants);

									SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
									SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);

									// Perform alpha test very early to save performance (a killed pixel will not sample textures)
									// TODO: split graph evaluation to grab just alpha dependencies first? tricky..
									// DoAlphaTest(surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold);

									BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);

									// Builtin Data
									// For back lighting we use the oposite vertex normal 
									InitBuiltinData(posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);

									builtinData.emissiveColor = surfaceDescription.Emission;

									PostInitBuiltinData(V, posInput, surfaceData, builtinData);
								}

								//-------------------------------------------------------------------------------------
								// Pass Includes
								//-------------------------------------------------------------------------------------
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassLightTransport.hlsl"
								//-------------------------------------------------------------------------------------
								// End Pass Includes
								//-------------------------------------------------------------------------------------

								ENDHLSL
							}

							Pass
							{
									// based on HDPBRPass.template
									Name "ShadowCaster"
									Tags { "LightMode" = "ShadowCaster" }

									//-------------------------------------------------------------------------------------
									// Render Modes (Blend, Cull, ZTest, Stencil, etc)
									//-------------------------------------------------------------------------------------
									Blend One Zero



									ZWrite On



									ColorMask 0

									//-------------------------------------------------------------------------------------
									// End Render Modes
									//-------------------------------------------------------------------------------------

									HLSLPROGRAM

									#pragma target 4.5
									#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
									//#pragma enable_d3d11_debug_symbols

									#pragma multi_compile_instancing
									#pragma instancing_options renderinglayer
									#pragma multi_compile _ LOD_FADE_CROSSFADE

									//-------------------------------------------------------------------------------------
									// Variant Definitions (active field translations to HDRP defines)
									//-------------------------------------------------------------------------------------
									#define _MATERIAL_FEATURE_SPECULAR_COLOR 1
									#define _SURFACE_TYPE_TRANSPARENT 1
									#define _BLENDMODE_ALPHA 1
									// #define _BLENDMODE_ADD 1
									// #define _BLENDMODE_PRE_MULTIPLY 1
									#define _DOUBLESIDED_ON 1

									//-------------------------------------------------------------------------------------
									// End Variant Definitions
									//-------------------------------------------------------------------------------------

									#pragma vertex Vert
									#pragma fragment Frag

									#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

									#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"

									// define FragInputs structure
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"

									//-------------------------------------------------------------------------------------
									// Defines
									//-------------------------------------------------------------------------------------
											#define SHADERPASS SHADERPASS_SHADOWS
										// ACTIVE FIELDS:
										//   DoubleSided
										//   DoubleSided.Mirror
										//   FragInputs.isFrontFace
										//   Material.SpecularColor
										//   SurfaceType.Transparent
										//   BlendMode.Alpha
										//   AlphaFog
										//   SurfaceDescription.Alpha
										//   SurfaceDescription.AlphaClipThreshold
										//   VaryingsMeshToPS.cullFace

									// this translates the new dependency tracker into the old preprocessor definitions for the existing HDRP shader code
									// #define ATTRIBUTES_NEED_NORMAL
									// #define ATTRIBUTES_NEED_TANGENT
									// #define ATTRIBUTES_NEED_TEXCOORD0
									// #define ATTRIBUTES_NEED_TEXCOORD1
									// #define ATTRIBUTES_NEED_TEXCOORD2
									// #define ATTRIBUTES_NEED_TEXCOORD3
									// #define ATTRIBUTES_NEED_COLOR
									// #define VARYINGS_NEED_POSITION_WS
									// #define VARYINGS_NEED_TANGENT_TO_WORLD
									// #define VARYINGS_NEED_TEXCOORD0
									// #define VARYINGS_NEED_TEXCOORD1
									// #define VARYINGS_NEED_TEXCOORD2
									// #define VARYINGS_NEED_TEXCOORD3
									// #define VARYINGS_NEED_COLOR
									#define VARYINGS_NEED_CULLFACE
									// #define HAVE_MESH_MODIFICATION

									//-------------------------------------------------------------------------------------
									// End Defines
									//-------------------------------------------------------------------------------------

									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
									#ifdef DEBUG_DISPLAY
										#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
									#endif

									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"

								#if (SHADERPASS == SHADERPASS_FORWARD)
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"

									#define HAS_LIGHTLOOP

									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
								#else
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
								#endif

									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
									#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

									//Used by SceneSelectionPass
									int _ObjectId;
									int _PassValue;

									//-------------------------------------------------------------------------------------
									// Interpolator Packing And Struct Declarations
									//-------------------------------------------------------------------------------------
								// Generated Type: AttributesMesh
								struct AttributesMesh {
									float3 positionOS : POSITION;
									#if UNITY_ANY_INSTANCING_ENABLED
									uint instanceID : INSTANCEID_SEMANTIC;
									#endif // UNITY_ANY_INSTANCING_ENABLED
								};

								// Generated Type: VaryingsMeshToPS
								struct VaryingsMeshToPS {
									float4 positionCS : SV_Position;
									#if UNITY_ANY_INSTANCING_ENABLED
									uint instanceID : CUSTOM_INSTANCE_ID;
									#endif // UNITY_ANY_INSTANCING_ENABLED
									#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
									FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
									#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
								};
								struct PackedVaryingsMeshToPS {
									float4 positionCS : SV_Position; // unpacked
									#if UNITY_ANY_INSTANCING_ENABLED
									uint instanceID : CUSTOM_INSTANCE_ID; // unpacked
									#endif // UNITY_ANY_INSTANCING_ENABLED
									#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
									FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // unpacked
									#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
								};
								PackedVaryingsMeshToPS PackVaryingsMeshToPS(VaryingsMeshToPS input)
								{
									PackedVaryingsMeshToPS output;
									output.positionCS = input.positionCS;
									#if UNITY_ANY_INSTANCING_ENABLED
									output.instanceID = input.instanceID;
									#endif // UNITY_ANY_INSTANCING_ENABLED
									#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
									output.cullFace = input.cullFace;
									#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
									return output;
								}
								VaryingsMeshToPS UnpackVaryingsMeshToPS(PackedVaryingsMeshToPS input)
								{
									VaryingsMeshToPS output;
									output.positionCS = input.positionCS;
									#if UNITY_ANY_INSTANCING_ENABLED
									output.instanceID = input.instanceID;
									#endif // UNITY_ANY_INSTANCING_ENABLED
									#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
									output.cullFace = input.cullFace;
									#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
									return output;
								}

								// Generated Type: VaryingsMeshToDS
								struct VaryingsMeshToDS {
									float3 positionRWS;
									float3 normalWS;
									#if UNITY_ANY_INSTANCING_ENABLED
									uint instanceID : CUSTOM_INSTANCE_ID;
									#endif // UNITY_ANY_INSTANCING_ENABLED
								};
								struct PackedVaryingsMeshToDS {
									float3 interp00 : TEXCOORD0; // auto-packed
									float3 interp01 : TEXCOORD1; // auto-packed
									#if UNITY_ANY_INSTANCING_ENABLED
									uint instanceID : CUSTOM_INSTANCE_ID; // unpacked
									#endif // UNITY_ANY_INSTANCING_ENABLED
								};
								PackedVaryingsMeshToDS PackVaryingsMeshToDS(VaryingsMeshToDS input)
								{
									PackedVaryingsMeshToDS output;
									output.interp00.xyz = input.positionRWS;
									output.interp01.xyz = input.normalWS;
									#if UNITY_ANY_INSTANCING_ENABLED
									output.instanceID = input.instanceID;
									#endif // UNITY_ANY_INSTANCING_ENABLED
									return output;
								}
								VaryingsMeshToDS UnpackVaryingsMeshToDS(PackedVaryingsMeshToDS input)
								{
									VaryingsMeshToDS output;
									output.positionRWS = input.interp00.xyz;
									output.normalWS = input.interp01.xyz;
									#if UNITY_ANY_INSTANCING_ENABLED
									output.instanceID = input.instanceID;
									#endif // UNITY_ANY_INSTANCING_ENABLED
									return output;
								}

								//-------------------------------------------------------------------------------------
								// End Interpolator Packing And Struct Declarations
								//-------------------------------------------------------------------------------------

								//-------------------------------------------------------------------------------------
								// Graph generated code
								//-------------------------------------------------------------------------------------
										// Shared Graph Properties (uniform inputs)
										CBUFFER_START(UnityPerMaterial)
										CBUFFER_END

										TEXTURE2D(Texture2D_E4969401); SAMPLER(samplerTexture2D_E4969401); float4 Texture2D_E4969401_TexelSize;
										TEXTURE2D(Texture2D_2C8B3EAF); SAMPLER(samplerTexture2D_2C8B3EAF); float4 Texture2D_2C8B3EAF_TexelSize;

										// Pixel Graph Inputs
											struct SurfaceDescriptionInputs {
											};
											// Pixel Graph Outputs
												struct SurfaceDescription
												{
													float Alpha;
													float AlphaClipThreshold;
												};

												// Shared Graph Node Functions
												// Pixel Graph Evaluation
													SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
													{
														SurfaceDescription surface = (SurfaceDescription)0;
														surface.Alpha = 1;
														surface.AlphaClipThreshold = 0;
														return surface;
													}

													//-------------------------------------------------------------------------------------
													// End graph generated code
													//-------------------------------------------------------------------------------------

												// $include("VertexAnimation.template.hlsl")


												//-------------------------------------------------------------------------------------
												// TEMPLATE INCLUDE : SharedCode.template.hlsl
												//-------------------------------------------------------------------------------------
													FragInputs BuildFragInputs(VaryingsMeshToPS input)
													{
														FragInputs output;
														ZERO_INITIALIZE(FragInputs, output);

														// Init to some default value to make the computer quiet (else it output 'divide by zero' warning even if value is not used).
														// TODO: this is a really poor workaround, but the variable is used in a bunch of places
														// to compute normals which are then passed on elsewhere to compute other values...
														output.tangentToWorld = k_identity3x3;
														output.positionSS = input.positionCS;       // input.positionCS is SV_Position

														// output.positionRWS = input.positionRWS;
														// output.tangentToWorld = BuildTangentToWorld(input.tangentWS, input.normalWS);
														// output.texCoord0 = input.texCoord0;
														// output.texCoord1 = input.texCoord1;
														// output.texCoord2 = input.texCoord2;
														// output.texCoord3 = input.texCoord3;
														// output.color = input.color;
														#if _DOUBLESIDED_ON && SHADER_STAGE_FRAGMENT
														output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);
														#elif SHADER_STAGE_FRAGMENT
														output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);
														#endif // SHADER_STAGE_FRAGMENT

														return output;
													}

													SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
													{
														SurfaceDescriptionInputs output;
														ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

														// output.WorldSpaceNormal =            normalize(input.tangentToWorld[2].xyz);
														// output.ObjectSpaceNormal =           mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M);           // transposed multiplication by inverse matrix to handle normal scale
														// output.ViewSpaceNormal =             mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_I_V);         // transposed multiplication by inverse matrix to handle normal scale
														// output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
														// output.WorldSpaceTangent =           input.tangentToWorld[0].xyz;
														// output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
														// output.ViewSpaceTangent =            TransformWorldToViewDir(output.WorldSpaceTangent);
														// output.TangentSpaceTangent =         float3(1.0f, 0.0f, 0.0f);
														// output.WorldSpaceBiTangent =         input.tangentToWorld[1].xyz;
														// output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
														// output.ViewSpaceBiTangent =          TransformWorldToViewDir(output.WorldSpaceBiTangent);
														// output.TangentSpaceBiTangent =       float3(0.0f, 1.0f, 0.0f);
														// output.WorldSpaceViewDirection =     normalize(viewWS);
														// output.ObjectSpaceViewDirection =    TransformWorldToObjectDir(output.WorldSpaceViewDirection);
														// output.ViewSpaceViewDirection =      TransformWorldToViewDir(output.WorldSpaceViewDirection);
														// float3x3 tangentSpaceTransform =     float3x3(output.WorldSpaceTangent,output.WorldSpaceBiTangent,output.WorldSpaceNormal);
														// output.TangentSpaceViewDirection =   mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
														// output.WorldSpacePosition =          GetAbsolutePositionWS(input.positionRWS);
														// output.ObjectSpacePosition =         TransformWorldToObject(input.positionRWS);
														// output.ViewSpacePosition =           TransformWorldToView(input.positionRWS);
														// output.TangentSpacePosition =        float3(0.0f, 0.0f, 0.0f);
														// output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionRWS), _ProjectionParams.x);
														// output.uv0 =                         input.texCoord0;
														// output.uv1 =                         input.texCoord1;
														// output.uv2 =                         input.texCoord2;
														// output.uv3 =                         input.texCoord3;
														// output.VertexColor =                 input.color;
														// output.FaceSign =                    input.isFrontFace;
														// output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value

														return output;
													}

													// existing HDRP code uses the combined function to go directly from packed to frag inputs
													FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
													{
														UNITY_SETUP_INSTANCE_ID(input);
														VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
														return BuildFragInputs(unpacked);
													}

													//-------------------------------------------------------------------------------------
													// END TEMPLATE INCLUDE : SharedCode.template.hlsl
													//-------------------------------------------------------------------------------------



														void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
														{
															// setup defaults -- these are used if the graph doesn't output a value
															ZERO_INITIALIZE(SurfaceData, surfaceData);
															surfaceData.ambientOcclusion = 1.0f;

															// copy across graph values, if defined
															// surfaceData.baseColor =             surfaceDescription.Albedo;
															// surfaceData.perceptualSmoothness =  surfaceDescription.Smoothness;
															// surfaceData.ambientOcclusion =      surfaceDescription.Occlusion;
															// surfaceData.metallic =              surfaceDescription.Metallic;
															// surfaceData.specularColor =         surfaceDescription.Specular;

															// These static material feature allow compile time optimization
															surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
													#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
															surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
													#endif

															float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
															// doubleSidedConstants = float3(-1.0, -1.0, -1.0);
															doubleSidedConstants = float3(1.0,  1.0, -1.0);

															// tangent-space normal
															float3 normalTS = float3(0.0f, 0.0f, 1.0f);
															// normalTS = surfaceDescription.Normal;

															// compute world space normal
															GetNormalWS(fragInputs, normalTS, surfaceData.normalWS, doubleSidedConstants);

															surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];

															surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);    // The tangent is not normalize in tangentToWorld for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
															surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);

															// By default we use the ambient occlusion with Tri-ace trick (apply outside) for specular occlusion.
															// If user provide bent normal then we process a better term
															surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));

													#if HAVE_DECALS
															if (_EnableDecals)
															{
																DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, surfaceDescription.Alpha);
																ApplyDecalToSurfaceData(decalSurfaceData, surfaceData);
															}
													#endif

													#ifdef DEBUG_DISPLAY
															if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
															{
																// TODO: need to update mip info
																surfaceData.metallic = 0;
															}

															// We need to call ApplyDebugToSurfaceData after filling the surfarcedata and before filling builtinData
															// as it can modify attribute use for static lighting
															ApplyDebugToSurfaceData(fragInputs.tangentToWorld, surfaceData);
													#endif
														}

														void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
														{
													#ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
															uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx)); // Quantize V to _ScreenSize values
															LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
													#endif

															float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
															// doubleSidedConstants = float3(-1.0, -1.0, -1.0);
															doubleSidedConstants = float3(1.0,  1.0, -1.0);

															ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants);

															SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
															SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);

															// Perform alpha test very early to save performance (a killed pixel will not sample textures)
															// TODO: split graph evaluation to grab just alpha dependencies first? tricky..
															// DoAlphaTest(surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold);

															BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);

															// Builtin Data
															// For back lighting we use the oposite vertex normal 
															InitBuiltinData(posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);

															// builtinData.emissiveColor = surfaceDescription.Emission;

															PostInitBuiltinData(V, posInput, surfaceData, builtinData);
														}

														//-------------------------------------------------------------------------------------
														// Pass Includes
														//-------------------------------------------------------------------------------------
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"
														//-------------------------------------------------------------------------------------
														// End Pass Includes
														//-------------------------------------------------------------------------------------

														ENDHLSL
													}

													Pass
													{
															// based on HDPBRPass.template
															Name "SceneSelectionPass"
															Tags { "LightMode" = "SceneSelectionPass" }

															//-------------------------------------------------------------------------------------
															// Render Modes (Blend, Cull, ZTest, Stencil, etc)
															//-------------------------------------------------------------------------------------






															ColorMask 0

															//-------------------------------------------------------------------------------------
															// End Render Modes
															//-------------------------------------------------------------------------------------

															HLSLPROGRAM

															#pragma target 4.5
															#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
															//#pragma enable_d3d11_debug_symbols

															#pragma multi_compile_instancing
															#pragma instancing_options renderinglayer
															#pragma multi_compile _ LOD_FADE_CROSSFADE

															//-------------------------------------------------------------------------------------
															// Variant Definitions (active field translations to HDRP defines)
															//-------------------------------------------------------------------------------------
															#define _MATERIAL_FEATURE_SPECULAR_COLOR 1
															#define _SURFACE_TYPE_TRANSPARENT 1
															#define _BLENDMODE_ALPHA 1
															// #define _BLENDMODE_ADD 1
															// #define _BLENDMODE_PRE_MULTIPLY 1
															#define _DOUBLESIDED_ON 1

															//-------------------------------------------------------------------------------------
															// End Variant Definitions
															//-------------------------------------------------------------------------------------

															#pragma vertex Vert
															#pragma fragment Frag

															#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

															#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"

															// define FragInputs structure
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"

															//-------------------------------------------------------------------------------------
															// Defines
															//-------------------------------------------------------------------------------------
																	#define SHADERPASS SHADERPASS_DEPTH_ONLY
																#define SCENESELECTIONPASS
																#pragma editor_sync_compilation
																// ACTIVE FIELDS:
																//   DoubleSided
																//   DoubleSided.Mirror
																//   FragInputs.isFrontFace
																//   Material.SpecularColor
																//   SurfaceType.Transparent
																//   BlendMode.Alpha
																//   AlphaFog
																//   SurfaceDescription.Alpha
																//   SurfaceDescription.AlphaClipThreshold
																//   VaryingsMeshToPS.cullFace

															// this translates the new dependency tracker into the old preprocessor definitions for the existing HDRP shader code
															// #define ATTRIBUTES_NEED_NORMAL
															// #define ATTRIBUTES_NEED_TANGENT
															// #define ATTRIBUTES_NEED_TEXCOORD0
															// #define ATTRIBUTES_NEED_TEXCOORD1
															// #define ATTRIBUTES_NEED_TEXCOORD2
															// #define ATTRIBUTES_NEED_TEXCOORD3
															// #define ATTRIBUTES_NEED_COLOR
															// #define VARYINGS_NEED_POSITION_WS
															// #define VARYINGS_NEED_TANGENT_TO_WORLD
															// #define VARYINGS_NEED_TEXCOORD0
															// #define VARYINGS_NEED_TEXCOORD1
															// #define VARYINGS_NEED_TEXCOORD2
															// #define VARYINGS_NEED_TEXCOORD3
															// #define VARYINGS_NEED_COLOR
															#define VARYINGS_NEED_CULLFACE
															// #define HAVE_MESH_MODIFICATION

															//-------------------------------------------------------------------------------------
															// End Defines
															//-------------------------------------------------------------------------------------

															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
															#ifdef DEBUG_DISPLAY
																#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
															#endif

															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"

														#if (SHADERPASS == SHADERPASS_FORWARD)
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"

															#define HAS_LIGHTLOOP

															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
														#else
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
														#endif

															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
															#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

															//Used by SceneSelectionPass
															int _ObjectId;
															int _PassValue;

															//-------------------------------------------------------------------------------------
															// Interpolator Packing And Struct Declarations
															//-------------------------------------------------------------------------------------
														// Generated Type: AttributesMesh
														struct AttributesMesh {
															float3 positionOS : POSITION;
															#if UNITY_ANY_INSTANCING_ENABLED
															uint instanceID : INSTANCEID_SEMANTIC;
															#endif // UNITY_ANY_INSTANCING_ENABLED
														};

														// Generated Type: VaryingsMeshToPS
														struct VaryingsMeshToPS {
															float4 positionCS : SV_Position;
															#if UNITY_ANY_INSTANCING_ENABLED
															uint instanceID : CUSTOM_INSTANCE_ID;
															#endif // UNITY_ANY_INSTANCING_ENABLED
															#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
															FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
															#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
														};
														struct PackedVaryingsMeshToPS {
															float4 positionCS : SV_Position; // unpacked
															#if UNITY_ANY_INSTANCING_ENABLED
															uint instanceID : CUSTOM_INSTANCE_ID; // unpacked
															#endif // UNITY_ANY_INSTANCING_ENABLED
															#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
															FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // unpacked
															#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
														};
														PackedVaryingsMeshToPS PackVaryingsMeshToPS(VaryingsMeshToPS input)
														{
															PackedVaryingsMeshToPS output;
															output.positionCS = input.positionCS;
															#if UNITY_ANY_INSTANCING_ENABLED
															output.instanceID = input.instanceID;
															#endif // UNITY_ANY_INSTANCING_ENABLED
															#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
															output.cullFace = input.cullFace;
															#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
															return output;
														}
														VaryingsMeshToPS UnpackVaryingsMeshToPS(PackedVaryingsMeshToPS input)
														{
															VaryingsMeshToPS output;
															output.positionCS = input.positionCS;
															#if UNITY_ANY_INSTANCING_ENABLED
															output.instanceID = input.instanceID;
															#endif // UNITY_ANY_INSTANCING_ENABLED
															#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
															output.cullFace = input.cullFace;
															#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
															return output;
														}

														// Generated Type: VaryingsMeshToDS
														struct VaryingsMeshToDS {
															float3 positionRWS;
															float3 normalWS;
															#if UNITY_ANY_INSTANCING_ENABLED
															uint instanceID : CUSTOM_INSTANCE_ID;
															#endif // UNITY_ANY_INSTANCING_ENABLED
														};
														struct PackedVaryingsMeshToDS {
															float3 interp00 : TEXCOORD0; // auto-packed
															float3 interp01 : TEXCOORD1; // auto-packed
															#if UNITY_ANY_INSTANCING_ENABLED
															uint instanceID : CUSTOM_INSTANCE_ID; // unpacked
															#endif // UNITY_ANY_INSTANCING_ENABLED
														};
														PackedVaryingsMeshToDS PackVaryingsMeshToDS(VaryingsMeshToDS input)
														{
															PackedVaryingsMeshToDS output;
															output.interp00.xyz = input.positionRWS;
															output.interp01.xyz = input.normalWS;
															#if UNITY_ANY_INSTANCING_ENABLED
															output.instanceID = input.instanceID;
															#endif // UNITY_ANY_INSTANCING_ENABLED
															return output;
														}
														VaryingsMeshToDS UnpackVaryingsMeshToDS(PackedVaryingsMeshToDS input)
														{
															VaryingsMeshToDS output;
															output.positionRWS = input.interp00.xyz;
															output.normalWS = input.interp01.xyz;
															#if UNITY_ANY_INSTANCING_ENABLED
															output.instanceID = input.instanceID;
															#endif // UNITY_ANY_INSTANCING_ENABLED
															return output;
														}

														//-------------------------------------------------------------------------------------
														// End Interpolator Packing And Struct Declarations
														//-------------------------------------------------------------------------------------

														//-------------------------------------------------------------------------------------
														// Graph generated code
														//-------------------------------------------------------------------------------------
																// Shared Graph Properties (uniform inputs)
																CBUFFER_START(UnityPerMaterial)
																CBUFFER_END

																TEXTURE2D(Texture2D_E4969401); SAMPLER(samplerTexture2D_E4969401); float4 Texture2D_E4969401_TexelSize;
																TEXTURE2D(Texture2D_2C8B3EAF); SAMPLER(samplerTexture2D_2C8B3EAF); float4 Texture2D_2C8B3EAF_TexelSize;

																// Pixel Graph Inputs
																	struct SurfaceDescriptionInputs {
																	};
																	// Pixel Graph Outputs
																		struct SurfaceDescription
																		{
																			float Alpha;
																			float AlphaClipThreshold;
																		};

																		// Shared Graph Node Functions
																		// Pixel Graph Evaluation
																			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
																			{
																				SurfaceDescription surface = (SurfaceDescription)0;
																				surface.Alpha = 1;
																				surface.AlphaClipThreshold = 0;
																				return surface;
																			}

																			//-------------------------------------------------------------------------------------
																			// End graph generated code
																			//-------------------------------------------------------------------------------------

																		// $include("VertexAnimation.template.hlsl")


																		//-------------------------------------------------------------------------------------
																		// TEMPLATE INCLUDE : SharedCode.template.hlsl
																		//-------------------------------------------------------------------------------------
																			FragInputs BuildFragInputs(VaryingsMeshToPS input)
																			{
																				FragInputs output;
																				ZERO_INITIALIZE(FragInputs, output);

																				// Init to some default value to make the computer quiet (else it output 'divide by zero' warning even if value is not used).
																				// TODO: this is a really poor workaround, but the variable is used in a bunch of places
																				// to compute normals which are then passed on elsewhere to compute other values...
																				output.tangentToWorld = k_identity3x3;
																				output.positionSS = input.positionCS;       // input.positionCS is SV_Position

																				// output.positionRWS = input.positionRWS;
																				// output.tangentToWorld = BuildTangentToWorld(input.tangentWS, input.normalWS);
																				// output.texCoord0 = input.texCoord0;
																				// output.texCoord1 = input.texCoord1;
																				// output.texCoord2 = input.texCoord2;
																				// output.texCoord3 = input.texCoord3;
																				// output.color = input.color;
																				#if _DOUBLESIDED_ON && SHADER_STAGE_FRAGMENT
																				output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);
																				#elif SHADER_STAGE_FRAGMENT
																				output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);
																				#endif // SHADER_STAGE_FRAGMENT

																				return output;
																			}

																			SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
																			{
																				SurfaceDescriptionInputs output;
																				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

																				// output.WorldSpaceNormal =            normalize(input.tangentToWorld[2].xyz);
																				// output.ObjectSpaceNormal =           mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M);           // transposed multiplication by inverse matrix to handle normal scale
																				// output.ViewSpaceNormal =             mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_I_V);         // transposed multiplication by inverse matrix to handle normal scale
																				// output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
																				// output.WorldSpaceTangent =           input.tangentToWorld[0].xyz;
																				// output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
																				// output.ViewSpaceTangent =            TransformWorldToViewDir(output.WorldSpaceTangent);
																				// output.TangentSpaceTangent =         float3(1.0f, 0.0f, 0.0f);
																				// output.WorldSpaceBiTangent =         input.tangentToWorld[1].xyz;
																				// output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
																				// output.ViewSpaceBiTangent =          TransformWorldToViewDir(output.WorldSpaceBiTangent);
																				// output.TangentSpaceBiTangent =       float3(0.0f, 1.0f, 0.0f);
																				// output.WorldSpaceViewDirection =     normalize(viewWS);
																				// output.ObjectSpaceViewDirection =    TransformWorldToObjectDir(output.WorldSpaceViewDirection);
																				// output.ViewSpaceViewDirection =      TransformWorldToViewDir(output.WorldSpaceViewDirection);
																				// float3x3 tangentSpaceTransform =     float3x3(output.WorldSpaceTangent,output.WorldSpaceBiTangent,output.WorldSpaceNormal);
																				// output.TangentSpaceViewDirection =   mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
																				// output.WorldSpacePosition =          GetAbsolutePositionWS(input.positionRWS);
																				// output.ObjectSpacePosition =         TransformWorldToObject(input.positionRWS);
																				// output.ViewSpacePosition =           TransformWorldToView(input.positionRWS);
																				// output.TangentSpacePosition =        float3(0.0f, 0.0f, 0.0f);
																				// output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionRWS), _ProjectionParams.x);
																				// output.uv0 =                         input.texCoord0;
																				// output.uv1 =                         input.texCoord1;
																				// output.uv2 =                         input.texCoord2;
																				// output.uv3 =                         input.texCoord3;
																				// output.VertexColor =                 input.color;
																				// output.FaceSign =                    input.isFrontFace;
																				// output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value

																				return output;
																			}

																			// existing HDRP code uses the combined function to go directly from packed to frag inputs
																			FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
																			{
																				UNITY_SETUP_INSTANCE_ID(input);
																				VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
																				return BuildFragInputs(unpacked);
																			}

																			//-------------------------------------------------------------------------------------
																			// END TEMPLATE INCLUDE : SharedCode.template.hlsl
																			//-------------------------------------------------------------------------------------



																				void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
																				{
																					// setup defaults -- these are used if the graph doesn't output a value
																					ZERO_INITIALIZE(SurfaceData, surfaceData);
																					surfaceData.ambientOcclusion = 1.0f;

																					// copy across graph values, if defined
																					// surfaceData.baseColor =             surfaceDescription.Albedo;
																					// surfaceData.perceptualSmoothness =  surfaceDescription.Smoothness;
																					// surfaceData.ambientOcclusion =      surfaceDescription.Occlusion;
																					// surfaceData.metallic =              surfaceDescription.Metallic;
																					// surfaceData.specularColor =         surfaceDescription.Specular;

																					// These static material feature allow compile time optimization
																					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
																			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
																					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
																			#endif

																					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
																					// doubleSidedConstants = float3(-1.0, -1.0, -1.0);
																					doubleSidedConstants = float3(1.0,  1.0, -1.0);

																					// tangent-space normal
																					float3 normalTS = float3(0.0f, 0.0f, 1.0f);
																					// normalTS = surfaceDescription.Normal;

																					// compute world space normal
																					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS, doubleSidedConstants);

																					surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];

																					surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);    // The tangent is not normalize in tangentToWorld for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
																					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);

																					// By default we use the ambient occlusion with Tri-ace trick (apply outside) for specular occlusion.
																					// If user provide bent normal then we process a better term
																					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));

																			#if HAVE_DECALS
																					if (_EnableDecals)
																					{
																						DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, surfaceDescription.Alpha);
																						ApplyDecalToSurfaceData(decalSurfaceData, surfaceData);
																					}
																			#endif

																			#ifdef DEBUG_DISPLAY
																					if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
																					{
																						// TODO: need to update mip info
																						surfaceData.metallic = 0;
																					}

																					// We need to call ApplyDebugToSurfaceData after filling the surfarcedata and before filling builtinData
																					// as it can modify attribute use for static lighting
																					ApplyDebugToSurfaceData(fragInputs.tangentToWorld, surfaceData);
																			#endif
																				}

																				void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
																				{
																			#ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
																					uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx)); // Quantize V to _ScreenSize values
																					LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
																			#endif

																					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
																					// doubleSidedConstants = float3(-1.0, -1.0, -1.0);
																					doubleSidedConstants = float3(1.0,  1.0, -1.0);

																					ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants);

																					SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
																					SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);

																					// Perform alpha test very early to save performance (a killed pixel will not sample textures)
																					// TODO: split graph evaluation to grab just alpha dependencies first? tricky..
																					// DoAlphaTest(surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold);

																					BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);

																					// Builtin Data
																					// For back lighting we use the oposite vertex normal 
																					InitBuiltinData(posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);

																					// builtinData.emissiveColor = surfaceDescription.Emission;

																					PostInitBuiltinData(V, posInput, surfaceData, builtinData);
																				}

																				//-------------------------------------------------------------------------------------
																				// Pass Includes
																				//-------------------------------------------------------------------------------------
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"
																				//-------------------------------------------------------------------------------------
																				// End Pass Includes
																				//-------------------------------------------------------------------------------------

																				ENDHLSL
																			}

																			Pass
																			{
																					// based on HDPBRPass.template
																					Name "Forward"
																					Tags { "LightMode" = "Forward" }

																					//-------------------------------------------------------------------------------------
																					// Render Modes (Blend, Cull, ZTest, Stencil, etc)
																					//-------------------------------------------------------------------------------------





																					// Stencil setup
																				Stencil
																				{
																				   WriteMask 3
																				   Ref  2
																				   Comp Always
																				   Pass Replace
																				}


																					//-------------------------------------------------------------------------------------
																					// End Render Modes
																					//-------------------------------------------------------------------------------------

																					HLSLPROGRAM

																					#pragma target 4.5
																					#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
																					//#pragma enable_d3d11_debug_symbols

																					#pragma multi_compile_instancing
																					#pragma instancing_options renderinglayer
																					#pragma multi_compile _ LOD_FADE_CROSSFADE

																					//-------------------------------------------------------------------------------------
																					// Variant Definitions (active field translations to HDRP defines)
																					//-------------------------------------------------------------------------------------
																					#define _MATERIAL_FEATURE_SPECULAR_COLOR 1
																					#define _SURFACE_TYPE_TRANSPARENT 1
																					#define _BLENDMODE_ALPHA 1
																					// #define _BLENDMODE_ADD 1
																					// #define _BLENDMODE_PRE_MULTIPLY 1
																					#define _DOUBLESIDED_ON 1

																					//-------------------------------------------------------------------------------------
																					// End Variant Definitions
																					//-------------------------------------------------------------------------------------

																					#pragma vertex Vert
																					#pragma fragment Frag

																					#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

																					#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"

																					// define FragInputs structure
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"

																					//-------------------------------------------------------------------------------------
																					// Defines
																					//-------------------------------------------------------------------------------------
																							#define SHADERPASS SHADERPASS_FORWARD
																						#pragma multi_compile _ DEBUG_DISPLAY
																						#pragma multi_compile _ LIGHTMAP_ON
																						#pragma multi_compile _ DIRLIGHTMAP_COMBINED
																						#pragma multi_compile _ DYNAMICLIGHTMAP_ON
																						#pragma multi_compile _ SHADOWS_SHADOWMASK
																						#pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
																						#define USE_CLUSTERED_LIGHTLIST
																						#pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH SHADOW_VERY_HIGH
																						// ACTIVE FIELDS:
																						//   DoubleSided
																						//   DoubleSided.Mirror
																						//   FragInputs.isFrontFace
																						//   Material.SpecularColor
																						//   SurfaceType.Transparent
																						//   BlendMode.Alpha
																						//   AlphaFog
																						//   SurfaceDescriptionInputs.uv0
																						//   SurfaceDescription.Albedo
																						//   SurfaceDescription.Normal
																						//   SurfaceDescription.Specular
																						//   SurfaceDescription.Emission
																						//   SurfaceDescription.Smoothness
																						//   SurfaceDescription.Occlusion
																						//   SurfaceDescription.Alpha
																						//   SurfaceDescription.AlphaClipThreshold
																						//   FragInputs.tangentToWorld
																						//   FragInputs.positionRWS
																						//   FragInputs.texCoord1
																						//   FragInputs.texCoord2
																						//   VaryingsMeshToPS.cullFace
																						//   FragInputs.texCoord0
																						//   VaryingsMeshToPS.tangentWS
																						//   VaryingsMeshToPS.normalWS
																						//   VaryingsMeshToPS.positionRWS
																						//   VaryingsMeshToPS.texCoord1
																						//   VaryingsMeshToPS.texCoord2
																						//   VaryingsMeshToPS.texCoord0
																						//   AttributesMesh.tangentOS
																						//   AttributesMesh.normalOS
																						//   AttributesMesh.positionOS
																						//   AttributesMesh.uv1
																						//   AttributesMesh.uv2
																						//   AttributesMesh.uv0

																					// this translates the new dependency tracker into the old preprocessor definitions for the existing HDRP shader code
																					#define ATTRIBUTES_NEED_NORMAL
																					#define ATTRIBUTES_NEED_TANGENT
																					#define ATTRIBUTES_NEED_TEXCOORD0
																					#define ATTRIBUTES_NEED_TEXCOORD1
																					#define ATTRIBUTES_NEED_TEXCOORD2
																					// #define ATTRIBUTES_NEED_TEXCOORD3
																					// #define ATTRIBUTES_NEED_COLOR
																					#define VARYINGS_NEED_POSITION_WS
																					#define VARYINGS_NEED_TANGENT_TO_WORLD
																					#define VARYINGS_NEED_TEXCOORD0
																					#define VARYINGS_NEED_TEXCOORD1
																					#define VARYINGS_NEED_TEXCOORD2
																					// #define VARYINGS_NEED_TEXCOORD3
																					// #define VARYINGS_NEED_COLOR
																					#define VARYINGS_NEED_CULLFACE
																					// #define HAVE_MESH_MODIFICATION

																					//-------------------------------------------------------------------------------------
																					// End Defines
																					//-------------------------------------------------------------------------------------

																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
																					#ifdef DEBUG_DISPLAY
																						#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
																					#endif

																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"

																				#if (SHADERPASS == SHADERPASS_FORWARD)
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"

																					#define HAS_LIGHTLOOP

																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
																				#else
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
																				#endif

																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
																					#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

																					//Used by SceneSelectionPass
																					int _ObjectId;
																					int _PassValue;

																					//-------------------------------------------------------------------------------------
																					// Interpolator Packing And Struct Declarations
																					//-------------------------------------------------------------------------------------
																				// Generated Type: AttributesMesh
																				struct AttributesMesh {
																					float3 positionOS : POSITION;
																					float3 normalOS : NORMAL; // optional
																					float4 tangentOS : TANGENT; // optional
																					float4 uv0 : TEXCOORD0; // optional
																					float4 uv1 : TEXCOORD1; // optional
																					float4 uv2 : TEXCOORD2; // optional
																					#if UNITY_ANY_INSTANCING_ENABLED
																					uint instanceID : INSTANCEID_SEMANTIC;
																					#endif // UNITY_ANY_INSTANCING_ENABLED
																				};

																				// Generated Type: VaryingsMeshToPS
																				struct VaryingsMeshToPS {
																					float4 positionCS : SV_Position;
																					float3 positionRWS; // optional
																					float3 normalWS; // optional
																					float4 tangentWS; // optional
																					float4 texCoord0; // optional
																					float4 texCoord1; // optional
																					float4 texCoord2; // optional
																					#if UNITY_ANY_INSTANCING_ENABLED
																					uint instanceID : CUSTOM_INSTANCE_ID;
																					#endif // UNITY_ANY_INSTANCING_ENABLED
																					#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
																					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
																					#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
																				};
																				struct PackedVaryingsMeshToPS {
																					float3 interp00 : TEXCOORD0; // auto-packed
																					float3 interp01 : TEXCOORD1; // auto-packed
																					float4 interp02 : TEXCOORD2; // auto-packed
																					float4 interp03 : TEXCOORD3; // auto-packed
																					float4 interp04 : TEXCOORD4; // auto-packed
																					float4 interp05 : TEXCOORD5; // auto-packed
																					float4 positionCS : SV_Position; // unpacked
																					#if UNITY_ANY_INSTANCING_ENABLED
																					uint instanceID : CUSTOM_INSTANCE_ID; // unpacked
																					#endif // UNITY_ANY_INSTANCING_ENABLED
																					#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
																					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // unpacked
																					#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
																				};
																				PackedVaryingsMeshToPS PackVaryingsMeshToPS(VaryingsMeshToPS input)
																				{
																					PackedVaryingsMeshToPS output;
																					output.positionCS = input.positionCS;
																					output.interp00.xyz = input.positionRWS;
																					output.interp01.xyz = input.normalWS;
																					output.interp02.xyzw = input.tangentWS;
																					output.interp03.xyzw = input.texCoord0;
																					output.interp04.xyzw = input.texCoord1;
																					output.interp05.xyzw = input.texCoord2;
																					#if UNITY_ANY_INSTANCING_ENABLED
																					output.instanceID = input.instanceID;
																					#endif // UNITY_ANY_INSTANCING_ENABLED
																					#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
																					output.cullFace = input.cullFace;
																					#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
																					return output;
																				}
																				VaryingsMeshToPS UnpackVaryingsMeshToPS(PackedVaryingsMeshToPS input)
																				{
																					VaryingsMeshToPS output;
																					output.positionCS = input.positionCS;
																					output.positionRWS = input.interp00.xyz;
																					output.normalWS = input.interp01.xyz;
																					output.tangentWS = input.interp02.xyzw;
																					output.texCoord0 = input.interp03.xyzw;
																					output.texCoord1 = input.interp04.xyzw;
																					output.texCoord2 = input.interp05.xyzw;
																					#if UNITY_ANY_INSTANCING_ENABLED
																					output.instanceID = input.instanceID;
																					#endif // UNITY_ANY_INSTANCING_ENABLED
																					#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
																					output.cullFace = input.cullFace;
																					#endif // defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
																					return output;
																				}

																				// Generated Type: VaryingsMeshToDS
																				struct VaryingsMeshToDS {
																					float3 positionRWS;
																					float3 normalWS;
																					#if UNITY_ANY_INSTANCING_ENABLED
																					uint instanceID : CUSTOM_INSTANCE_ID;
																					#endif // UNITY_ANY_INSTANCING_ENABLED
																				};
																				struct PackedVaryingsMeshToDS {
																					float3 interp00 : TEXCOORD0; // auto-packed
																					float3 interp01 : TEXCOORD1; // auto-packed
																					#if UNITY_ANY_INSTANCING_ENABLED
																					uint instanceID : CUSTOM_INSTANCE_ID; // unpacked
																					#endif // UNITY_ANY_INSTANCING_ENABLED
																				};
																				PackedVaryingsMeshToDS PackVaryingsMeshToDS(VaryingsMeshToDS input)
																				{
																					PackedVaryingsMeshToDS output;
																					output.interp00.xyz = input.positionRWS;
																					output.interp01.xyz = input.normalWS;
																					#if UNITY_ANY_INSTANCING_ENABLED
																					output.instanceID = input.instanceID;
																					#endif // UNITY_ANY_INSTANCING_ENABLED
																					return output;
																				}
																				VaryingsMeshToDS UnpackVaryingsMeshToDS(PackedVaryingsMeshToDS input)
																				{
																					VaryingsMeshToDS output;
																					output.positionRWS = input.interp00.xyz;
																					output.normalWS = input.interp01.xyz;
																					#if UNITY_ANY_INSTANCING_ENABLED
																					output.instanceID = input.instanceID;
																					#endif // UNITY_ANY_INSTANCING_ENABLED
																					return output;
																				}

																				//-------------------------------------------------------------------------------------
																				// End Interpolator Packing And Struct Declarations
																				//-------------------------------------------------------------------------------------

																				//-------------------------------------------------------------------------------------
																				// Graph generated code
																				//-------------------------------------------------------------------------------------
																						// Shared Graph Properties (uniform inputs)
																						CBUFFER_START(UnityPerMaterial)
																						CBUFFER_END

																						TEXTURE2D(Texture2D_E4969401); SAMPLER(samplerTexture2D_E4969401); float4 Texture2D_E4969401_TexelSize;
																						TEXTURE2D(Texture2D_2C8B3EAF); SAMPLER(samplerTexture2D_2C8B3EAF); float4 Texture2D_2C8B3EAF_TexelSize;
																						SAMPLER(_NormalFromTexture_46C3DE9D_Sampler_2_Linear_Repeat);
																						SAMPLER(_SampleTexture2D_DCD952C4_Sampler_3_Linear_Repeat);

																						// Pixel Graph Inputs
																							struct SurfaceDescriptionInputs {
																								float4 uv0; // optional
																							};
																							// Pixel Graph Outputs
																								struct SurfaceDescription
																								{
																									float3 Albedo;
																									float3 Normal;
																									float3 Specular;
																									float3 Emission;
																									float Smoothness;
																									float Occlusion;
																									float Alpha;
																									float AlphaClipThreshold;
																								};

																								// Shared Graph Node Functions

																									void Unity_NormalFromTexture_float(Texture2D Texture, SamplerState Sampler, float2 UV, float Offset, float Strength, out float3 Out)
																									{
																										Offset = pow(Offset, 3) * 0.1;
																										float2 offsetU = float2(UV.x + Offset, UV.y);
																										float2 offsetV = float2(UV.x, UV.y + Offset);
																										float normalSample = Texture.Sample(Sampler, UV);
																										float uSample = Texture.Sample(Sampler, offsetU);
																										float vSample = Texture.Sample(Sampler, offsetV);
																										float3 va = float3(1, 0, (uSample - normalSample) * Strength);
																										float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
																										Out = normalize(cross(va, vb));
																									}

																									// Pixel Graph Evaluation
																										SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
																										{
																											SurfaceDescription surface = (SurfaceDescription)0;
																											float3 _NormalFromTexture_46C3DE9D_Out_5;
																											Unity_NormalFromTexture_float(Texture2D_2C8B3EAF, samplerTexture2D_2C8B3EAF, IN.uv0.xy, 0.5, 8, _NormalFromTexture_46C3DE9D_Out_5);
																											float4 _SampleTexture2D_DCD952C4_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_E4969401, samplerTexture2D_E4969401, IN.uv0.xy);
																											float _SampleTexture2D_DCD952C4_R_4 = _SampleTexture2D_DCD952C4_RGBA_0.r;
																											float _SampleTexture2D_DCD952C4_G_5 = _SampleTexture2D_DCD952C4_RGBA_0.g;
																											float _SampleTexture2D_DCD952C4_B_6 = _SampleTexture2D_DCD952C4_RGBA_0.b;
																											float _SampleTexture2D_DCD952C4_A_7 = _SampleTexture2D_DCD952C4_RGBA_0.a;
																											surface.Albedo = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
																											surface.Normal = _NormalFromTexture_46C3DE9D_Out_5;
																											surface.Specular = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
																											surface.Emission = (_SampleTexture2D_DCD952C4_RGBA_0.xyz);
																											surface.Smoothness = 0;
																											surface.Occlusion = 1;
																											surface.Alpha = 1;
																											surface.AlphaClipThreshold = 0;
																											return surface;
																										}

																										//-------------------------------------------------------------------------------------
																										// End graph generated code
																										//-------------------------------------------------------------------------------------

																									// $include("VertexAnimation.template.hlsl")


																									//-------------------------------------------------------------------------------------
																									// TEMPLATE INCLUDE : SharedCode.template.hlsl
																									//-------------------------------------------------------------------------------------
																										FragInputs BuildFragInputs(VaryingsMeshToPS input)
																										{
																											FragInputs output;
																											ZERO_INITIALIZE(FragInputs, output);

																											// Init to some default value to make the computer quiet (else it output 'divide by zero' warning even if value is not used).
																											// TODO: this is a really poor workaround, but the variable is used in a bunch of places
																											// to compute normals which are then passed on elsewhere to compute other values...
																											output.tangentToWorld = k_identity3x3;
																											output.positionSS = input.positionCS;       // input.positionCS is SV_Position

																											output.positionRWS = input.positionRWS;
																											output.tangentToWorld = BuildTangentToWorld(input.tangentWS, input.normalWS);
																											output.texCoord0 = input.texCoord0;
																											output.texCoord1 = input.texCoord1;
																											output.texCoord2 = input.texCoord2;
																											// output.texCoord3 = input.texCoord3;
																											// output.color = input.color;
																											#if _DOUBLESIDED_ON && SHADER_STAGE_FRAGMENT
																											output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);
																											#elif SHADER_STAGE_FRAGMENT
																											output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);
																											#endif // SHADER_STAGE_FRAGMENT

																											return output;
																										}

																										SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
																										{
																											SurfaceDescriptionInputs output;
																											ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

																											// output.WorldSpaceNormal =            normalize(input.tangentToWorld[2].xyz);
																											// output.ObjectSpaceNormal =           mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M);           // transposed multiplication by inverse matrix to handle normal scale
																											// output.ViewSpaceNormal =             mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_I_V);         // transposed multiplication by inverse matrix to handle normal scale
																											// output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
																											// output.WorldSpaceTangent =           input.tangentToWorld[0].xyz;
																											// output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
																											// output.ViewSpaceTangent =            TransformWorldToViewDir(output.WorldSpaceTangent);
																											// output.TangentSpaceTangent =         float3(1.0f, 0.0f, 0.0f);
																											// output.WorldSpaceBiTangent =         input.tangentToWorld[1].xyz;
																											// output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
																											// output.ViewSpaceBiTangent =          TransformWorldToViewDir(output.WorldSpaceBiTangent);
																											// output.TangentSpaceBiTangent =       float3(0.0f, 1.0f, 0.0f);
																											// output.WorldSpaceViewDirection =     normalize(viewWS);
																											// output.ObjectSpaceViewDirection =    TransformWorldToObjectDir(output.WorldSpaceViewDirection);
																											// output.ViewSpaceViewDirection =      TransformWorldToViewDir(output.WorldSpaceViewDirection);
																											// float3x3 tangentSpaceTransform =     float3x3(output.WorldSpaceTangent,output.WorldSpaceBiTangent,output.WorldSpaceNormal);
																											// output.TangentSpaceViewDirection =   mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
																											// output.WorldSpacePosition =          GetAbsolutePositionWS(input.positionRWS);
																											// output.ObjectSpacePosition =         TransformWorldToObject(input.positionRWS);
																											// output.ViewSpacePosition =           TransformWorldToView(input.positionRWS);
																											// output.TangentSpacePosition =        float3(0.0f, 0.0f, 0.0f);
																											// output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionRWS), _ProjectionParams.x);
																											output.uv0 = input.texCoord0;
																											// output.uv1 =                         input.texCoord1;
																											// output.uv2 =                         input.texCoord2;
																											// output.uv3 =                         input.texCoord3;
																											// output.VertexColor =                 input.color;
																											// output.FaceSign =                    input.isFrontFace;
																											// output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value

																											return output;
																										}

																										// existing HDRP code uses the combined function to go directly from packed to frag inputs
																										FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
																										{
																											UNITY_SETUP_INSTANCE_ID(input);
																											VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
																											return BuildFragInputs(unpacked);
																										}

																										//-------------------------------------------------------------------------------------
																										// END TEMPLATE INCLUDE : SharedCode.template.hlsl
																										//-------------------------------------------------------------------------------------



																											void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
																											{
																												// setup defaults -- these are used if the graph doesn't output a value
																												ZERO_INITIALIZE(SurfaceData, surfaceData);
																												surfaceData.ambientOcclusion = 1.0f;

																												// copy across graph values, if defined
																												surfaceData.baseColor = surfaceDescription.Albedo;
																												surfaceData.perceptualSmoothness = surfaceDescription.Smoothness;
																												surfaceData.ambientOcclusion = surfaceDescription.Occlusion;
																												// surfaceData.metallic =              surfaceDescription.Metallic;
																												surfaceData.specularColor = surfaceDescription.Specular;

																												// These static material feature allow compile time optimization
																												surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
																										#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
																												surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
																										#endif

																												float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
																												// doubleSidedConstants = float3(-1.0, -1.0, -1.0);
																												doubleSidedConstants = float3(1.0,  1.0, -1.0);

																												// tangent-space normal
																												float3 normalTS = float3(0.0f, 0.0f, 1.0f);
																												normalTS = surfaceDescription.Normal;

																												// compute world space normal
																												GetNormalWS(fragInputs, normalTS, surfaceData.normalWS, doubleSidedConstants);

																												surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];

																												surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);    // The tangent is not normalize in tangentToWorld for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
																												surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);

																												// By default we use the ambient occlusion with Tri-ace trick (apply outside) for specular occlusion.
																												// If user provide bent normal then we process a better term
																												surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));

																										#if HAVE_DECALS
																												if (_EnableDecals)
																												{
																													DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, surfaceDescription.Alpha);
																													ApplyDecalToSurfaceData(decalSurfaceData, surfaceData);
																												}
																										#endif

																										#ifdef DEBUG_DISPLAY
																												if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
																												{
																													// TODO: need to update mip info
																													surfaceData.metallic = 0;
																												}

																												// We need to call ApplyDebugToSurfaceData after filling the surfarcedata and before filling builtinData
																												// as it can modify attribute use for static lighting
																												ApplyDebugToSurfaceData(fragInputs.tangentToWorld, surfaceData);
																										#endif
																											}

																											void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
																											{
																										#ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
																												uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx)); // Quantize V to _ScreenSize values
																												LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
																										#endif

																												float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
																												// doubleSidedConstants = float3(-1.0, -1.0, -1.0);
																												doubleSidedConstants = float3(1.0,  1.0, -1.0);

																												ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants);

																												SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
																												SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);

																												// Perform alpha test very early to save performance (a killed pixel will not sample textures)
																												// TODO: split graph evaluation to grab just alpha dependencies first? tricky..
																												// DoAlphaTest(surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold);

																												BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);

																												// Builtin Data
																												// For back lighting we use the oposite vertex normal 
																												InitBuiltinData(posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);

																												builtinData.emissiveColor = surfaceDescription.Emission;

																												PostInitBuiltinData(V, posInput, surfaceData, builtinData);
																											}

																											//-------------------------------------------------------------------------------------
																											// Pass Includes
																											//-------------------------------------------------------------------------------------
																												#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForward.hlsl"
																											//-------------------------------------------------------------------------------------
																											// End Pass Includes
																											//-------------------------------------------------------------------------------------

																											ENDHLSL
																										}

	}
		CustomEditor "UnityEditor.Experimental.Rendering.HDPipeline.HDPBRLitGUI"
																												FallBack "Hidden/InternalErrorShader"
}
