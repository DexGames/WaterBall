
Shader "Custom/WaterShader3"
{
    Properties
    {
        _MainTex ("MainTexture", 2D) = "white" {}

		_TessFactor("TessFactor",Vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags {"RenderType"="Opaque" "LightMode" = "ForwardBase"}
        LOD 100

		ZWrite Off
		Cull Off

        Pass
        {
            CGPROGRAM

			#define TEXTURE_SIZE 2048
			#define PI 3.141592653f
			#define PI_2 (2.0f * PI)
			#define GRAVITY 9.8f

            #pragma vertex VS
			#pragma hull HSMain
			#pragma domain DS
            #pragma fragment FS
			#define PATCH_SIZE 3

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct vs_input
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
				float3 normal :NORMAL;
            };

			struct fs_input
			{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

            sampler2D _MainTex; // メインテクスチャ
            float4 _MainTex_ST;
			float4 _TessFactor;

			
			// iPos = 波計算前の頂点座標
			// t = 時間
			// l = 波長(L)
			// q = 波の強度(Q) ちょっと違うからちゃんと調べとく
			// r = 波の激しさ(R)
			// b = 風向き(B)
			// oPos = 計算結果座標
			// oNormal = 計算結果法線
			void GerstnerWave(float3 iPos, float t, float l, float q, float r, float2 b, inout float3 oPos, inout float3 oNormal)
			{
				b = normalize(b);

				float _a = l / 14.0f;
				float _pi2_l = PI_2 / l;
				float d = dot(b, iPos.xz);
				float th = _pi2_l * d + sqrt(GRAVITY / _pi2_l) * t;

				float3 pos = float3(0.0f, r * _a * sin(th), 0.0);
				pos.xz = q * _a * b * cos(th);


				float3 normal = float3(0.0f, 1.0f, 0.0f);
				normal.xz = -b * r * cos(th) / (7.0f / PI - q * b * b * sin(th));

				oPos += pos;
				oNormal += normalize(normal);
			}

			// 頂点シェーダー
            vs_output VS (vs_input i)
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
				// memo
				// 振幅 = 波長(L)/14 が最大値になる(たまにでる14はこれ)

				ds_output o;

				float3 pos = i[0].pos * bary.x + i[1].pos * bary.y + i[2].pos * bary.z;
				float2 uv = i[0].uv * bary.x + i[1].uv * bary.y + i[2].uv * bary.z;
				uv = TRANSFORM_TEX(uv, _MainTex);

				float3 oPos = float3(0.0f, 0.0f, 0.0f);
				float3 oNormal = float3(0.0f, 0.0f, 0.0f);
				float t = _Time.y;

				// 座標, 時間, 波長, 波強度?, 波の激しさ, 風向き, 出力座標, 出力法線
				GerstnerWave(pos, t,       1.0, 0.3, 0.5, float2(-0.4, 0.6), oPos, oNormal);
				GerstnerWave(pos, t,       2.1, 0.4, 0.4, float2(-0.2, 0.6), oPos, oNormal);
				GerstnerWave(pos, t + 1.0, 0.4, 0.6, 0.2, float2(0.3, 0.2), oPos, oNormal);
				GerstnerWave(pos, t + 2.0, 0.7, 0.7, 0.3, float2(0.2, 0.3),  oPos, oNormal);
				GerstnerWave(pos, t + 3.0, 1.8, 0.3, 0.5, float2(0.4, 0.4),  oPos, oNormal);

				pos += oPos;
				float3 normal = normalize(oNormal);

				o.pos = UnityObjectToClipPos(float4(pos, 1));
				o.uv = uv;
				o.normal = normal;

				return o;
			}

			// フラグメントシェーダー
            fixed4 FS (fs_input i) : SV_Target
            {
				float3 lightDir = _WorldSpaceLightPos0;
				float NL = dot(i.normal, lightDir);

				float4 baseColor = tex2D(_MainTex, i.uv);
				float4 lightColor = _LightColor0;

				return baseColor * _LightColor0 * max(NL, 0.23f);
            }

            ENDCG
        }
    }
}
