
Shader "Custom/WaterShader"
{
    Properties
    {
        _MainTex ("MainTexture", 2D) = "white" {}
        _WaterHeight01Tex ("WaterHeightTex01", 2D) = "white" {}
        _WaterHeight02Tex ("WaterHeightTex02", 2D) = "white" {}
		_MyTime ("MyTime", Float) = 0.0
		_WaterHeight ("WaterHeight", Float) = 0.0
		_WaterWidth ("WaterWidth", Float) = 0.0

		_TessFactor("TessFactor",Vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" "LightMode" = "ForwardBase"}
        LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            CGPROGRAM

			#define TEXTURE_SIZE 2048
			//#define NORMAL_OUTPUT

            #pragma vertex VS
			#pragma hull HSMain
			#pragma domain DS
            #pragma fragment FS
			#define PATCH_SIZE 3

            #include "UnityCG.cginc"

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

				#ifdef NORMAL_OUTPUT
				float4 color : COLOR;
				#endif
            };

			struct fs_input
			{
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;

				#ifdef NORMAL_OUTPUT
				float4 color : COLOR;
				#endif
			};

            sampler2D _MainTex;				// メインテクスチャ
			sampler2D _WaterHeight01Tex;	// 波模様テクスチャ
			sampler2D _WaterHeight02Tex;	// 大波テクスチャ
            float4 _MainTex_ST;
			float _MyTime;
			float _WaterHeight;
			float _WaterWidth;

			float4 _TessFactor;

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
				ds_output o;

				float3 pos = i[0].pos * bary.x + i[1].pos * bary.y + i[2].pos * bary.z;
				float2 uv = i[0].uv * bary.x + i[1].uv * bary.y + i[2].uv * bary.z;
				uv = TRANSFORM_TEX(uv, _MainTex);

                uv.y += _MyTime * 0.2;
				float height = tex2Dlod(_WaterHeight01Tex, float4(uv, 0, 0)).y;
				//height += tex2Dlod(_WaterHeight02Tex, float4(uv, 0, 0)).y;
				height += _WaterHeight;
				pos.y = height;

				// 現状2点間の勾配から法線を求めているがもう少し滑らかにするならサンプル数増やしたりする必要あると思う
				float xGrad = 
					 tex2Dlod(_WaterHeight01Tex, float4(uv.x + 1.0 / TEXTURE_SIZE, uv.y, 0, 0)) - 
					 tex2Dlod(_WaterHeight01Tex, float4(uv.x - 1.0 / TEXTURE_SIZE, uv.y, 0, 0));
				float yGrad = 
					tex2Dlod(_WaterHeight01Tex, float4(uv.x, uv.y + 1.0 / TEXTURE_SIZE, 0, 0)) - 
					tex2Dlod(_WaterHeight01Tex, float4(uv.x, uv.y - 1.0 / TEXTURE_SIZE, 0, 0));

				float3 normal = normalize(cross(float3(1, 1, yGrad), float3(1, 1, xGrad)));
				
				#ifdef NORMAL_OUTPUT
				float3 L = normalize(float3(-5, 10, 3) - pos);
				o.color = tex2Dlod(_MainTex, float4(uv,0,0)) * max(dot(L, normal), 0.4);
				o.color.a = 1;
				#endif

				o.pos = UnityObjectToClipPos(float4(pos, 1));
				o.uv = uv;

				return o;
			}

			// フラグメントシェーダー
            fixed4 FS (fs_input i) : SV_Target
            {
				#ifdef NORMAL_OUTPUT
				return i.color;
				#else
                return tex2D(_MainTex, i.uv);
				#endif
            }

            ENDCG
        }
    }
}
