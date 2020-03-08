
Shader "Custom/WaterShader4"
{
    Properties
	{
		[Header(Common)]
		_TessFactor("TessFactor", Vector) = (1, 1, 1, 1)

		_WaveTimeSpeed("Wave Time Speed", Range(0, 2)) = 1.0	// 波の更新速度

		[Header(WaterColor)]
		_WaterBaseColor("Water Base Color", Color) = (255, 255, 255, 255)			// 基本カラー
		_WaterShallowColor("Water Shallow Color", Color) = (255, 255, 255, 255)		// 浅瀬カラー
		_WaterBaseColorStrength("Water Base Color Strength", Range(0, 1)) = 1		// 基本カラーの強度(基本カラーの影響度 0なら基本カラーの影響はなし 1なら丸々影響を受ける)
		_WaterHeightColorCoef("Water Height Color Coef", Range(0, 1)) = 0.1			// 浅瀬カラー係数(数値が高いほど深い箇所も浅瀬カラーの影響を受ける)
 
		// ゲルストナー波 パラメータ
		[Header(GerstnerWave01)]
		_Amplitude ("Amplitude", Vector) = (0.7, 0.8, 0.65, 0.25)	// 振幅(波の高さ0から波頂までの高さ 例を出すとsin波は振幅1)
		_Frequency ("Frequency", Vector) = (0.16, 0.18, 0.2, 0.27)	// 波の周期
		_Steepness ("Steepness", Vector) = (1.70, 1.60, 1.2, 1.8)	// 
		_Speed ("Speed", Vector) = (25, 40, 45, 60)					// 波の速度
		_DirectionA ("Wave A(X,Y) Wave B(Z,W)", Vector) = (0.35, 0.31, 0.08, 0.6)	// 波の向き A B
		_DirectionB ("Wave C(X,Y) Wave D(Z,W)", Vector) = (-0.95, -0.74, 0.7, -0.5) // 波の向き C D

		_Noise ("Noise", Vector) = (0.39, 0.31, 0.27, 0.57)	// ノイズ値
 
		[Header(GerstnerWave02)]
		_Amplitude2 ("Amplitude", Vector) = (0.17, 0.12, 0.21, 0.06)	// 振幅(波の高さ0から波頂までの高さ 例を出すとsin波は振幅1)
		_Frequency2 ("Frequency", Vector) = (0.7, 0.84, 0.54, 0.80)		// 波の周期
		_Steepness2 ("Steepness", Vector) = (1.55, 2.18, 2.8, 1.9)		// 
		_Speed2 ("Speed", Vector) = (32, 40, 48, 60)					// 波の速度
		_DirectionC ("Wave A(X,Y) Wave B(Z,W)", Vector) = (0.7, 0.6, 0.1, 0.38)		// 波の向き A B
		_DirectionD ("Wave C(X,Y) Wave D(Z,W)", Vector) = (0.43, 0.07, 0.42, 0.61)	// 波の向き C D

		_Noise2 ("Noise", Vector) = (0.33, 0.81, 0.39, 0.45)	// ノイズ値

		[Header(NoiseParameter)]
		_NoiseSizeLerp("Noise Size", Range(0, 1)) = 0.5
		_NoiseStrength("Noise Strength", Range(0, 3)) = 1.5
	}

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
 
        Pass
        {
            CGPROGRAM
            #pragma vertex VS
			#pragma hull HSMain
			#pragma domain DS
            #pragma fragment FS
			#define PATCH_SIZE 3
			
            #include "UnityCG.cginc"
			#include "Water.cginc"
 
            struct appdata
            {
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
            };
 
            struct vs_output
            {
				float4 pos : POS;
				float2 uv : TEXCOORD0;
            };
			
			struct hs_const
			{
				float tessFactor[3] : SV_TessFactor;
				float insideTessFactor : SV_InsideTessFactor;
			};

			struct hs_main
			{
				float3 pos : POS;
                float2 uv : TEXCOORD0;
            };

            struct ds_output
            {
				float4 pos : SV_Position;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _TessFactor;
			float4 _LightColor0;
 
			static const int sub_wave_num = 4;
			static const int wave_num = 8;
 
			// 頂点シェーダー
            vs_output VS (appdata i)
            {
                vs_output o;
				
				o.pos = i.pos;
				o.uv = i.uv;

                return o;
            }
			
			// ハルシェーダーパッチ定数設定
			hs_const HSConst(InputPatch<vs_output, PATCH_SIZE> i)
			{
				hs_const o;
				o.tessFactor[0] = _TessFactor.x;
				o.tessFactor[1] = _TessFactor.y;
				o.tessFactor[2] = _TessFactor.z;
				o.insideTessFactor = _TessFactor.w;
				return o;
			}

			// ハルシェーダーコントロールポイント制御
			[domain("tri")]
			[partitioning("integer")]
			[outputtopology("triangle_cw")]
			[outputcontrolpoints(PATCH_SIZE)]
			[patchconstantfunc("HSConst")]
			hs_main HSMain(InputPatch<vs_output, PATCH_SIZE> i, uint id:SV_OutputControlPointID)
			{
				hs_main o;
				o.pos = i[id].pos;
				o.uv = i[id].uv;
				return o;
			}

			// ドメインシェーダー
			[domain("tri")]
			ds_output DS(hs_const hs_const_data, const OutputPatch<hs_main, PATCH_SIZE> i, float3 bary : SV_DomainLocation)
			{
				ds_output o;
				
				float3 pos = i[0].pos * bary.x + i[1].pos * bary.y + i[2].pos * bary.z;
				float2 uv = i[0].uv * bary.x + i[1].uv * bary.y + i[2].uv * bary.z;

				float4 worldPos = mul(unity_ObjectToWorld, float4(pos, 1));
				o.worldPos = worldPos.xyz;
 
				// @todo 時間計算は外でしたい
				float time = _Time.x * _WaveTimeSpeed;
 
				// --------------------
				// 頂点計算
				// --------------------
				float3 p = 0.0;
				for (int n = 0; n < sub_wave_num; n++)
				{
					p += GerstnerWave(amplitude[n], frequency[n], steepness[n], speed[n], dir[n], noiseSize[n], worldPos.xz, time, n);
				}

				for (int n2 = sub_wave_num; n2 < wave_num; n2++)
				{
					p += GerstnerWave_Cross(amplitude[n2], frequency[n2], steepness[n2], speed[n2], dir[n2], noiseSize[n2], worldPos.xz, time, n2);
				}
 
				worldPos.xyz += p;
 
				o.uv = TRANSFORM_TEX(uv, _MainTex);
				o.pos = UnityObjectToClipPos(mul(unity_WorldToObject, worldPos));
 
				return o;
			}
 
			// フラグメントシェーダー
            fixed4 FS (ds_output i) : SV_Target
            {
				// --------------------
				// 法線計算
				// --------------------
				float3 worldPos = i.worldPos;
				float3 geometryPos = worldPos;
 
				// @todo 時間計算は外でしたい
				float time = _Time.x * _WaveTimeSpeed;
 
				float3 p = 0.0;
				float3 pBinormal = float3(0.05, 0.0, 0.0);
				float3 pTangent =float3(0.0, 0.0, 0.05);
				float3 vBinormal = worldPos.xyz + float3(0.05, 0.0, 0.0);
				float3 vTangent = worldPos.xyz + float3(0.0, 0.0, 0.05);

				// @todo 重たいのでどうにかしたい
				for(int n = 0; n < sub_wave_num; n++)
				{
					p			+= GerstnerWave(amplitude[n], frequency[n], steepness[n], speed[n], dir[n], noiseSize[n], worldPos.xz, time, n);
					pBinormal	+= GerstnerWave(amplitude[n], frequency[n], steepness[n], speed[n], dir[n], noiseSize[n], vBinormal.xz, time, n);
					pTangent	+= GerstnerWave(amplitude[n], frequency[n], steepness[n], speed[n], dir[n], noiseSize[n], vTangent.xz, time, n);
				}

				for(int n2 = sub_wave_num; n2 < wave_num; n2++)
				{
					p			+= GerstnerWave_Cross(amplitude[n2], frequency[n2], steepness[n2], speed[n2], dir[n2], noiseSize[n2], worldPos.xz, time, n2);
					pBinormal	+= GerstnerWave_Cross(amplitude[n2], frequency[n2], steepness[n2], speed[n2], dir[n2], noiseSize[n2], vBinormal.xz, time, n2);
					pTangent	+= GerstnerWave_Cross(amplitude[n2], frequency[n2], steepness[n2], speed[n2], dir[n2], noiseSize[n2], vTangent.xz, time, n2);
				}

				worldPos += p;
				float3 dist = worldPos - geometryPos;
				float3 normal = normalize(cross(pTangent - p, pBinormal - p));
 
				// --------------------
				// カラー計算
				// --------------------
				float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 halfDir = normalize(lightDir + viewDir);

				float diffuse = saturate(dot(normal, lightDir)) * _LightColor0;
				float waterHeight = worldPos.y - geometryPos.y;
				float3 waterColor = 
					diffuse * _WaterBaseColor * _WaterBaseColorStrength +		// 基本カラー
					waterHeight * _WaterShallowColor * _WaterHeightColorCoef;	// 浅瀬カラー
 
                return fixed4(waterColor, 1.0);
            }
            ENDCG
        }
    }
}
